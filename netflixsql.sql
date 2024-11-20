--Netflix Project 

drop table if exists netflix;

CREATE TABLE NETFLIX (
	SHOW_ID VARCHAR(10),
	TYPE VARCHAR(10),
	TITLE VARCHAR(150),
	DIRECTOR VARCHAR(250),
	CASTS VARCHAR(1000),
	COUNTRY VARCHAR(150),
	DATE_ADDED VARCHAR(50),
	RELEASE_YEAR INT,
	RATING VARCHAR(10),
	DURATION VARCHAR(15),
	LISTED_IN VARCHAR(250),
	DESCRIPTION VARCHAR(250)
);
select * from netflix;

select count(*) from netflix;

select distinct type from netflix;



-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows
	
SELECT
	TYPE,
	COUNT(*) AS NUM_MOVIES
FROM
	NETFLIX
GROUP BY
	TYPE;
	

--2. Find the most common rating for movies and TV shows

SELECT
	TYPE,
	RATING
FROM
	(
		SELECT
			TYPE,
			RATING,
			COUNT(*),
			RANK() OVER (
				PARTITION BY
					TYPE
				ORDER BY
					COUNT(*) DESC
			) AS RANKING
		FROM
			NETFLIX
		GROUP BY
			TYPE,
			RATING
	) AS T1
WHERE
	RANKING = 1

	

--3. List all movies released in a specific year (e.g., 2020)

SELECT
	TITLE,
	RELEASE_YEAR
FROM
	NETFLIX
WHERE
	RELEASE_YEAR = 2020
	AND TYPE = 'Movie';
	

--4. Find the top 5 countries with the most content on Netflix

SELECT
	UNNEST(STRING_TO_ARRAY(COUNTRY, ',')) AS NEW_COUNTRY,
	COUNT(*)
FROM
	NETFLIX
GROUP BY
	NEW_COUNTRY
ORDER BY
	COUNT(*) DESC
LIMIT
	5;
	

--5. Identify the longest movie

	select title,duration 
	from netflix 
	where  type='Movie' and duration=(select max(duration) from netflix) ;
	

--6. Find content added in the last 5 years

SELECT
	*
FROM
	NETFLIX
WHERE
	TO_DATE(DATE_ADDED, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 Years';


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
	
SELECT
	TITLE,
	TYPE
FROM
	NETFLIX
WHERE
	DIRECTOR ILIKE '%Rajiv Chilaka%';


--8. List all TV shows with more than 5 seasons

	SELECT
	TITLE
FROM
	NETFLIX
WHERE
	TYPE = 'TV Show'
	AND SPLIT_PART(DURATION, ' ', 1)::NUMERIC> 5;
	

--9. Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(LISTED_IN, ',')) AS GENRE,
	COUNT(*)
FROM
	NETFLIX
GROUP BY
	GENRE;	


--10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!

SELECT
	EXTRACT(
		YEAR
		FROM
			TO_DATE(DATE_ADDED, 'Month DD,YYYY')
	),
	COUNT(*),
	ROUND(
		COUNT(*)::NUMERIC / (
			SELECT
				COUNT(*)
			FROM
				NETFLIX
			WHERE
				COUNTRY = 'India'
		)::NUMERIC * 100,
		2
	) AS AVG_CONTENT_YEAR FROM
	NETFLIX
WHERE
	COUNTRY = 'India'
GROUP BY
	1;


--11. List all movies that are documentaries
	
SELECT
	TITLE,
	LISTED_IN
FROM
	NETFLIX
WHERE
	LISTED_IN LIKE '%Documentaries%';


--12. Find all content without a director


	select title from netflix where director is null;


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT
	TITLE
FROM
	NETFLIX
WHERE
	CASTS LIKE '%Salman Khan%'
	AND TYPE = 'Movie'
	AND RELEASE_YEAR > EXTRACT(
		YEAR
		FROM
			CURRENT_DATE
	) -10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
    unnest(string_to_array(Casts, ',')) AS actors,
    COUNT(*) AS appearances
FROM 
    netflix
WHERE 
    country = 'India'
GROUP BY 
    actors
ORDER BY 
    appearances DESC limit 10;


--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

WITH
	NEW_TABLE AS (
		SELECT
			*,
			CASE
				WHEN DESCRIPTION ILIKE 'kill%'
				OR DESCRIPTION ILIKE 'violence%' THEN 'bad_content'
				ELSE 'good_content'
			END CATEGORY
		FROM
			NETFLIX
	)
SELECT
	CATEGORY,
	COUNT(*) AS TOTAL_CONTENT
FROM
	NEW_TABLE
GROUP BY
	1;

