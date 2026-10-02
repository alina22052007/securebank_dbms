-- =========================================================
-- SECUREBANK ATOMIC FUND TRANSFER (PostgreSQL)
-- =========================================================
-- A transfer = debit sender + credit receiver.
-- Both happen together or not at all: any RAISE EXCEPTION inside
-- the function aborts the surrounding transaction, so PostgreSQL
-- rolls back every change made so far (atomicity).

CREATE OR REPLACE FUNCTION transfer_funds(
    p_from_account INTEGER,
    p_to_account   INTEGER,
    p_amount       NUMERIC(15,2)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_sender_balance  NUMERIC(15,2);
    v_sender_status   VARCHAR(20);
    v_receiver_status VARCHAR(20);
BEGIN

    -- 1. Validate amount
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION 'Transfer amount must be greater than zero.';
    END IF;

    -- 2. Block same-account transfer
    IF p_from_account = p_to_account THEN
        RAISE EXCEPTION 'Sender and receiver accounts cannot be the same.';
    END IF;

    -- 3. Lock BOTH rows in a fixed order (lowest AccountID first).
    --    This prevents deadlock when two opposite transfers
    --    (A->B and B->A) run at the same time.
    PERFORM 1
    FROM Account
    WHERE AccountID IN (p_from_account, p_to_account)
    ORDER BY AccountID
    FOR UPDATE;

    -- 4. Read sender (now locked)
    SELECT Balance, Status
    INTO   v_sender_balance, v_sender_status
    FROM   Account
    WHERE  AccountID = p_from_account;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sender account % does not exist.', p_from_account;
    END IF;

    IF v_sender_status <> 'Active' THEN
        RAISE EXCEPTION 'Sender account is closed or inactive.';
    END IF;

    -- 5. Read receiver (now locked)
    SELECT Status
    INTO   v_receiver_status
    FROM   Account
    WHERE  AccountID = p_to_account;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Receiver account % does not exist.', p_to_account;
    END IF;

    IF v_receiver_status <> 'Active' THEN
        RAISE EXCEPTION 'Receiver account is closed or inactive.';
    END IF;

    -- 6. Check funds
    IF v_sender_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient balance in sender account.';
    END IF;

    -- 7. DEBIT sender
    UPDATE Account
    SET    Balance = Balance - p_amount
    WHERE  AccountID = p_from_account;

    INSERT INTO BankTransaction (AccountID, Type, Amount, Description)
    VALUES (p_from_account, 'Debit', p_amount,
            'Transfer to Account ' || p_to_account);

    -- 8. CREDIT receiver
    UPDATE Account
    SET    Balance = Balance + p_amount
    WHERE  AccountID = p_to_account;

    INSERT INTO BankTransaction (AccountID, Type, Amount, Description)
    VALUES (p_to_account, 'Credit', p_amount,
            'Transfer from Account ' || p_from_account);

END;
$$;


-- =========================================================
-- TEST 1: SUCCESSFUL TRANSFER  (Account 1 -> Account 2, 5000)
-- =========================================================

SELECT AccountID, AccountNo, Balance FROM Account
WHERE AccountID IN (1, 2) ORDER BY AccountID;      -- BEFORE

BEGIN;
SELECT transfer_funds(1, 2, 5000.00);
COMMIT;

SELECT AccountID, AccountNo, Balance FROM Account
WHERE AccountID IN (1, 2) ORDER BY AccountID;      -- AFTER (45000 / 40000)

SELECT TransactionID, AccountID, Type, Amount, Description
FROM BankTransaction
WHERE Description LIKE 'Transfer%'
ORDER BY TransactionID;


-- =========================================================
-- TEST 2-5: FAILED TRANSFERS (each must change NOTHING)
-- In psql each error is printed, ROLLBACK cleans up,
-- and the script continues with the next test.
-- =========================================================

-- Test 2: insufficient funds
BEGIN;
SELECT transfer_funds(4, 1, 999999.00);
ROLLBACK;

-- Test 3: same account
BEGIN;
SELECT transfer_funds(1, 1, 100.00);
ROLLBACK;

-- Test 4: receiver account is closed (Account 6)
BEGIN;
SELECT transfer_funds(1, 6, 100.00);
ROLLBACK;

-- Test 5: receiver does not exist
BEGIN;
SELECT transfer_funds(1, 99999, 100.00);
ROLLBACK;

-- Balances must be unchanged by tests 2-5
SELECT AccountID, AccountNo, Balance, Status FROM Account ORDER BY AccountID;
