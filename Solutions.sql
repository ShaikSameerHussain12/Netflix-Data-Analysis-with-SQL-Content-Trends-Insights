----------------project 1------------
CREATE DATABASE PROJECT1
USE PROJECT1

SELECT *
FROM netflix

------------------------------------------------------------------------
-- 1.THE NUMBER OF MOVIES VS TV SHOWS
SELECT N.TYPE,
COUNT(N.SHOW_ID) AS TOTAL_COUNT
FROM NETFLIX AS N
GROUP BY N.TYPE

------------------------------------------------------------------------
-- 2.THE MOST COMMON RATING FOR MOVIES AND TV SHOWS
SELECT 
	TYPE,
	RATING
	FROM (
		SELECT N.type,N.rating,
		COUNT(rating) AS COUNT ,
		RANK() OVER(PARTITION BY N.TYPE ORDER BY COUNT(*) DESC) AS RANKING
		FROM netflix AS N 
		GROUP BY N.type,N.rating
		
		) T
WHERE RANKING = 1

---------------------------------------------------------------------------------
--3.ALL MOVIES RELEASED IN A SPECIFIC YEAR (EG:2020)
SELECT * 
FROM netflix AS N 
WHERE N.type = 'Movie' AND N.release_year = 2020

----------------------------------------------------------------------------------
--4.TOP 5 COUNTRIES WITH THE MOST CONTENT ON NETFLIX
SELECT TOP(5)
TRIM(value) AS COUNTRY,
COUNT(*) AS TOTAL
FROM netflix AS N 
CROSS APPLY string_split(COUNTRY,',')
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC

----------------------------------------------------------------------------------
--5 : LONGEST MOVIE 
SELECT * 
FROM netflix AS N
WHERE N.type = 'Movie'
AND N.duration = (SELECT MAX(duration) FROM netflix)

----------------------------------------------------------------------------------
--5.1 : LONGEST MOVIE AND TV SHOW DURATION 
SELECT N.type,MAX(N.duration) AS DURATION
FROM netflix AS N
GROUP BY N.type

----------------------------------------------------------------------------------
--6.CONTENT ADDED IN THE LAST FIVE YEARS 
SELECT *
FROM netflix AS N 
WHERE N.date_added >= DATEADD(YEAR,-5,GETDATE())

----------------------------------------------------------------------------------
--7.ALL THE MOVEIS AND TV SHOWS BY THE DIRECTOR 'RAJIV CHILAKA'
SELECT *
FROM netflix AS N 
WHERE N.director LIKE '%Rajiv Chilaka%'

----------------------------------------------------------------------------------
--8.TV SHOWS WITH MORE THAN 5 SEASONS 
SELECT * ,
CAST(LEFT(N.duration,CHARINDEX(' ',N.duration) - 1) AS INT) AS SEASONS
FROM netflix AS N
WHERE N.type = 'TV Show' 
AND CAST(LEFT(N.duration,CHARINDEX(' ',N.duration) - 1) AS INT) > 5

----------------------------------------------------------------------------------
--9. NUMBER OF ITEMS IN EACH GENRE
SELECT TRIM(VALUE) AS GENRE,
COUNT(N.show_id) AS TOTAL_CONTENT
FROM netflix AS N
CROSS APPLY string_split(N.listed_in,',')
GROUP BY TRIM(VALUE)

----------------------------------------------------------------------------------
--10. THE AVERAGE CONTENT RELEASED IN INDIA ON NETFLIX IN EACH YEAR 
WITH total AS (
    SELECT COUNT(*) AS total_count
    FROM netflix
    WHERE country LIKE '%India%'
)
SELECT 
N.country,
DATETRUNC(YEAR, TRY_CONVERT(DATE, N.date_added)) AS year_added,
ROUND(COUNT(*) * 100 / T.total_count, 2) AS percentage
FROM netflix N
CROSS JOIN total T
WHERE N.country LIKE '%India%'
GROUP BY 
N.country,
DATETRUNC(YEAR, TRY_CONVERT(DATE, N.date_added)),
T.total_count
ORDER BY percentage DESC

------------------------------------------------------------------------------------
--11.ALL MOVIES THAT ARE DOCUMENTRIES 
SELECT * 
FROM netflix
WHERE TYPE = 'Movie' AND listed_in LIKE '%Documentaries%'

------------------------------------------------------------------------------------
--12.ALL THE CONTENT WITHOUT A DIRECTOR
SELECT * 
FROM netflix
WHERE director IS NULL

------------------------------------------------------------------------------------
--13.TOTAL MOVIES IN WHICH ACTOR SALMAN KHAN APPEARED IN LAST 10 YEARS
SELECT * 
FROM netflix
WHERE TYPE = 'MOVIE' AND CAST LIKE '%Salman Khan%' AND DATE_ADDED >= DATEADD(YEAR,-10,GETDATE())

------------------------------------------------------------------------------------
--14.TOP 10 ACTORS WHO HAVE APPEARED IN THE HIGHEST NUMBER OF MOVIES IN INDIA
SELECT TOP(10)
TRIM(VALUE) AS ACTOR_NAME,COUNT(show_id) AS TOTAL_MOVIES
FROM netflix
CROSS APPLY string_split(CAST,',')
WHERE TYPE = 'Movie' AND country LIKE '%India%'
GROUP BY TRIM(VALUE)
ORDER BY COUNT(show_id) DESC 

------------------------------------------------------------------------------------
/*15.CATEGORIZE THE CONTENT BASED ON THE PRESENCE OF THE KEYWORDS 'KILL' AND 'VIOLENCE' 
BASED ON THE DESCRIPTION FIELD. LABEL CONTENT CONTAINING THESE KEYWORDS AS 'BAD' AND ALL
OTHER CONTENT AS 'GOOD'. COUNT HOW MANY ITEMS FALL IN EACH CATEGORY.
*/
WITH TABLE1 AS (
SELECT *,
CASE 
	WHEN description LIKE '%Violence%' OR description LIKE '%Kill%' THEN 'Bad' 
	ELSE 'Good'
END CONTENT_TYPE
FROM netflix AS N  
)
SELECT CONTENT_TYPE,
COUNT(*) AS TOTAL_CONTENT
FROM TABLE1 
GROUP BY CONTENT_TYPE
