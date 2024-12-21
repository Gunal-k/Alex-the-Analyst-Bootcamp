#begin

#Select
select * from parks_and_recreation.employee_demographics;

#PEDMAS(paranthesis,exponent,division,multiplication,addition,subtraction)
select age+5
from parks_and_recreation.employee_demographics;

select (age+5)*10
from parks_and_recreation.employee_demographics;

#disntinct keyword
select distinct gender
from parks_and_recreation.employee_demographics;

#Where clause 
select first_name,age
from parks_and_recreation.employee_demographics
where age>40
;

#comparision operators(!=,=,>=,<=,>,<)
select first_name,last_name,age
from parks_and_recreation.employee_demographics
where age!=40;

#logical operators(and,or,not)
select employee_id,first_name,last_name,age
from parks_and_recreation.employee_demographics
where employee_id>4 and age<50;

#like statement(%,_)
select first_name,age
from parks_and_recreation.employee_demographics
where first_name like '__a%';

#group by (aggregate functions avg(),min(),max(),count())
select avg(age),gender,count(first_name)
from parks_and_recreation.employee_demographics
group by gender;

#order by (asc(default),desc)
select employee_id,first_name,last_name,age,gender
from parks_and_recreation.employee_demographics
where age<50
order by gender ;

select employee_id,first_name,last_name,age,gender
from parks_and_recreation.employee_demographics
where age<50
order by 1 desc;

#diff Havind and Where
select avg(age),gender,count(first_name)
from parks_and_recreation.employee_demographics
group by gender
having avg(age)>40;

#limit and aliasing
select last_name as age,gender as g,first_name as total
from parks_and_recreation.employee_demographics
limit 2,4;

#----End beginner