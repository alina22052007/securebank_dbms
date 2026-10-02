-- =========================================================
-- FINAL VERIFICATION
-- =========================================================

-- 1. Current state of all accounts
SELECT AccountID, AccountNo, Balance, Status
FROM Account
ORDER BY AccountID;

-- 2. Money conservation: total of all balances.
--    Transfers only move money, so this equals the initial 250000.
SELECT SUM(Balance) AS TotalMoneyInBank FROM Account;

-- 3. Balance must equal credits minus debits for every account
SELECT
    a.AccountNo,
    a.Balance AS StoredBalance,
    COALESCE(SUM(CASE WHEN t.Type = 'Credit' THEN t.Amount
                      ELSE -t.Amount END), 0) AS BalanceFromHistory,
    CASE WHEN a.Balance = COALESCE(SUM(CASE WHEN t.Type = 'Credit' THEN t.Amount
                                            ELSE -t.Amount END), 0)
         THEN 'YES' ELSE 'NO' END AS Consistent
FROM Account a
LEFT JOIN BankTransaction t ON a.AccountID = t.AccountID
GROUP BY a.AccountID, a.AccountNo, a.Balance
ORDER BY a.AccountID;
