#Intermediate

#joins(Inner Join(default),left,right,self)
#inner(returns only the matched items)
select * 
from employee_demographics emp1
join employee_salary emp2
on emp1.employee_id=emp2.employee_id;

#left join(return all data of left table and only matched data of right table)
select * 
from employee_demographics as emp1
left join employee_salary as emp2
on emp1.employee_id+1=emp2.employee_id;

#right join(return all data of right table and only matched data of left table)
select * 
from employee_demographics as emp1
right join employee_salary as emp2
on emp1.employee_id=emp2.employee_id+1;

#self join(
select * 
from employee_salary as emp1
join employee_salary as emp2
on emp1.employee_id+1=emp2.employee_id;

#joining multiple tables
select emp1.employee_id,concat(emp1.first_name,' ',emp1.last_name) as namea,emp2.occupation,emp2.dept_id,pkd.department_name from
employee_demographics emp1
join employee_salary emp2 on emp1.employee_id=emp2.employee_id 
join parks_departments pkd on  emp2.dept_id=pkd.department_id;

#Unions (distinct,all, label (bonus))
select first_name,last_name from employee_demographics
union distinct
select first_name,last_name from employee_salary
;

select first_name,last_name, 'old' as label from employee_demographics where age>40
union all 
select first_name,last_name,'high salary' as salary from employee_salary where salary>50000
;

#String functions(length(),upper(),lower(),trim(),substring(),replace(),locate(),concat())
#length()
select first_name,length(first_name) as length from employee_demographics order by length;

#upper()
select first_name,upper(first_name) as length from employee_demographics order by length;

#lower()
select first_name,lower(first_name) as length from employee_demographics order by length;

#trim()(ltrim(),rtrim())
select trim('      first_name      ');
#ltrim()
select ltrim('      first_name      ');
#rtrim()
select rtrim('      first_name      ');

#substring(clmn,start,charnum),left(clmn,charnum),right(clmn,charnum)
select first_name,substring(first_name,1,2) from employee_demographics;
select first_name,left(first_name,2) from employee_demographics;
select first_name,right(first_name,2) from employee_demographics;

#replace()
select first_name,replace(first_name,'A','d') from employee_demographics;

#locate()
select first_name,locate('a',first_name) from employee_demographics order by 2;

#concat()
select first_name,last_name,concat(first_name,' ',last_name) as 'full name' from employee_demographics;

#case statements
select first_name,last_name,
case
	when age<=30 then 'young'
    when age between 30 and 50 then 'adult'
    when age>=50 then 'old'
end as agebra
from employee_demographics;

-- increase and bonus
-- <50000 = 5%
-- >50000 = 7%
-- finance = 10%
SELECT DISTINCT dem.first_name, dem.last_name,pkd.department_name,sal.salary,
case
	when salary>50000 then salary*1.07
    when salary<50000 then salary*1.05
end as hike,
case 
	when dept_id=6 then salary *.10
end as bonus
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id
join parks_departments as pkd
on sal.dept_id=pkd.department_id;

#subqueries
select * from employee_demographics where employee_id in (select employee_id 
		from employee_salary 
        where dept_id=1)
;

select first_name,salary,(select avg(salary)  from employee_salary) as 'avrage salary' from employee_salary;

select gender,max_age from 
(select gender,
avg(age) as avg_age,
max(age) as max_age,
min(age) min_age,
count(age) from employee_demographics 
group by gender) as agg_table;
 
 #window functions
SELECT gender, ROUND(AVG(salary),1)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
;

-- now let's try doing something similar with a window function

SELECT dem.employee_id, dem.first_name, gender, salary,
AVG(salary) OVER()
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

-- now we can add any columns and it works. We could get this exact same output with a subquery in the select statement, 
-- but window functions have a lot more functionality, let's take a look


-- if we use partition it's kind of like the group by except it doesn't roll up - it just partitions or breaks based on a column when doing the calculation

SELECT dem.employee_id, dem.first_name, gender, salary,
AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;


-- now if we wanted to see what the salaries were for genders we could do that by using sum, but also we could use order by to get a rolling total

SELECT dem.employee_id, dem.first_name, gender, salary,
SUM(salary) OVER(PARTITION BY gender ORDER BY employee_id)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;


-- Let's look at row_number rank and dense rank now


SELECT dem.employee_id, dem.first_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

-- let's  try ordering by salary so we can see the order of highest paid employees by gender
SELECT dem.employee_id, dem.first_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary desc)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

-- let's compare this to rank
SELECT dem.employee_id, dem.first_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary desc) row_num,
Rank() OVER(PARTITION BY gender ORDER BY salary desc) rank_1 
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

-- notice rank repeats on tom ad jerry at 5, but then skips 6 to go to 7 -- this goes based off positional rank


-- let's compare this to dense rank
SELECT dem.employee_id, dem.first_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary desc) row_num,
Rank() OVER(PARTITION BY gender ORDER BY salary desc) rank_1,
dense_rank() OVER(PARTITION BY gender ORDER BY salary desc) dense_rank_2 -- this is numerically ordered instead of positional like rank
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;