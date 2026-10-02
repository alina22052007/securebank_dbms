-- =========================================================
-- SECUREBANK SAMPLE DATA
-- =========================================================

-- =========================================================
-- BRANCHES
-- =========================================================

INSERT INTO Branch
(BranchName, City, Address, IFSCCode, Phone, Email)
VALUES
('Mumbai Central Branch', 'Mumbai',
 'MG Road, Mumbai', 'SBNK000001',
 '9876543210', 'mumbai@securebank.com'),

('Delhi Main Branch', 'Delhi',
 'Connaught Place, Delhi', 'SBNK000002',
 '9876543211', 'delhi@securebank.com'),

('Bangalore Branch', 'Bangalore',
 'MG Road, Bangalore', 'SBNK000003',
 '9876543212', 'bangalore@securebank.com');


-- =========================================================
-- CUSTOMERS
-- =========================================================

INSERT INTO Customer
(CustomerName, DOB, Address, Phone, Email)
VALUES
('Aarav Sharma', '2000-05-15',
 'Mumbai, Maharashtra', '9000000001',
 'aarav@example.com'),

('Ananya Patel', '2001-08-20',
 'Delhi, India', '9000000002',
 'ananya@example.com'),

('Rahul Mehta', '1999-03-10',
 'Bangalore, Karnataka', '9000000003',
 'rahul@example.com'),

('Priya Singh', '2002-11-25',
 'Mumbai, Maharashtra', '9000000004',
 'priya@example.com'),

('Rohan Verma', '1998-07-05',
 'Delhi, India', '9000000005',
 'rohan@example.com');


-- =========================================================
-- ACCOUNTS
-- =========================================================

INSERT INTO Account
(AccountNo, CustomerID, BranchID, AccountType, Balance, Status)
VALUES
('SB100001', 1, 1, 'Savings', 50000.00, 'Active'),

('SB100002', 2, 2, 'Savings', 35000.00, 'Active'),

('SB100003', 3, 3, 'Current', 80000.00, 'Active'),

('SB100004', 4, 1, 'Savings', 25000.00, 'Active'),

('SB100005', 5, 2, 'Savings', 60000.00, 'Active'),

('SB100006', 1, 3, 'Savings', 0.00, 'Closed');


-- =========================================================
-- LOANS
-- =========================================================

INSERT INTO Loan
(CustomerID, BranchID, LoanAmount, InterestRate, LoanDate, Status)
VALUES
(1, 1, 500000.00, 7.50, '2026-01-10', 'Approved'),

(2, 2, 300000.00, 8.00, '2026-02-15', 'Approved'),

(3, 3, 750000.00, 7.25, '2026-03-20', 'Pending');


-- =========================================================
-- INITIAL TRANSACTION HISTORY
-- =========================================================

INSERT INTO BankTransaction
(AccountID, Type, Amount, Description)
VALUES
(1, 'Credit', 50000.00, 'Initial account deposit'),

(2, 'Credit', 35000.00, 'Initial account deposit'),

(3, 'Credit', 80000.00, 'Initial account deposit'),

(4, 'Credit', 25000.00, 'Initial account deposit'),

(5, 'Credit', 60000.00, 'Initial account deposit');


SELECT 'Sample data inserted successfully!' AS Message;