
use Linkedin_Practice


select * 
from dbo.staff s
where s.region_id in (1,5,7) 
order by salary desc, region_id asc


select Avg(salary) as Avg_Salary, job_title
from staff
where   job_title like '%tuary' -- and Avg_Salary > 60000
group by job_title
having Avg(salary) > 60000
-- where job_title like "VP*"
order by Avg_Salary Desc

select salary, job_title
from staff
group by job_title, salary
having avg(salary) > 99000 and job_title = 'Actuary'
-- where job_title like "VP*"
order by Avg_Salary Desc

------------------------Bbbbbbbbbbbbbbbbbbbb>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
select * from staff

-- B1
SELECT gender, count(*)
FROM staff
GROUP BY gender

-- B2
SELECT department, count(*)
FROM staff
GROUP BY department


-- B3 > Max salary and job title
SELECT MAX(salary), job_title
FROM staff
where salary =(select max(salary) from staff) -- job_title like '%Sales'
group by job_title 
having salary = (select max(salary) from staff)

-- B4 >  Top 3 salary
SELECT Top 10 (salary), job_title
FROM staff
order by salary desc


-- B5 >  Select the 4th and 5th  highest salary
select Top 2 salary, job_title
from (SELECT Top 5 (salary), job_title
		FROM staff
		order by salary desc) as Top3
order by salary asc

------------------------ Stats
-- B6 >  Salary paid in all company across years

select sum(salary) TTL, year(start_date) as Yr
FROM staff
group by year(start_date)
order by TTL desc

-- B7 >  total and avg salary paid by dept over all
SELECT Department, sum(salary) Ttl_Salary, Avg(salary) as Avg_Salary , VAR(salary), STDEV(salary)
FROM staff
GROUP BY department


--- B8 >   avg slary by deprt where dept = tools and salary > 100000
SELECT job_title, AVG(salary) as Avg_Sal
FROM staff
WHERE job_title like 'S%'  -- AND 		AVG(salary) > 100000 aggregte measures work use HAVING
GROUP BY job_title
HAVING AVG(salary) > 100000
ORDER BY Avg_Sal desc

-- B9 > concatenate Job title and Department
SELECT job_title + ' - ' + department
FROM staff

-- B10 > add new colum to output boolean for example!!!!!!! Could not get it
SELECT job_title ,salary
FROM staff

--- B11 > subsstring
SELECT SUBSTRING('asdbffjfn1234',1,3) as New

SELECT substring(job_title, 10,len(job_title))
FROM staff
WHERE job_title like 'Assistant%'



SELECT Replace(job_title, 'Assistant', 'Asst.')
FROM staff
WHERE job_title like 'Assistant%'


SELECT job_title
FROM staff
WHERE job_title like '%Assistant%IV' or job_title like '%Assistant%III'


SELECT upper(department), Lower(job_title), AVG(salary)
FROM staff
GROUP BY department, job_title

---------------------------- Sub quesries

SELECT AVG(salary), department from staff group by department

-- Show employee salary and Deartment avg salary >>>> sub query in SELECT clause
SELECT s.last_name, s.salary, s.department, 
	(SELECT AVG(salary) from staff where department = s.department  group by department)
FROM staff s

-- avg salary of departments for executives. Executive individual income (>100000)
-- >>>> sub query in FROM clause
SELECT department, AVG(salary)
FROM 	(SELECT department, salary
			FROM staff
			WHERE salary > 100000) as exectv
GROUP BY department

-- Max salary 
-- >>>> sub query in WHERE clause
SELECT s1.department, s1.last_name, s1.salary
FROM staff s1
WHERE s1.salary = (SELECT max(salary) FROM staff s2)


SELECT Top 1 department, last_name, salary
FROM staff
ORDER BY salary desc

--- >>>>>>>>>>.. Joining tables
-- show company division of respective emplyees with department names
select * from company_divisions

SELECT s.last_name, s.department, cd.company_division
FROM staff s
JOIN company_divisions cd ON s.department = cd.department

--find which depatment have null 

