

select 
job_title_short AS title , 
job_location AS location , 
job_posted_date :: DATE AS date 
FROM 
job_postings_fact
LIMIT 15 ;



select 
job_title_short AS title , 
job_location AS location , 
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date 
FROM 
job_postings_fact
LIMIT 5 ;

select 
job_title_short AS title , 
job_location AS location , 
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
Extract (MONTH FROM job_posted_date ) AS date_month
Extract (YEAR FROM job_posted_date ) AS date_year
FROM 
job_postings_fact
LIMIT 5 ;

select 
job_title_short AS title , 
job_location AS location , 
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
Extract (YEAR FROM job_posted_date ) AS date_year
FROM 
job_postings_fact
LIMIT 5 ;

"JOB POSTING TRENDING FROM MONTH TO MONTH "

Select 
        COUNT(job_id) , 
        EXTRACT (MONTH from job_posted_date) AS month 
From 
        job_postings_fact
GROUP BY 
        month  ; 

Select 
        COUNT(job_id) AS job_posted_count , 
        EXTRACT (MONTH from job_posted_date) AS month 
From 
        job_postings_fact
WHERE 
        job_title_short = 'Data Analyst'
GROUP BY 
        month 
ORDER BY 
        job_posted_count DESC ; 


"PRCATISE QUESTION"

"Write a query to find average salary both yearly (salary_year_avg ) 
and hourly (salary _hour_avg) fopr job posting that were posted after june 1 , 2023 .
 group  the result by job Schedule type "

SELECT 
    job_schedule_type, 
     AVG(salary_year_avg)AS yearly, 
     AVG(salary_hour_avg) AS hourly
FROM job_postings_fact
WHERE job_posted_date :: DATE > '2023-06-01'
GROUP BY job_schedule_type;


"PRACTISE PROBLEM 6 "

" Create table from other tables 
Create three tables - jan 2023 jobs 
- feb 2023 jobs 
-mar 2023 jobs"

Create table january_jobs AS 
   SELECT *  
   from job_postings_fact
   where Extract(month From job_posted_date) = 1 ;

CREATE TABLE february_jobs AS 
   SELECT * FROM job_postings_fact
   WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS 
   SELECT * FROM job_postings_fact
   WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

Select * from february_jobs ;


"CASE EXPRESSION"
SELECT 
      job_location,
      job_title_short
      CASE
          when job_location = "Anywhere" then "Remote"
          when job_location = "New York , NY" then "Local"
          Else "Onsite"
          END AS location_category
 FROM job_postings_fact;


"Sub Queries and CTE (Common Table Expression)"

select * 
From (
        select * 
        from job_postings_fact
        where Extract(month from job_posted_date) = 1
) AS january_jobs; 


with january_jobs As (
        select * 
        from job_postings_fact 
        where Extract (month from job_posted_date)=1
)
select * from january_jobs;


"company id and company name which allows no degree "

Select company_id,  name  AS company_name
from company_dim 
where company_id IN (
        select company_id 
        from job_postings_fact 
        where job_no_degree_mention = TRUE 
        order by company_id)


"companies with the most job openings"

with company_job_count AS
(
select company_id ,count(*) As total_jobs
from job_postings_fact
group by company_id
)
select company_dim.name ,  company_job_count.total_jobs
from company_dim
left join company_job_count on company_job_count.company_id = company_dim. company_id
order by total_jobs DESC

"Practise Problem "
"Identifying the top 5 skills that are most frequently mentioned in job postings"

select * 
from(
        select count(*) as skill_count,skill_id
        from skills_job_dim
        group by skill_id
) as sc
select skills_dim.skills , sc.skill_count
from skills_dim
join sc on sc.skill.id = skills.skill_id
order by sc.skill_count DESC
LIMIT 5 ;

SELECT skills_dim.skills, sc.skill_count
FROM (
    SELECT skill_id, COUNT(*) AS skill_count
    FROM skills_job_dim
    GROUP BY skill_id
) AS sc
JOIN skills_dim s ON sc.skill_id = s.skill_id
ORDER BY sc.skill_count DESC
LIMIT 5;


"Determine the size category ('Small', 'Medium', 'Large') for each company."

SELECT company_id, job_count,
       CASE 
           WHEN job_count < 10 THEN 'Small'
           WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
           ELSE 'Large'
       END AS company_size
FROM (
    SELECT company_id, COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY company_id
) job_counts;


"Practise Problem 7 "
"find the count of the number of remote jobs posting per skill 
 - display the top 5 skill by their demand in remote jobs
 - include skill id , name , and count of postings require the skill "


with remote_job_skills as (
select 
       skill_id,
       count(*) as skill_count
from skills_job_dim as skills_to_job
inner join job_postings_fact as job_postings on job_postings.job_id = skills_to_job.job_id 
where 
      job_postings.job_work_from_home = TRUE
group by  skill_id
)

select 
       skills.skill_id,
       skills As skill_name,
       skill_count
from remote_job_skills
inner join skills_dim as skills on skills.skill_id = remote_job_skills.skill_id
order by skill_count DESC
limit 5 ;


"Union Operator"

Select 
       job_title_short,
       company_id,
       job_location
From 
        january_jobs

UNION

Select 
       job_title_short,
       company_id,
       job_location
From 
        february_jobs
        
Union 

Select 
       job_title_short,
       company_id,
       job_location
From 
        march_jobs

"Union All"

Select 
       job_title_short,
       company_id,
       job_location
From 
        january_jobs

UNION All

Select 
       job_title_short,
       company_id,
       job_location
From 
        february_jobs
        
Union All

Select 
       job_title_short,
       company_id,
       job_location
From 
        march_jobs



"Practise Problem 8"

"Find job postings from the first quarter that have a salary greater than $70k 
 - Combine job postings tables from the First quarter 2023 (Jan-Mar)
 - Gets job Postings with an average yearly salary > $70,000 "

select quarter1_job_postings.job_title_short,
       quarter1_job_postings.job_location,
       quarter1_job_postings.job_via,
       quarter1_job_postings.job_posted_date :: DATE,
       quarter1_job_postings.salary_year_avg
 from (
select *
from january_jobs
union all
select * from february_jobs
union All
select * from march_jobs
) As quarter1_job_postings
where  quarter1_job_postings.salary_year_avg > 70000  AND 
       quarter1_job_postings.job_title_short = 'Data Analyst'
order by quarter1_job_postings.salary_year_avg ASC ;