-- 1

SELECT *
FROM "Employee"
;

-- 2

SELECT "FirstName", "LastName", "State"
FROM "Employee"
WHERE "City" = 'Calgary'
;

-- 3

SELECT "Name", "Milliseconds", "Bytes"
FROM "Track"
WHERE "Milliseconds" > '500000'
;

-- 4

SELECT *
FROM "Invoice"
WHERE "BillingCountry" = 'Germany' or "BillingCountry" = 'Italy' or "BillingCountry" = 'France'
ORDER by "BillingCity"
;

-- 4 Mas elegante
SELECT *
FROM "Invoice"
WHERE "BillingCountry" in ('Germany','Italy','France')
ORDER by "BillingCity"
;

-- 5

SELECT T."Name", T."AlbumId", T."Composer", G."Name" genre
FROM "Track" T
	INNER JOIN "Genre" G
		ON T."GenreId" = G."GenreId"
;

-- 6

SELECT T."Name", T."AlbumId", T."Composer", G."Name" genre, M."Name"
FROM "Track" T
	JOIN "MediaType" M
		ON M."MediaTypeId" = T."MediaTypeId"
	JOIN "Genre" G
		ON T."GenreId" = G."GenreId"
;

-- 7

SELECT COUNT(*), G."Name" genre
FROM "Genre" G
	LEFT JOIN "Track" T
    	ON T."GenreId" = G."GenreId"
GROUP BY genre
;

-- 8

SELECT COUNT(*), G."Name" genre
FROM "Genre" G
	LEFT JOIN "Track" T
    	ON T."GenreId" = G."GenreId"
GROUP BY genre
ORDER BY COUNT(*) DESC
;

-- 9

SELECT Art."Name"
FROM "Artist" Art
WHERE Art."ArtistId" NOT IN (
  SELECT DISTINCT Alb."ArtistId" FROM "Album" Alb
)
;

-- 9 version 2

SELECT Art."Name"
FROM "Artist" Art
LEFT JOIN "Album" Alb
ON Art."ArtistId" = Alb."ArtistId"
WHERE Alb."ArtistId" IS NULL
;

-- 10

SELECT A."Name", COUNT(*)
FROM "Artist" A
	JOIN "Album" Al
    	ON A."ArtistId" = Al."ArtistId"
    JOIN "Track" T
    	ON Al."AlbumId" = T."AlbumId"
WHERE A."Name" LIKE 'M%'
GROUP BY A."Name"
HAVING COUNT(*) > 25
ORDER BY COUNT(*) DESC
;


-- 11 En pdf clase

-- 12

SELECT *
FROM "Track" T
WHERE T."AlbumId" = (
  SELECT A."AlbumId" FROM "Album" A WHERE A."Title" = 'Led Zeppelin I'
	)
;

-- 13

SELECT T."Name" track
FROM "Track" T
WHERE T."Name" IN ( SELECT A."Title" FROM "Album" A)
;
