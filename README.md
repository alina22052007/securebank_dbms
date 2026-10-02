# SecureBank - Online Banking Account & Fund Transfer System

B.Tech CSE (2025-29) | Database Management Systems | Semester III | SQL & NoSQL Case Study 53
**Database: PostgreSQL**

## Deliverables -> where to find them

| Required deliverable | File |
|---|---|
| ER Diagram (entities, attributes, relationships, PK/FK) | `docs/ER_Diagram.png` (also `.svg`) |
| Schema design - normalized to 3NF/BCNF with keys & constraints | `docs/Schema_and_Normalization.md` and `sql/01_schema.sql` |
| SQL Scripts - DDL and DML | `sql/01_schema.sql`, `sql/02_insert_data.sql` |
| Query Set - JOINs, subqueries, aggregates | `sql/03_queries.sql` (13 queries; Query 3 = required branch report) |
| Transaction Management - atomic transfer with COMMIT / ROLLBACK | `sql/04_transfer.sql`, `sql/05_rollback_test.sql` |
| Working Database - loaded schema + documented query outputs | `sql/run_all.sql`, `docs/Query_Outputs.md`, `docs/Transaction_Outputs.md` |

## How to run

1. Create the database (once):
   ```sql
   CREATE DATABASE securebank;
   ```
2. Run everything in order from inside the `sql/` folder:
   ```bash
   cd sql
   psql -U postgres -d securebank -f run_all.sql
   ```
   Or run the files one by one (pgAdmin Query Tool / psql `\i`): `01` -> `02` -> `03` -> `04` -> `05` -> `06`.

> Run the files in order and from a fresh schema: `01_schema.sql` drops and recreates all tables, so the numbers in the documented outputs are reproduced exactly.
> `run_all.sql` uses `\i`, which works in `psql` only (not in pgAdmin's Query Tool).

## Design summary

* 5 tables: **Branch, Customer, Account, Loan, BankTransaction**; all in BCNF (branch address and IFSC code live only in `Branch`).
* Atomic transfer: `transfer_funds(from, to, amount)` validates the amount, blocks same-account transfers, checks both accounts exist and are active, checks sufficient funds, locks both rows in a fixed order (deadlock-safe), then debits, credits and writes both ledger rows. Any failure aborts the transaction and everything is rolled back.
  ```sql
  BEGIN;
  SELECT transfer_funds(1, 2, 5000.00);
  COMMIT;
  ```
* `05_rollback_test.sql` reproduces the exact case in the problem statement - the debit succeeds but the matching credit fails - and shows the balance returns to its original value.

## Sample data

3 branches, 5 customers, 6 accounts (one closed), 3 loans, 5 opening deposits (total balance 250,000.00).
