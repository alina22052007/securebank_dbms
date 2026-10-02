-- =========================================================
-- SECUREBANK - POSTGRESQL DATABASE SCHEMA
-- =========================================================

-- NOTE:
-- First create a database named securebank in PostgreSQL.
-- Then connect to the securebank database and run this file.

-- =========================================================
-- DROP OLD TABLES
-- =========================================================


DROP TABLE IF EXISTS BankTransaction CASCADE;
DROP TABLE IF EXISTS Loan CASCADE;
DROP TABLE IF EXISTS Account CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Branch CASCADE;

-- =========================================================
-- BRANCH
-- Branch information is stored separately to satisfy
-- normalization / BCNF requirements.
-- =========================================================

CREATE TABLE Branch (
    BranchID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    BranchName VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    IFSCCode VARCHAR(20) NOT NULL UNIQUE,
    Phone VARCHAR(15),
    Email VARCHAR(100)
);

-- =========================================================
-- CUSTOMER
-- =========================================================

CREATE TABLE Customer (
    CustomerID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Phone VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE
);

-- =========================================================
-- ACCOUNT
-- =========================================================

CREATE TABLE Account (
    AccountID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    AccountNo VARCHAR(20) NOT NULL UNIQUE,
    CustomerID INTEGER NOT NULL,
    BranchID INTEGER NOT NULL,
    AccountType VARCHAR(20) NOT NULL DEFAULT 'Savings',
    Balance NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    CreatedDate DATE NOT NULL DEFAULT CURRENT_DATE,
    Status VARCHAR(20) NOT NULL DEFAULT 'Active',

    CONSTRAINT chk_account_type
        CHECK (AccountType IN ('Savings', 'Current', 'Fixed Deposit')),

    CONSTRAINT chk_account_balance
        CHECK (Balance >= 0),

    CONSTRAINT chk_account_status
        CHECK (Status IN ('Active', 'Closed')),

    CONSTRAINT fk_account_customer
        FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID),

    CONSTRAINT fk_account_branch
        FOREIGN KEY (BranchID)
        REFERENCES Branch(BranchID)
);

-- =========================================================
-- LOAN
-- =========================================================

CREATE TABLE Loan (
    LoanID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CustomerID INTEGER NOT NULL,
    BranchID INTEGER NOT NULL,
    LoanAmount NUMERIC(15,2) NOT NULL,
    InterestRate NUMERIC(5,2) NOT NULL,
    LoanDate DATE NOT NULL DEFAULT CURRENT_DATE,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending',

    CONSTRAINT chk_loan_amount
        CHECK (LoanAmount > 0),

    CONSTRAINT chk_interest_rate
        CHECK (InterestRate >= 0),

    CONSTRAINT chk_loan_status
        CHECK (Status IN ('Approved', 'Pending', 'Closed')),

    CONSTRAINT fk_loan_customer
        FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID),

    CONSTRAINT fk_loan_branch
        FOREIGN KEY (BranchID)
        REFERENCES Branch(BranchID)
);

-- =========================================================
-- BANK TRANSACTION
-- One account can have many debit/credit transactions.
-- =========================================================

CREATE TABLE BankTransaction (
    TransactionID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    AccountID INTEGER NOT NULL,
    Type VARCHAR(10) NOT NULL,
    Amount NUMERIC(15,2) NOT NULL,
    Timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Description VARCHAR(255),

    CONSTRAINT chk_transaction_type
        CHECK (Type IN ('Debit', 'Credit')),

    CONSTRAINT chk_transaction_amount
        CHECK (Amount > 0),

    CONSTRAINT fk_transaction_account
        FOREIGN KEY (AccountID)
        REFERENCES Account(AccountID)
);

-- =========================================================
-- PREVENT TRANSACTIONS ON CLOSED ACCOUNTS
-- =========================================================

CREATE OR REPLACE FUNCTION check_active_account()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM Account
        WHERE AccountID = NEW.AccountID
          AND Status = 'Active'
    ) THEN

        RAISE EXCEPTION
        'Transaction not allowed: account % does not exist or is closed.',
        NEW.AccountID;

    END IF;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_check_active_account
BEFORE INSERT ON BankTransaction
FOR EACH ROW
EXECUTE FUNCTION check_active_account();

-- =========================================================
-- PREVENT BALANCE CHANGE ON CLOSED ACCOUNTS
-- =========================================================

CREATE OR REPLACE FUNCTION prevent_closed_account_balance_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF OLD.Status = 'Closed'
       AND NEW.Balance <> OLD.Balance THEN

        RAISE EXCEPTION
        'Cannot change balance of a closed account.';

    END IF;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_prevent_closed_balance_change
BEFORE UPDATE OF Balance ON Account
FOR EACH ROW
EXECUTE FUNCTION prevent_closed_account_balance_change();

-- =========================================================
-- INDEXES ON FOREIGN KEYS (faster joins / GROUP BY reports)
-- =========================================================

CREATE INDEX idx_account_customer ON Account(CustomerID);
CREATE INDEX idx_account_branch   ON Account(BranchID);
CREATE INDEX idx_loan_customer    ON Loan(CustomerID);
CREATE INDEX idx_loan_branch      ON Loan(BranchID);
CREATE INDEX idx_txn_account      ON BankTransaction(AccountID);

-- =========================================================
-- SUCCESS MESSAGE
-- =========================================================

SELECT 'SecureBank PostgreSQL schema created successfully!' AS Message;