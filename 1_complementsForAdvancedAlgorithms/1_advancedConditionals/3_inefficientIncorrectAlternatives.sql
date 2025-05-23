		-- 3 Practice Inefficient/Incorrect Alternatives vs. Advanced WHERE Conditions

-- 		3.1 Inefficient COUNT(*) vs. EXISTS for Existence Check
-- Problem: List department names that have at least one project associated with them
-- (i.e., a project where lead emp id belongs to an employee in that department).
-- • Task: Write a query using an inefficient approach: a correlated subquery with
-- COUNT(*) in the WHERE clause, checking if COUNT(*) > 0.
-- • Consideration: Why is using EXISTS generally more efficient for this type of ”is
-- there at least one?” check?
SELECT d.dept_name        -- Inefficient
FROM complementary.departments d
WHERE (
	SELECT COUNT (*)
	FROM complementary.projects p
	JOIN complementary.employees e ON p.lead_emp_id = e.emp_id
	WHERE e.dept_id = d.dept_id
) > 0;
SELECT d.dept_name        -- Efficient: uses less code and does not need to count all the things, just uses a bool
FROM complementary.departments d	-- value if data exists using 1 in SELECT
WHERE EXISTS (
	SELECT 1
	FROM complementary.projects p
	JOIN complementary.employees e ON p.lead_emp_id = e.emp_id
	WHERE e.dept_id = d.dept_id
);

-- 		3.2 Verbose/Incorrect NULL Handling vs. IS DISTINCT FROM
-- Problem: Find employees whose last bonus is not $5000.00. This list should include
-- employees whose last bonus is NULL, as NULL is considered different from $5000.00.
-- • Task: Write a query using a verbose approach: (last bonus <> 5000.00 OR
-- last bonus IS NULL).
-- • Consideration: How does last bonus IS DISTINCT FROM 5000.00 offer a more
-- concise and less error-prone solution?
SELECT emp_name, last_bonus 							-- Inefficient
FROM complementary.employees
WHERE ( last_bonus <> 5000.00 OR last_bonus IS NULL );
SELECT emp_name, last_bonus 							-- Efficient: includes null values as different of 5000
FROM complementary.employees							-- because <> avoids unknown values
WHERE (last_bonus IS DISTINCT FROM 5000.00);

-- 		3.3 Complex NULL-aware Equality vs. IS NOT DISTINCT FROM
-- Problem: Find all employees whose manager id is the same as Peter Pan’s manager id.
-- (Peter Pan, emp id 16, has a NULL manager id). Do not include Peter Pan himself in
-- the results.
-- • Task: Write a query using a complex approach: explicitly check for equality of
-- manager id with Peter Pan’s manager id, AND explicitly check if both the em-
-- ployee’s manager id and Peter Pan’s manager id are NULL.
-- • Consideration: How does using IS NOT DISTINCT FROM simplify this NULL-
-- aware equality check and make the query more robust and readable?

SELECT emp_name , manager_id   		-- Inefficient
FROM complementary.employees
WHERE emp_id != 16 
	AND (
	( manager_id = ( SELECT manager_id FROM complementary.employees WHERE emp_id = 16) )
	OR
	( manager_id IS NULL AND ( SELECT manager_id FROM complementary.employees WHERE emp_id = 16) IS NULL ));

SELECT emp_name , manager_id			-- Efficient
FROM complementary.employees
WHERE emp_id != 16 
	AND manager_id IS NOT DISTINCT FROM ( SELECT manager_id FROM complementary.employees WHERE emp_id = 16);

-- 		3.4 Using LEFT JOIN and checking for NULL vs. NOT EXISTS
-- Problem: Find departments that have no employees. (Note: The dataset includes an
-- ’Empty Department’ specifically for this exercise).
-- • Task: Write a query using a common approach: LEFT JOIN the departments table
-- with the employees table and then filter for departments where the employee’s
-- primary key (or any non-nullable employee column from the join) is NULL. Another
-- variant could use GROUP BY and HAVING COUNT(e.emp id) = 0.
-- • Consideration: For the specific task of checking non-existence, how does NOT
-- EXISTS compare in terms of directness and potential efficiency?

SELECT d.dept_name
FROM complementary.departments d
LEFT JOIN complementary.employees e ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;				-- Inefficient: it needs to make a cartesian product in the join

SELECT d.dept_name
FROM complementary.departments d
LEFT JOIN complementary.employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT ( e.emp_id ) = 0;		-- Inefficient: it needs to count the number of rows before to return the value
										about existence

SELECT d.dept_name
FROM complementary.departments d
WHERE NOT EXISTS (
	SELECT e.emp_id FROM complementary.employees e WHERE d.dept_id = e.dept_id
);									-- Efficient: returns the bool value as the existance is checked
