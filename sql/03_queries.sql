
-- =========================================================
-- SECUREBANK QUERIES
-- =========================================================

-- 1. DISPLAY ALL CUSTOMERS AND THEIR ACCOUNTS

SELECT
    c.CustomerID,
    c.CustomerName,
    a.AccountNo,
    a.AccountType,
    a.Balance,
    a.Status
FROM Customer c
LEFT JOIN Account a
    ON c.CustomerID = a.CustomerID
ORDER BY c.CustomerID;


-- =========================================================
-- 2. DISPLAY ALL BRANCHES AND ACCOUNTS
-- =========================================================

SELECT
    b.BranchID,
    b.BranchName,
    b.City,
    a.AccountNo,
    a.Balance
FROM Branch b
LEFT JOIN Account a
    ON b.BranchID = a.BranchID
ORDER BY b.BranchID;


-- =========================================================
-- 3. REQUIRED ASSIGNMENT QUERY
-- TOTAL BALANCE AND NUMBER OF ACCOUNTS PER BRANCH
-- =========================================================

SELECT
    b.BranchID,
    b.BranchName,
    COUNT(a.AccountID) AS NumberOfAccounts,
    COALESCE(SUM(a.Balance), 0) AS TotalBalance
FROM Branch b
LEFT JOIN Account a
    ON b.BranchID = a.BranchID
GROUP BY
    b.BranchID,
    b.BranchName
ORDER BY b.BranchID;


-- =========================================================
-- 4. CUSTOMER LOAN DETAILS
-- =========================================================

SELECT
    c.CustomerName,
    l.LoanID,
    l.LoanAmount,
    l.InterestRate,
    l.LoanDate,
    l.Status,
    b.BranchName
FROM Loan l
JOIN Customer c
    ON l.CustomerID = c.CustomerID
JOIN Branch b
    ON l.BranchID = b.BranchID
ORDER BY l.LoanID;


-- =========================================================
-- 5. ACCOUNTS WITH BALANCE ABOVE 30000
-- =========================================================

SELECT
    AccountID,
    AccountNo,
    CustomerID,
    Balance
FROM Account
WHERE Balance > 30000
ORDER BY Balance DESC;


-- =========================================================
-- 6. TOTAL BALANCE PER CUSTOMER
-- =========================================================

SELECT
    c.CustomerID,
    c.CustomerName,
    COALESCE(SUM(a.Balance), 0) AS TotalBalance
FROM Customer c
LEFT JOIN Account a
    ON c.CustomerID = a.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName
ORDER BY TotalBalance DESC;


-- =========================================================
-- 7. ALL TRANSACTIONS
-- =========================================================

SELECT
    t.TransactionID,
    a.AccountNo,
    c.CustomerName,
    t.Type,
    t.Amount,
    t.Timestamp,
    t.Description
FROM BankTransaction t
JOIN Account a
    ON t.AccountID = a.AccountID
JOIN Customer c
    ON a.CustomerID = c.CustomerID
ORDER BY t.Timestamp DESC, t.TransactionID DESC;


-- =========================================================
-- 8. ACTIVE ACCOUNTS
-- =========================================================

SELECT
    AccountID,
    AccountNo,
    AccountType,
    Balance
FROM Account
WHERE Status = 'Active';


-- =========================================================
-- 9. SUBQUERY
-- CUSTOMERS HAVING BALANCE ABOVE AVERAGE
-- =========================================================

SELECT
    c.CustomerName,
    a.AccountNo,
    a.Balance
FROM Customer c
JOIN Account a
    ON c.CustomerID = a.CustomerID
WHERE a.Balance >
(
    SELECT AVG(Balance)
    FROM Account
    WHERE Status = 'Active'
);


-- =========================================================
-- 10. ACCOUNT COUNT BY ACCOUNT TYPE
-- =========================================================

SELECT
    AccountType,
    COUNT(*) AS NumberOfAccounts
FROM Account
GROUP BY AccountType
ORDER BY AccountType;


-- =========================================================
-- 11. SUBQUERY (NOT EXISTS)
-- CUSTOMERS WHO HAVE NO LOAN
-- =========================================================

SELECT
    c.CustomerID,
    c.CustomerName
FROM Customer c
WHERE NOT EXISTS
(
    SELECT 1
    FROM Loan l
    WHERE l.CustomerID = c.CustomerID
)
ORDER BY c.CustomerID;


-- =========================================================
-- 12. TOTAL LOAN AMOUNT PER BRANCH (AGGREGATE + JOIN)
-- =========================================================

SELECT
    b.BranchName,
    COUNT(l.LoanID) AS NumberOfLoans,
    COALESCE(SUM(l.LoanAmount), 0) AS TotalLoanAmount
FROM Branch b
LEFT JOIN Loan l
    ON b.BranchID = l.BranchID
GROUP BY b.BranchID, b.BranchName
ORDER BY b.BranchID;


-- =========================================================
-- 13. CONSISTENCY CHECK
-- ACCOUNT BALANCE MUST EQUAL (SUM OF CREDITS - SUM OF DEBITS)
-- Every row should show Consistent = 'YES'.
-- =========================================================

SELECT
    a.AccountID,
    a.AccountNo,
    a.Balance AS StoredBalance,
    COALESCE(SUM(CASE WHEN t.Type = 'Credit' THEN t.Amount
                      WHEN t.Type = 'Debit'  THEN -t.Amount END), 0)
        AS BalanceFromHistory,
    CASE
        WHEN a.Balance = COALESCE(SUM(CASE WHEN t.Type = 'Credit' THEN t.Amount
                                           WHEN t.Type = 'Debit'  THEN -t.Amount END), 0)
        THEN 'YES' ELSE 'NO'
    END AS Consistent
FROM Account a
LEFT JOIN BankTransaction t
    ON a.AccountID = t.AccountID
GROUP BY a.AccountID, a.AccountNo, a.Balance
ORDER BY a.AccountID;
