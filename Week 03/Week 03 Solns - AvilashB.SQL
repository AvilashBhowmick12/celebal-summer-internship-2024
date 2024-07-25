-- Name : Avilash Bhowmick


-- Task 01--
WITH ProjectBoundaries AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        CASE 
            WHEN DATEDIFF(day, LAG(End_Date) OVER (ORDER BY Start_Date), Start_Date) = 1 THEN 0
            ELSE 1
        END AS IsNewProject
    FROM
        Projects
),
ProjectGroups AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        SUM(IsNewProject) OVER (ORDER BY Start_Date) AS ProjectGroup
    FROM
        ProjectBoundaries
),
ProjectDetails AS (
    SELECT
        ProjectGroup,
        MIN(Start_Date) AS Project_Start,
        MAX(End_Date) AS Project_End,
        DATEDIFF(day, MIN(Start_Date), MAX(End_Date)) + 1 AS Duration
    FROM
        ProjectGroups
    GROUP BY
        ProjectGroup
)
SELECT
    Project_Start,
    Project_End
FROM
    ProjectDetails
ORDER BY
    Duration ASC,
    Project_Start ASC;






-- Task 02  ----
with cte as (
select friend_id, salary as frnd_salary from friends f join packages p on f.friend_id=p.id)

select s.name from students s
join friends f on f.id=s.id 
join cte c on c.friend_id=f.friend_id
join packages p on p.id=s.id 
where  c.frnd_salary>p.salary
order by c.frnd_salary



--Task 03 ---------------
SELECT F1.X, F1.Y
FROM Functions F1
JOIN Functions F2 ON F1.X = F2.Y AND F1.Y = F2.X
WHERE F1.X < F1.Y
ORDER BY F1.Y;




--Task 04 ---------------

SELECT c.contest_id, c.hacker_id, c.name, 
SUM(COALESCE(s.total_submissions, 0))AS total_submissions,
SUM(COALESCE(s.total_accepted_submissions, 0)) AS total_accepted_submissions, 
SUM(COALESCE(v.total_views, 0)) AS total_views, 
SUM(COALESCE(v.total_unique_views, 0)) AS total_unique_views 

FROM contests c
JOIN colleges col ON
c.contest_id = col.contest_id 
JOIN challenges chal ON 
col.college_id = chal.college_id 
LEFT JOIN 
( SELECT challenge_id, SUM(total_submissions) AS total_submissions, SUM(total_accepted_submissions) AS total_accepted_submissions 
FROM Submission_Stats GROUP BY challenge_id ) s 
ON chal.challenge_id = s.challenge_id
LEFT JOIN 
( SELECT challenge_id, SUM(total_views) AS total_views, SUM(total_unique_views) AS total_unique_views FROM view_stats GROUP BY challenge_id ) v 
ON chal.challenge_id = v.challenge_id 

GROUP BY c.contest_id, c.hacker_id, c.name
HAVING (SUM(COALESCE(s.total_submissions, 0)) + SUM(COALESCE(s.total_accepted_submissions, 0)) + SUM(COALESCE(v.total_views, 0)) + SUM(COALESCE(v.total_unique_views, 0))) > 0

ORDER BY c.contest_id;




--Task 05  -------------------------

with t1 as
( select hacker_id, submission_date , SUM(count(distinct hacker_id)) 
OVER (PARTITION BY hacker_id ORDER BY submission_date) AS number_of_submissions_until_the_date,datediff(day, '2016-03-01', submission_date ) +1 as difference,
count( submission_id) as count_submission
from Submissions 
group by hacker_id, submission_date ), t2 as 
(
    select t1.submission_date,t1.number_of_submissions_until_the_date, t1.difference
    from t1 
    where t1.number_of_submissions_until_the_date >= t1.difference ),
    t3 as(  select t2.submission_date ,count(*) as count_hackers from t2 group by t2.submission_date ), 
    t4 as ( select t1.submission_date, t1.hacker_id , max(t1.count_submission) as max_submission, row_number() over (partition by t1.submission_date order by max(t1.count_submission)desc , t1.hacker_id asc ) as ranked_max
    from t1
   group by t1.submission_date, t1.hacker_id 
)

select t3.submission_date, t3.count_hackers, t4.hacker_id, Hackers.name
from t3 join t4 on t4.submission_date = t3.submission_date and t4.ranked_max = 1 join Hackers on t4.hacker_id = Hackers.hacker_id
group by t3.submission_date, t3.count_hackers, t4.hacker_id, Hackers.name 
order by t3.submission_date







--Task 06 ----------
SELECT
    CAST(ROUND(ABS(MAX(LAT_N) - MIN(LAT_N)) + ABS(MAX(LONG_W) - MIN(LONG_W)), 4) AS DECIMAL(10, 4)) AS manhattan_distance
FROM
    STATION;




--Task 07 -------

WITH Numbers AS (
    SELECT 2 AS num
    UNION ALL
    SELECT num + 1
    FROM Numbers
    WHERE num < 1000
),
PrimeNumbers AS (
    SELECT num
    FROM Numbers AS n1
    WHERE NOT EXISTS (
        SELECT 1
        FROM Numbers AS n2
        WHERE n2.num <= SQRT(n1.num) AND n1.num % n2.num = 0 AND n2.num > 1
    )
)
SELECT STRING_AGG(CAST(num AS VARCHAR), '&') AS primes
FROM PrimeNumbers
OPTION (MAXRECURSION 1000);








