SELECT *
FROM music_genre;

-- DATA CLEANING 
-- FIRST WE CREATE A COPY OF THE ORIGINAL TABLE AND COPY ALL THE DATA IN IT. THIS IS DONE TO PRESERVE THE ORIGINAL DATA

CREATE TABLE music_genre_staging
LIKE music_genre;

INSERT INTO music_genre_staging
SELECT *
FROM music_genre;

SELECT *
FROM music_genre_staging;

-- NEXT WE CHECK FOR DUPLICATES BY USING THE ROW_NUMBER() KEYWORD
WITH CTE_1 AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY instance_id, artist_name, track_name, popularity, acousticness, danceability, duration_ms, energy, 
instrumentalness, `Key`, liveness, loudness, `mode`, speechiness, tempo, obtained_date, valence, music_genre) AS row_num
FROM music_genre_staging
)
SELECT *
FROM CTE_1
WHERE row_num > 1;

-- SINCE THERE ARE NO DUPLICATES WE CONTINUE CLEANING

SELECT * 
FROM music_genre_staging;

SELECT DISTINCT track_name
FROM music_genre_staging;

-- DATA IS FAIRLY CLEAN SO WE'LL DO A LOT MORE EXPLORATORY ANALYSIS
-- 1) TOP 5 ARTISTS
SELECT artist_name, COUNT(*)
FROM music_genre_staging
GROUP BY artist_name
ORDER BY 2 DESC
LIMIT 5;

-- 2) TOP 10 POPULAR TRACKS
SELECT track_name, popularity
FROM music_genre_staging
GROUP BY track_name, popularity
ORDER BY 2 DESC
LIMIT 10;

-- 3) PERCENTAGE OF TOP 10 DANCEABLE TRACKS
SELECT track_name, (danceability * 100) AS dance_percent
FROM music_genre_staging
GROUP BY track_name, danceability
ORDER BY 2 DESC
LIMIT 10;

-- 4) TOP 10 LONGEST TRACKS IN MINS AND SECS
SELECT track_name, (duration_ms / 60000)  AS duration
FROM music_genre_staging
GROUP BY track_name, duration_ms
ORDER BY 2 DESC
LIMIT 10;

-- 5) KEYS OF THE TOP 10 TRACKS (BY POPULARITY)
SELECT track_name, popularity, `key`
FROM music_genre_staging
GROUP BY track_name, popularity, `key`
ORDER BY 2 DESC
LIMIT 10;

-- 6) MOST USED KEYS BY TOP 5 ARTISTS
SELECT artist_name, `key`, COUNT(*)
FROM music_genre_staging
GROUP BY artist_name, `key`
ORDER BY 3 DESC
LIMIT 5;

-- 7) CLASSIFY SONGS WITH FAST AND SLOW BEATS
WITH CTE_2 AS
(
SELECT *, 
CASE
	WHEN tempo < 120.0 THEN 'Low_Tempo'
    WHEN tempo > 120.0 THEN 'Up_Tempo'
    ELSE 'Avg_Tempo'
END AS Tempo_category
FROM music_genre_staging
)
UPDATE music_genre_staging
JOIN CTE_2
	ON music_genre_staging.instance_id = CTE_2.instance_id
SET music_genre_staging.obtained_date = CTE_2.Tempo_category;

SELECT *
FROM music_genre_staging;

ALTER TABLE music_genre_staging
CHANGE COLUMN obtained_date tempo_category text;

-- 8) MOST COMMON MODE
SELECT `mode`, COUNT(*)
FROM music_genre_staging
GROUP BY `mode`
ORDER BY 2 DESC;

-- 9) MODE OF THE TOP 10 TRACKS (BY POPULARITY)
SELECT track_name, popularity, `mode`
FROM music_genre_staging
GROUP BY track_name, popularity, `mode`
ORDER BY 2 DESC
LIMIT 10;

-- 10) TEMPO CATEGORY OF THE TOP 10 TRACKS (BY POPULARITY)
SELECT track_name, popularity, tempo, tempo_category
FROM music_genre_staging
GROUP BY track_name, popularity, tempo, tempo_category
ORDER BY 2 DESC
LIMIT 10;