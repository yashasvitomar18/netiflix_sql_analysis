--Netflix Project

CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),	
	title VARCHAR(150),	
	director VARCHAR(230),	
	casts VARCHAR(1000),	
	country VARCHAR(150),	
	date_added VARCHAR(50),	
	release_year INT,	
	rating VARCHAR(10),
	duration VARCHAR(15),	
	listed_in VARCHAR(100),	
	description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT 
   COUNT(*) as total_content 
FROM netflix;

SELECT 
    DISTINCT TYPE
FROM netflix;

--Count number of movies and TV shows
SELECT 
    type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type

--Find the most common rating for movies and TV shows
SELECT
   type,
   rating
FROM (SELECT
   type,
   rating, --using this we get proper results
   COUNt(*),
   RANK() OVER(PARTITION BY type ORDER BY COUNT(*)) as ranking 
FROM netflix
GROUP BY 1,2
ORDER BY 1,3 DESC --for top type ratings
) as t1
WHERE 
   ranking = 1

--List all movies released in a specific year   

SELECT * FROM netflix
WHERE 
    type = 'Movie'
	AND
	release_year = 2020
	

--Top 5  countries with the most content on netflix
SELECT 
    UNNEST(STRING_TO_ARRAY(country , ',')) new_country,
	COUNT(*) total_content
FROM netflix
GROUP BY 1

SELECT 
   UNNEST(STRING_TO_ARRAY(country , ',')) new_country
FROM netflix	 

--Identify largest movie
SELECT * FROM netflix
WHERE
     type = 'Movie'
	 AND
	 duration = (SELECT MAX(duration)FROM netflix)

--Find the content added in last 5 years

SELECT 
      *
FROM netflix
WHERE
     TO_DATE(date_added, 'MONTH , DD , YYY')>= CURRENT_DATE - INTERVAL '5 years'
SELECT CURRENT_DATE - INTERVAL '5 years'

--Find all movies and TV shows by director 'Rajiv Chilaka'

SELECT * FROM netflix 
WHERE director LIKE '%Rajiv Chilaka%' --so that if multiple director present it will still appear

--List all TV shows with more than 5 seasons

SELECT 
      *
	  --SPLIT_PART(duration ,' ',1) as sessions --to get the 1st part
FROM netflix
WHERE
     type = 'TV Show'
	 AND
     SPLIT_PART(duration ,' ',1):: numeric> 5; 

--Count the number of content items in each genre

SELECT 
	 UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre, --multiple rows
	 COUNT(show_id)
FROM netflix
GROUP BY 1

--Find each year and the avg number of content release by Indians on netflix.Return top 5 years with highest avg content released
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS total_content,
	ROUND(
    COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM netflix
         WHERE country = 'India') 
		 )AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 1;

--Select all movies that are documentaries
SELECT * FROM netflix
WHERE 
listed_in LIKE '%Documentaries%'

--Find all content without director
SELECT * FROM netflix
WHERE
    director is NULL

--How many movies does 'salman khan' appears in last 15 years	
SELECT * FROM netflix
WHERE
   casts ILIKE '%Salman Khan%'
   AND
   release_year >EXTRACT(YEAR FROM CURRENT_DATE) - 15

--Find 10 actors who has appeared in the highest number of movies produced in India

SELECT 
--show_id,
--casts,
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIkE '%India%'
GROUP BY 1
ORDER BY 2 DESC

--Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other as 'Good'. Count how many items fall into each category
WITH new_table
AS(
SELECT 
*, 
CASE
WHEN
    description ILIKE '%kill%'
	OR
	description ILIKE '%violence%' THEN 'Bad_Content'
	ELSE 'Good_Content'
END category
FROM netflix
) 

SELECT category,
COUNT (*) AS total_content
FROM new_table
GROUP BY 1

WHERE
    description ILIKE '%kill%'
	OR
	description ILIKE '%violence%'