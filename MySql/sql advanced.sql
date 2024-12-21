-- Using Common Table Expressions (CTE)
-- A CTE allows you to define a subquery block that can be referenced within the main query. 
-- It is particularly useful for recursive queries or queries that require referencing a higher level
-- this is something we will look at in the next lesson/

-- Let's take a look at the basics of writing a CTE:


-- First, CTEs start using a "With" Keyword. Now we get to name this CTE anything we want
-- Then we say as and within the parenthesis we build our subquery/table we want
WITH CTE_Example AS 
(
SELECT gender, SUM(salary), MIN(salary), MAX(salary), COUNT(salary), AVG(salary)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
-- directly after using it we can query the CTE
SELECT *
FROM CTE_Example;


-- Now if I come down here, it won't work because it's not using the same syntax
SELECT *
FROM CTE_Example;



-- Now we can use the columns within this CTE to do calculations on this data that
-- we couldn't have done without it.

WITH CTE_Example AS 
(
SELECT gender, SUM(salary), MIN(salary), MAX(salary), COUNT(salary)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
-- notice here I have to use back ticks to specify the table names  - without them it doesn't work
SELECT gender, ROUND(AVG(`SUM(salary)`/`COUNT(salary)`),2)
FROM CTE_Example
GROUP BY gender;



-- we also have the ability to create multiple CTEs with just one With Expression

WITH CTE_Example AS 
(
SELECT employee_id, gender, birth_date
FROM employee_demographics dem
WHERE birth_date > '1985-01-01'
), -- just have to separate by using a comma
CTE_Example2 AS 
(
SELECT employee_id, salary
FROM parks_and_recreation.employee_salary
WHERE salary >= 50000
)
-- Now if we change this a bit, we can join these two CTEs together
SELECT *
FROM CTE_Example cte1
LEFT JOIN CTE_Example2 cte2
	ON cte1. employee_id = cte2. employee_id;


-- the last thing I wanted to show you is that we can actually make our life easier by renaming the columns in the CTE
-- let's take our very first CTE we made. We had to use tick marks because of the column names

-- we can rename them like this
WITH CTE_Example (gender, sum_salary, min_salary, max_salary, count_salary) AS 
(
SELECT gender, SUM(salary), MIN(salary), MAX(salary), COUNT(salary)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
-- notice here I have to use back ticks to specify the table names  - without them it doesn't work
SELECT gender, ROUND(AVG(sum_salary/count_salary),2)
FROM CTE_Example
GROUP BY gender;

#temporary tables

-- Using Temporary Tables
-- Temporary tables are tables that are only visible to the session that created them. 
-- They can be used to store intermediate results for complex queries or to manipulate data before inserting it into a permanent table.

-- There's 2 ways to create temp tables:
-- 1. This is the less commonly used way - which is to build it exactly like a real table and insert data into it

CREATE TEMPORARY TABLE temp_table
(first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
);

-- if we execute this it gets created and we can actualyl query it.

SELECT *
FROM temp_table;
-- notice that if we refresh out tables it isn't there. It isn't an actual table. It's just a table in memory.

-- now obviously it's balnk so we would need to insert data into it like this:

INSERT INTO temp_table
VALUES ('Alex','Freberg','Lord of the Rings: The Twin Towers');

-- now when we run it and execute it again we have our data
SELECT *
FROM temp_table;

-- the second way is much faster and my preferred method
-- 2. Build it by inserting data into it - easier and faster

CREATE TEMPORARY TABLE salary_over_50k
SELECT *
FROM employee_salary
WHERE salary >= 50000;

-- if we run this query we get our output
SELECT *
FROM salary_over_50k;

-- this is the primary way I've used temp tables especially if I'm just querying data and have some complex data I want to put into boxes or these temp tables to use later
-- it helps me kind of categorize and separate it out

#stored procedures
-- So let's look at how we can create a stored procedure

-- First let's just write a super simple query
SELECT *
FROM employee_salary
WHERE salary >= 60000;

-- Now let's put this into a stored procedure.
CREATE PROCEDURE large_salaries()
SELECT *
FROM employee_salary
WHERE salary >= 60000;

-- Now if we run this it will work and create the stored procedure
-- we can click refresh and see that it is there

-- notice it did not give us an output, that's because we 

-- If we want to call it and use it we can call it by saying:
CALL large_salaries();

-- as you can see it ran the query inside the stored procedure we created


-- Now how we have written is not actually best practice.alter
-- Usually when writing a stored procedure you don't have a simple query like that. It's usually more complex

-- if we tried to add another query to this stored procedure it wouldn't work. It's a separate query:
CREATE PROCEDURE large_salaries2()
SELECT *
FROM employee_salary
WHERE salary >= 60000;
SELECT *
FROM employee_salary
WHERE salary >= 50000;


-- Best practice is to use a delimiter and a Begin and End to really control what's in the stored procedure
-- let's see how we can do this.
-- the delimiter is what separates the queries by default, we can change this to something like two $$
-- in my career this is what I've seen a lot of people who work in SQL use so I've picked it up as well

-- When we change this delimiter it now reads in everything as one whole unit or query instead of stopping
-- after the first semi colon
DELIMITER $$
CREATE PROCEDURE large_salaries2()
BEGIN
	SELECT *
	FROM employee_salary
	WHERE salary >= 60000;
	SELECT *
	FROM employee_salary
	WHERE salary >= 50000;
END $$

-- now we change the delimiter back after we use it to make it default again
DELIMITER ;

-- let's refresh to see the SP
-- now we can run this stored procedure
CALL large_salaries2();

-- as you can see we have 2 outputs which are the 2 queries we had in our stored procedure



-- we can also create a stored procedure by right clicking on Stored Procedures and creating one:

-- it's going to drop the procedure if it already exists.
USE `parks_and_recreation`;
DROP procedure IF EXISTS `large_salaries3`;
-- it automatically adds the dilimiter for us
DELIMITER $$
CREATE PROCEDURE large_salaries3()
BEGIN
	SELECT *
	FROM employee_salary
	WHERE salary >= 60000;
	SELECT *
	FROM employee_salary
	WHERE salary >= 50000;
END $$

DELIMITER ;

-- and changes it back at the end

-- this can be a genuinely good option to help you write your Stored Procedures faster, although either way
-- works

-- if we click finish you can see it is created the same and if we run it

CALL large_order_totals3();

-- we get our results



-- -------------------------------------------------------------------------

-- we can also add parameters
USE `parks_and_recreation`;
DROP procedure IF EXISTS `large_salaries3`;
-- it automatically adds the dilimiter for us
DELIMITER $$
CREATE PROCEDURE large_salaries3(employee_id_param INT)
BEGIN
	SELECT *
	FROM employee_salary
	WHERE salary >= 60000
    AND employee_id_param = employee_id;
END $$

DELIMITER ;



CALL large_salaries3(1);

#triggers and events
#Triggers

-- a Trigger is a block of code that executes automatically executes when an event takes place in a table.

-- for example we have these 2 tables, invoice and payments - when a client makes a payment we want it to update the invoice field "total paid"
-- to reflect that the client has indeed paid their invoice


SELECT * FROM employee_salary;

SELECT * FROM employee_demographics;

-- so really when we get a new row or data is inserted into the payments table we want a trigger to update the correct invoice 
-- with the amount that was paid
-- so let's write this out
USE parks_and_recreation;
DELIMITER $$

CREATE TRIGGER employee_insert2
    -- we can also do BEFORE, but for this lesson we have to do after
	AFTER INSERT ON employee_salary
    -- now this means this trigger gets activated for each row that is inserted. Some sql databses like MSSQL have batch triggers or table level triggers that
    -- only trigger once, but MySQL doesn't have this functionality unfortunately
    FOR EACH ROW
    
    -- now we can write our block of code that we want to run when this is triggered
BEGIN
-- we want to update our client invoices table
-- and set the total paid = total_paid (if they had already made some payments) + NEW.amount_paid
-- NEW says only from the new rows that were inserted. There is also OLD which is rows that were deleted or updated, but for us we want NEW
    INSERT INTO employee_demographics (employee_id, first_name, last_name) VALUES (NEW.employee_id,NEW.first_name,NEW.last_name);
END $$

DELIMITER ; 

-- Now let's run it and create it


-- Now that it's created let's test it out.

-- Let's insert a payment into the payments table and see if it updates in the Invoice table.

-- so let's put the values that we want to insert - let's pay off this invoice 3 in full
INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES(13, 'Jean-Ralphio', 'Saperstein', 'Entertainment 720 CEO', 1000000, NULL);
-- now it was updated in the payments table and the trigger was triggered and update the corresponding values in the invoice table

DELETE FROM employee_demographics
WHERE employee_id = 13;



#events

-- now let's look at Events

-- Now I usually call these "Jobs" because I called them that for years in MSSQL, but in MySQL they're called Events

-- Events are task or block of code that gets executed according to a schedule. These are fantastic for so many reasons. Importing data on a schedule. 
-- Scheduling reports to be exported to files and so many other things
-- you can schedule all of this to happen every day, every monday, every first of the month at 10am. Really whenever you want

-- This really helps with automation in MySQL

-- let's say Parks and Rec has a policy that anyone over the age of 60 is immediately retired with lifetime pay
-- All we have to do is delete them from the demographics table

SELECT * 
FROM parks_and_recreation.employee_demographics;

SHOW EVENTS;
-- we can drop or alter these events like this:
DROP EVENT IF EXISTS delete_retirees;
DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO BEGIN
	DELETE
	FROM parks_and_recreation.employee_demographics
    WHERE age >= 60;
END $$


-- if we run it again you can see Jerry is now fired -- or I mean retired
SELECT * 
FROM parks_and_recreation.employee_demographics;
