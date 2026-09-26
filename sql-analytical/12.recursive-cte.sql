-- A recursive CTE can reference its own previous result to repeatedly process hierarchical 
-- or sequential data.

-- The classic use case is hierarchical data:
employee_id | employee_name | manager_id
------------+---------------+-----------
1           | Alice         | NULL
2           | Marco         | 1
3           | Sarah         | 1
4           | John          | 2
5           | Laura         | 2
6           | David         | 4


Alice
├── Marco
│   ├── John
│   │   └── David
│   └── Laura
│
└── Sarah


-- Give me the entire organizational hierarchy starting from Alice:
-- (assuming an 'employee' table)

WITH RECURSIVE employee_hierarchy AS (

    -- Anchor: start with the CEO
    SELECT
        employee_id,
        employee_name,
        manager_id,
        1 AS level
    FROM employee
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: find employees reporting
    -- to the previous level
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        h.level + 1
    FROM employee AS e
    JOIN employee_hierarchy AS h        -- CTE referenfes itself (the anchor query)
        ON e.manager_id = h.employee_id
)

SELECT *
FROM employee_hierarchy;

