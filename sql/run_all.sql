-- Run from the sql/ folder:   psql -U postgres -d securebank -f run_all.sql
\echo '=== 1. SCHEMA ===';        \i 01_schema.sql
\echo '=== 2. SAMPLE DATA ===';    \i 02_insert_data.sql
\echo '=== 3. QUERIES ===';        \i 03_queries.sql
\echo '=== 4. TRANSFER ===';       \i 04_transfer.sql
\echo '=== 5. ROLLBACK TEST ===';  \i 05_rollback_test.sql
\echo '=== 6. VERIFY ===';         \i 06_verify.sql
