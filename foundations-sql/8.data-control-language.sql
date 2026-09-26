-- DCL (Data Control Language) = controls who can access database objects and what actions 
--                               they are allowed to perform.

-- Its two core commands are:
--              - GRANT: give a role/user permission.
--              - REVOKE: remove a previously granted permission.

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE      -- grant full permission
ON dim_product
TO warehouse_editor;

GRANT SELECT                                    -- can only read orders
ON fact_order
TO analyst_role;

-- To revoke a permission:
REVOKE UPDATE
ON dim_product
FROM warehouse_editor;


-- Follow the least-privilege principle: give each role only the permissions required for 
-- its job. In a real system, permissions may apply to schemas, tables, columns, sequences, 
-- functions, and databases—not just tables.