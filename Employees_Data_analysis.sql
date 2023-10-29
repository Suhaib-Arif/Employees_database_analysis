use employees;
/*
Exercise 1:
	Find Average of Salaries of Male and female employees in each Department
*/
SELECT 
    e.gender, d.dept_name AS department, AVG(s.salary) AS average_salary
FROM
    employees e
        JOIN
    salaries s ON s.emp_no = e.emp_no
        JOIN
    dept_emp dm ON dm.emp_no = e.emp_no
        JOIN
    departments d ON d.dept_no = dm.dept_no
GROUP BY e.gender , dm.dept_no
ORDER BY dm.dept_no , e.gender;

/*
Exercise 2:
	Find the total number of employees in each department
*/
Select
	dept_name as department,
    count(e.emp_no) as number_of_employees
from employees e 
join dept_emp de on de.emp_no = e.emp_no
join departments d on d.dept_no = de.dept_no
group by de.dept_no
order by de.dept_no;

/*
Exercise 3:
	Obtain a table containing the following three fields for all individuals whose employee number is not 
	greater than 10040: 
	- employee number 
	- the lowest department number among the departments where the employee has worked in.
	- assign '110022' as 'manager' to all individuals whose employee number is lower than or equal to 10020, 
	and '110039' to those whose number is between 10021 and 10040 inclusive
*/

SELECT 
    e.emp_no,
    de.dept_no,
    (CASE
        WHEN e.emp_no <= 10020 THEN 110022
        ELSE 110039
    END) AS manager
FROM
    employees e
        JOIN
    (SELECT 
        emp_no, MIN(dept_no) AS dept_no
    FROM
        dept_emp
    GROUP BY emp_no) AS de ON de.emp_no = e.emp_no
WHERE
    e.emp_no <= 10040;

/*
Exercise 4:
	Retrive a count of all employees that have been hired every year
*/
select * from employees
where year(hire_date) = '2000';

/*
Exercise 5:
	Retrieve a list of all employees from the ‘titles’ table who are engineers. 
	Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior 
	engineers.
*/

Select * from titles where title LIKE "%Engineer";

Select * from titles where title = "Senior Engineer";

/*
Exercise 6:
	Create a procedure that asks you to insert an employee number and that will obtain an output containing 
	the same number, as well as the number and name of the last department the employee has worked in.
*/

DROP PROCEDURE IF EXISTS last_department;


DELIMITER $$
CREATE PROCEDURE last_department(IN p_emp_no INTEGER)
BEGIN
	DECLARE max_dept_no CHAR(4);

	SELECT dept_no
		INTO max_dept_no
	FROM dept_emp
	WHERE emp_no = p_emp_no
	ORDER BY dept_no DESC
	LIMIT 1;
    
    SELECT d.emp_no, d.dept_no, de.dept_name
    FROM dept_emp d
    JOIN departments de ON d.dept_no = de.dept_no
    WHERE d.emp_no = p_emp_no AND d.dept_no = max_dept_no; 

END $$

DELIMITER ;

CALL last_department(10010);

/*
Exercise 7:
	How many contracts have been registered in the ‘salaries’ table with duration of more than one year and 
	of value higher than or equal to $100,000?
*/
SELECT
	count(*) as contract_count    
from salaries
where datediff(to_date,from_date) > 365
and salary >= 100000;

/*
Exercise 8:
	Create a trigger that checks if the hire date of an employee is higher than the current date. If true, set the 
	hire date to equal the current date. Format the output appropriately (YY-mm-dd). 
	Extra challenge: You can try to declare a new variable called 'today' which stores today's data, and then 
	use it in your trigger
*/
DELIMITER $$

CREATE TRIGGER date_checker
BEFORE INSERT ON employees
FOR EACH ROW
	BEGIN
		DECLARE today_date DATETIME;
        
        SET today_date = CURDATE();
        
        IF NEW.hire_date > today_date THEN
			SET NEW.hire_date = DATE_FORMAT(today_date, "YY-mm-dd");
		END IF;
    END $$

DELIMITER ;

INSERT INTO employees values(1000000,'2002-03-25','Rudeus', 'Grayrat', "M", "9999-01-01");

SELECT * from employees where emp_no = 1000000;

/*
Exercise 9:
	Define a function that retrieves the largest contract salary value of an employee. Apply it to employee 
	number 11356. 
	In addition, what is the lowest contract salary value of the same employee? You may want to create a new 
	function that to obtain the result.
*/


DELIMITER $$
CREATE FUNCTION max_salary_retriver(p_emp_no INTEGER) RETURNS INTEGER
DETERMINISTIC NO SQL READS SQL DATA
	BEGIN 
		DECLARE result INTEGER;
		SELECT MAX(salary) INTO result FROM salaries WHERE emp_no = p_emp_no;
        RETURN result;
	END $$
DELIMITER ;

select max_salary_retriver(11356);

---------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE FUNCTION min_salary_retriver(p_emp_no INTEGER) RETURNS INTEGER
DETERMINISTIC NO SQL READS SQL DATA
	BEGIN 
		DECLARE result INTEGER;
		SELECT MIN(salary) INTO result FROM salaries WHERE emp_no = p_emp_no;
        RETURN result;
	END $$
DELIMITER ;

select min_salary_retriver(11356);


/*
Exercise 10:
	Based on the previous exercise, you can now try to create a third function that also accepts a second 
	parameter. Let this parameter be a character sequence. Evaluate if its value is 'min' or 'max' and based on 
	that retrieve either the lowest or the highest salary, respectively (using the same logic and code structure 
	from Exercise 9). If the inserted value is any string value different from ‘min’ or ‘max’, let the function 
	return the difference between the highest and the lowest salary of that employee.
*/

DROP FUNCTION IF EXISTS salary_retriver;

DELIMITER $$
CREATE FUNCTION salary_retriver(p_emp_no INTEGER, operation VARCHAR(20)) RETURNS INTEGER
DETERMINISTIC NO SQL READS SQL DATA
	BEGIN 
		DECLARE result INTEGER;
        
        IF operation = "MAX" THEN
			SELECT MAX(salary) INTO result FROM salaries WHERE emp_no = p_emp_no;
            RETURN result;
		ELSEIF operation = "MIN" THEN
			SELECT MIN(salary) INTO result FROM salaries WHERE emp_no = p_emp_no;
			RETURN result;
        ELSE
			SELECT (MAX(salary) - MIN(salary)) INTO result FROM salaries WHERE emp_no = p_emp_no;
            RETURN result;
		END IF;
	END $$
DELIMITER ;



select salary_retriver(11356, 'MAX');

select salary_retriver(11356, 'MIN');

select salary_retriver(11356, 'diff');

/*
Exercise 11:
	Retrive a count of all employees that have been hired every year
*/

Select
	YEAR(hire_date) as year_of_hiring,
    count(emp_no) as number_of_employees
from employees 
group by YEAR(hire_date)
order by year_of_hiring;