SELECT s.last_name, s.department, cd.company_division
FROM staff s
LEFT JOIN company_divisions cd 
ON s.department = cd.department where company_division is null


--- Multiple joins and view
CREATE VIEW Staff_div_reg AS
			(SELECT s.*, CD.company_division, CR.company_regions
			FROM staff S LEFT JOIN company_divisions CD ON s.department = CD.department
						LEFT JOIN company_regions CR ON CR.region_id = S.region_id)
			--order by company_division asc)

drop view Staff_div_reg
select * from Staff_div_reg

SELECT company_division, company_regions, gender,  count(*)
FROM Staff_div_reg
GROUP BY GROUPING SETS(company_division, company_regions, gender)

----- ROLL and CUBE

	-- -- combine data as view 
	ALTER VIEW staff_div_reg_cntry AS  -- CREATE VIEW >> only then use ALTER , atleast once Create should be executed before altering
		(SELECT s.*, cd.company_division, cr.company_regions, cr.country
		FROM staff s LEFT JOIN company_divisions cd ON cd.department = s.department
					LEFT JOIN company_regions cr ON cr.region_id = s.region_id)

	
	SELECT country, company_regions, count(*)
	FROM staff_div_reg_cntry
	GROUP BY rollup (country, company_regions)
	
	SELECT company_regions, country, count(*)
	FROM staff_div_reg_cntry
	GROUP BY CUBE (company_regions, country)
	
-- ------ >>>>>>> FETCH FIRST, check for use cases could not process
select * from staff_div_reg_cntry

SELECT Top 5 company_division , COUNT(*)
FROM staff_div_reg_cntry
GROUP BY company_division
ORDER BY count(*) DESC

	-- >>>>>>>>>>>.PARTITION
	SELECT department, last_name, salary,  AVG(salary) OVER (PARTITION BY department) as vvvv 
	FROM staff

	-- avg  minimum salary in the regions
	SELECT company_regions, last_name, salary, min(salary) OVER (PARTITION BY company_regions_ -- order by last_name desc)
	FROM staff_div_reg_cntry

	-- >> FIRST_VALUE
	SELECT DEPARTMENT, last_name, salary, FIRST_VALUE(salary) OVER (PARTITION BY department order by last_name )
	FROM staff_div_reg_cntry

	------ >>>>>>>>>>>>>>>>> RANK

	SELECT department, last_name, salary, 
			RANK() OVER (PARTITION BY department ORDER BY salary DESC)
	FROM staff_div_reg_cntry


	-------- >>>>>>>>>> LAG AND LEAD (processes previous and next values of the table in combination with partition)
	SELECT department, last_name, salary, 
			lag(salary) OVER (PARTITION BY department ORDER BY salary DESC)
	FROM staff_div_reg_cntry

	SELECT department, last_name, salary, 
			LEAD(salary) OVER (PARTITION BY department ORDER BY salary DESC)
	FROM staff_div_reg_cntry


	select department, AVG(salary)
	from staff
	group by department

	----- >>>>>>>>>>>>> FUNCTIONS
	select  *
	from company_regions
	

	CREATE FUNCTION cnty_full (@country as varchar(20))
	RETURNS varchar(30)
	AS
	BEGIN
		Declare @fullname varchar(30)
		SELECT @fullname = (CASE @country WHEN 'USA' THEN 'United States of America'
										  WHEN 'Canada' THEN 'CANADA'
										  else 'other'
										  END)
		RETURN @fullname
	END

	select dbo.[cnty_full]('USA')
	SELECT *, dbo.[cnty_full](country) as FullCountry
	FROM [dbo].[staff_div_reg_cntry] t


	---------- >>>>>>>>>>>>>>>>>> Stored Procedures

	CREATE PROCEDURE EmployeeDetails_lstname (@last_name varchar(20))
	AS
		SELECT * FROM [dbo].[staff_div_reg_cntry] t
		WHERE t.last_name = @last_name


	EXEC EmployeeDetails_lstname 'Kelley'
	
	EXEC EmployeeDetails_lstname 'Carr'

