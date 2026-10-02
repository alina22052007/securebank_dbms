-- =========================================================
-- SECUREBANK ROLLBACK / ATOMICITY TEST (PostgreSQL)
-- Scenario from the problem statement:
--   "the debit succeeds but the matching credit fails"
-- =========================================================

-- ---------------------------------------------------------
-- SCENARIO A: credit fails because account does not exist
-- ---------------------------------------------------------

SELECT 'BEFORE (Scenario A)' AS Step, AccountID, AccountNo, Balance
FROM Account WHERE AccountID = 1;

BEGIN;

-- Step 1: debit sender  (succeeds)
UPDATE Account SET Balance = Balance - 1000.00 WHERE AccountID = 1;

INSERT INTO BankTransaction (AccountID, Type, Amount, Description)
VALUES (1, 'Debit', 1000.00, 'Rollback test debit');

-- Step 2: credit receiver (FAILS - account 99999 does not exist)
INSERT INTO BankTransaction (AccountID, Type, Amount, Description)
VALUES (99999, 'Credit', 1000.00, 'Deliberate failure');

-- The transaction is now in a failed state -> undo everything
ROLLBACK;

SELECT 'AFTER ROLLBACK (Scenario A)' AS Step, AccountID, AccountNo, Balance
FROM Account WHERE AccountID = 1;      -- identical to BEFORE

SELECT COUNT(*) AS LeftoverDebitRows
FROM BankTransaction
WHERE Description = 'Rollback test debit';   -- must be 0


-- ---------------------------------------------------------
-- SCENARIO B: credit fails because receiver account is CLOSED
-- ---------------------------------------------------------

SELECT 'BEFORE (Scenario B)' AS Step, AccountID, AccountNo, Balance
FROM Account WHERE AccountID IN (1, 6) ORDER BY AccountID;

BEGIN;

UPDATE Account SET Balance = Balance - 1000.00 WHERE AccountID = 1;   -- succeeds

UPDATE Account SET Balance = Balance + 1000.00 WHERE AccountID = 6;   -- FAILS (closed-account trigger)

ROLLBACK;

SELECT 'AFTER ROLLBACK (Scenario B)' AS Step, AccountID, AccountNo, Balance
FROM Account WHERE AccountID IN (1, 6) ORDER BY AccountID;   -- identical to BEFORE