-- Task 08 --------

select [DOCTOR],[PROFESSOR],[SINGER],[ACTOR]
FROM 
(
 SELECT ROW_NUMBER()OVER(PARTITION BY OCCUPATION ORDER BY NAME)[ROWNUMBER], *FROM OCCUPATIONS
)AS AA
PIVOT
(
 MIN(NAME) FOR OCCUPATION IN ([DOCTOR],[PROFESSOR],[SINGER],[ACTOR])
)PIVOTTABLE





-- Task 09 ----------

SELECT N ,
CASE 
 
    WHEN P IS NULL
    THEN "Root" 
    WHEN N IN (SELECT P FROM BST)
    THEN "Inner"
    ELSE "Leaf"
END
  FROM BST ORDER BY N 




-- Task 10 ----------

SELECT E.COMPANY_CODE,
MAX(FOUNDER),
COUNT(DISTINCT LEAD_MANAGER_CODE),
COUNT(DISTINCT SENIOR_MANAGER_CODE),
COUNT(DISTINCT MANAGER_CODE),
COUNT(DISTINCT EMPLOYEE_CODE)
FROM EMPLOYEE E 
LEFT JOIN 
COMPANY C
ON E.COMPANY_CODE= C.COMPANY_CODE
GROUP BY  E.COMPANY_CODE
ORDER BY  E.COMPANY_CODE;



-- Task 11 ----------

with cte as (
select friend_id, salary as frnd_salary from friends f join packages p on f.friend_id=p.id)

select s.name from students s
join friends f on f.id=s.id 
join cte c on c.friend_id=f.friend_id
join packages p on p.id=s.id 
where  c.frnd_salary>p.salary
order by c.frnd_salary



-- Task 12 ----------

CREATE TABLE Job_Costs (
    Job_Family VARCHAR(100),
    Cost DECIMAL(10, 2),
    Location VARCHAR(50)
);
INSERT INTO Job_Costs (Job_Family, Cost, Location) VALUES
('Software Engineer', 50000.00, 'India'),
('Software Engineer', 75000.00, 'International'),
('Data Scientist', 60000.00, 'India'),
('Data Scientist', 90000.00, 'International'),
('Marketing Manager', 70000.00, 'India'),
('Marketing Manager', 85000.00, 'International');

SELECT
    Job_Family,
    SUM(CASE WHEN Location = 'India' THEN Cost ELSE 0 END) AS India_Cost,
    SUM(CASE WHEN Location = 'International' THEN Cost ELSE 0 END) AS International_Cost,
    CASE 
        WHEN SUM(CASE WHEN Location = 'International' THEN Cost ELSE 0 END) = 0 THEN 0
        ELSE (SUM(CASE WHEN Location = 'India' THEN Cost ELSE 0 END) * 100.0) / SUM(CASE WHEN Location = 'International' THEN Cost ELSE 0 END)
    END AS Cost_Ratio_India_to_International
FROM
    Job_Costs
GROUP BY
    Job_Family;




-- Task 13 ----
/* here i have a table  CostRevenueData with columns BU, Month, Cost, and Revenue*/

SELECT 
    BU,
    Month,
    SUM(Cost) AS Total_Cost,
    SUM(Revenue) AS Total_Revenue,
    CASE
        WHEN SUM(Revenue) = 0 THEN NULL
        ELSE SUM(Cost) / SUM(Revenue)
    END AS Cost_Revenue_Ratio
FROM 
    CostRevenueData
GROUP BY 
    BU,
    Month;



-- Task  14 ---------------
/* I  have a table named Employees with columns SubBand representing the sub band of employees. */

SELECT 
    SubBand,
    COUNT(*) AS Headcount,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS Percentage
FROM 
    Employees
GROUP BY 
    SubBand;





-- Task 15  ------


WITH RankedEmployees AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum
    FROM Employees
)
SELECT *
FROM RankedEmployees
WHERE RowNum <= 5;




-- Task 16  ------------------------------
--i already have employee table in my database with columns 


-- Before swapping
SELECT * FROM Employees;

-- Swap values of Salary and Bonus columns
UPDATE Employees
SET Salary = Salary + Bonus,
    Bonus = Salary - Bonus,
    Salary = Salary - Bonus;

-- After swapping
SELECT * FROM Employees;




-- Task  17 ---------

-- Step 1: Creating a Login
CREATE LOGIN MAD_USER
WITH PASSWORD = 'kj1234';

-- Step 2: Create a User in the AdventureWorks2019 database
USE AdventureWorks2019;
CREATE USER MY_USER FOR LOGIN MAD_USER;

-- Step 3: Provide db_owner permissions to the user
ALTER ROLE db_owner ADD MEMBER MY_USER;





-- Task 18 ----
/* there already exists the table with used columns*/

SELECT 
    BU,
    Month,
    SUM(EmployeeCount * TotalCost) / SUM(EmployeeCount) AS Weighted_Average_Cost
FROM 
    EmployeeCosts
GROUP BY 
    BU,
    Month;




-- Task 19 ---------

select ceiling(avg(salary)- avg(replace(salary, 0,''))) from employees;


-- Task  20 ------

/* choosing a table from adventure works database */

--creating table
CREATE TABLE SalesOrderHeader_Copy AS
SELECT * FROM Sales.SalesOrderHeader WHERE 1=0;

--insertig data 
INSERT INTO SalesOrderHeader_Copy
SELECT * FROM Sales.SalesOrderHeader;
