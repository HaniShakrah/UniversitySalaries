use school;

DROP TABLE IF EXISTS school_salary;
DROP TABLE IF EXISTS schools;

CREATE TABLE schools (
school VARCHAR(100),
conference VARCHAR(20),
primary key (school));

CREATE TABLE school_salary (
school VARCHAR(100),
region	VARCHAR(20),
starting_median DECIMAL (8,2),
mid_career_median DECIMAL (8,2),
mid_career_90 DECIMAL (8,2),
FOREIGN KEY (school) REFERENCES schools (school)
);

/*Clean for manipulation*/
UPDATE school_salary_src
SET mid_career_median = NULL
WHERE mid_career_median = "";

UPDATE school_salary_src
SET mid_career_90 = NULL
WHERE mid_career_90 = "";

INSERT INTO schools (school, conference)
SELECT *
FROM schools_src;

update school_salary_src
SET starting_median = replace(starting_median, '$', ''), mid_career_median = replace(mid_career_median, '$', ''), mid_career_90 = replace(mid_career_90, '$', '');

update school_salary_src
SET starting_median = replace(starting_median, ',', ''), mid_career_median = replace(mid_career_median, ',', ''), mid_career_90 = replace(mid_career_90, ',', '');


ALTER TABLE school_salary_src
CHANGE starting_median starting_median decimal (8,2),
CHANGE mid_career_median mid_career_median decimal (8,2),
CHANGE mid_career_90 mid_career_90 decimal (8,2);

INSERT INTO schools(school)
(SELECT school_salary_src.school
FROM school_salary_src
LEFT JOIN schools ON schools.school = school_salary_src.school
WHERE schools.school IS NULL);

INSERT INTO school_salary (school, region, starting_median, mid_career_median, mid_career_90)
SELECT *
FROM school_salary_src;


/* Information for Rutgers University */
SELECT * 
FROM school_salary
WHERE school LIKE '%Rutgers%';

/* Number of schools in the Big Ten */
SELECT COUNT(*) AS "Number of Schools"
FROM schools
WHERE conference = "Big Ten";

/* Ranking tech schools by lowest starting median salary */
SELECT *
FROM school_salary
WHERE school LIKE '%tech%'
ORDER BY starting_median DESC;

/* Display the different conferences represented in the dataset */
SELECT DISTINCT(conference)
FROM schools
WHERE conference IS NOT NULL;

/* List the Big Ten school with the highest 90th percentile mid-career salary, along with the corresponding value */
SELECT schools.school, school_salary.mid_career_90
FROM schools
JOIN school_salary ON schools.school = school_salary.school
WHERE school_salary.mid_career_90 = (SELECT max(mid_career_90)
FROM school_salary
JOIN schools ON schools.school = school_salary.school
WHERE schools.conference = "Big Ten");


/* Mid career 90th percentile salary in the Big Ten in descending order */
SELECT schools.school, starting_median, mid_career_median, mid_career_90
FROM school_salary
JOIN schools ON schools.school = school_salary.school
WHERE schools.conference = "Big Ten"
ORDER BY mid_career_90 DESC;

/* NJ school info... salary in $xxx,xxx.xx format */
SELECT school, concat('$',format(starting_median, 'C')) AS starting_median, concat('$',format(mid_career_median, 'C')) AS mid_career_median, concat('$',format(mid_career_90, 'C')) AS mid_career_90
FROM school_salary
WHERE school IN ('Fairleigh Dickinson University',
'Princeton University', 'Rider University', 'Rutgers University', 'Seton Hall University', 'Stevens
Institute of Technology')
ORDER BY school ASC;

/* Conference(s) with most schools in dataset */
DROP TABLE IF EXISTS byconference;
DROP TABLE IF EXISTS byconference2;

CREATE TEMPORARY TABLE byconference AS 
SELECT conference, count(*) as num
FROM schools
GROUP BY conference;

CREATE TEMPORARY TABLE byconference2 AS 
SELECT conference, count(*) as num
FROM schools
GROUP BY conference;

SELECT conference, num as Member_count
FROM byconference
WHERE num = (SELECT max(num) FROM byconference2 WHERE conference IS NOT NULL);





