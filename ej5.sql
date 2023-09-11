-- Ejercicio 5

-- a) Obtener los nombres y apellidos de los empleados con código postal “T5K 2N1”.

SELECT E."FirstName", E."LastName"
FROM "Employee" E
WHERE "PostalCode" = 'T5K 2N1'
;

-- b) Listar los nombres de los álbumes con canciones de género “Rock”.

SELECT DISTINCT Al."Title"
FROM "Album" Al
	JOIN "Track" T
		ON T."AlbumId" = Al."AlbumId"
	WHERE T."GenreId" IN (SELECT G."GenreId" FROM "Genre" G WHERE G."Name" = 'Rock')
;

-- c) Indicar cuantos álbumes tiene cada PlayList.
-- Debe devolver id y nombre de la PlayList y cantidad de álbumes,
-- ordenados de mayor a menor según cantidad de álbumes.

SELECT P."PlaylistId", P."Name", COUNT(*)
FROM "Playlist" P
JOIN "PlaylistTrack" PT
ON PT."PlaylistId" = P."PlaylistId"
JOIN "Track" T
ON T."TrackId" = PT."TrackId"
JOIN "Album" A
ON A."AlbumId" = T."AlbumId"
GROUP BY P."PlaylistId", P."Name"
ORDER bY COUNT(*) DESC
;

-- d) Obtener los nombres de las PlayList que tienen
-- más de 10 tracks de álbumes de "Iron Maiden".

SELECT DISTINCT P."Name", COUNT(*)
FROM "Playlist" P
JOIN "PlaylistTrack" PT ON P."PlaylistId" = PT."PlaylistId"
JOIN "Track" T ON T."TrackId" = PT."TrackId"
JOIN "Album" Al ON Al."AlbumId" = T."AlbumId"
JOIN "Artist" A ON A."ArtistId" = Al."ArtistId"
WHERE A."Name" = 'Iron Maiden'
GROUP BY P."Name"
HAVING COUNT(*) > 10
;

-- e) Listar los nombres de los empleados (Employee)
-- mayores de 25 años que tienen al menos una factura (Invoice)
-- con más de 10 ítems.

SELECT E."FirstName", E."LastName"
FROM "Employee" E
JOIN "Customer" C ON C."SupportRepId" = E."EmployeeId"
JOIn "Invoice" I ON C."CustomerId" = I."CustomerId"
JOIN (
  SELECT IL."InvoiceId", COUNT(*) items FROM "InvoiceLine" IL GROUP BY IL."InvoiceId" HAVING COUNT(*) > 10
) IL ON IL."InvoiceId" = I."InvoiceId"
WHERE EXTRACT('YEAR' FROM AGE(E."BirthDate")) > 25
GROUP BY E."FirstName", E."LastName"
;


-- f) Listar los nombres de los empleados que soportan clientes con menos de 7 facturas.

WITH CLIENTES_MENOS_DE_7_FACTURAS AS (
  SELECT I."CustomerId", COUNT(*) FROM "Invoice" I GROUP BY I."CustomerId" HAVING COUNT(*) < 7
)

SELECT E."FirstName", E."LastName"
FROM "Employee" E
JOIN "Customer" C ON C."SupportRepId" = E."EmployeeId"
WHERE C."CustomerId" IN ( SELECT C7."CustomerId" FROM CLIENTES_MENOS_DE_7_FACTURAS C7 )
GROUP BY E."FirstName", E."LastName"
;

-- g) Listar los empleados junto a su jefe.
-- Las tuplas resultantes tendrán la siguiente forma:
-- (nombre empleado (FirstName), apellido de empleado (LastName),
-- nombre jefe, apellido de jefe).

SELECT E."FirstName", E."LastName", J."FirstName", J."LastName"
FROM "Employee" E
JOIN "Employee" J ON J."EmployeeId" = E."ReportsTo"
;

-- h) Resolver el ítem anterior pero que no falte ningún empleado en el listado.

SELECT E."FirstName", E."LastName", J."FirstName", J."LastName"
FROM "Employee" E
LEFT JOIN "Employee" J ON J."EmployeeId" = E."ReportsTo"
;

-- i) Obtener, para cada cliente,
-- el promedio de tracks comprados en sus facturas.
-- Es decir, si en una factura compro 8 tracks y en otra 4 el promedio es 6.



SELECT C."FirstName", C."LastName", AVG(IL."Quantity")
FROM "Customer" C
JOIN "Invoice" I ON C."CustomerId" = I."CustomerId"
JOIN "InvoiceLine" IL ON IL."InvoiceId" = I."InvoiceId"
GROUP BY C."FirstName", C."LastName"
;

-- j) Obtener para cada empleado el total de tracks del género "Rock"
-- comprados por los clientes a quienes da soporte.

SELECT E."FirstName", E."LastName", COUNT(*)
FROM "Employee" E
JOIN "Customer" C ON C."SupportRepId" = E."EmployeeId"
JOIN "Invoice" I ON I."CustomerId" = C."CustomerId"
JOIN "InvoiceLine" IL ON IL."InvoiceId" = I."InvoiceId"
JOIN "Track" T ON T."TrackId" = IL."TrackId"
JOIN "Genre" G ON G."GenreId" = T."GenreId"
WHERE G."Name" = 'Rock'
GROUP BY E."FirstName", E."LastName"
;

-- k) Obtener los nombres de los clientes que tengan la factura (invoice)
-- con el ítem (invoiceline) de mayor cantidad

WITH cant_por_track AS (
  SELECT "TrackId", COUNT(*) FROM "InvoiceLine" GROUP BY "TrackId"
)

SELECT C."FirstName", C."LastName"
FROM "Customer" C
JOIN "Invoice" I ON I."CustomerId" = C."CustomerId"
JOIN "InvoiceLine" IL ON IL."InvoiceId" = I."InvoiceId"
WHERE IL."InvoiceId" IN (
  SELECT cpt."TrackId" FROM cant_por_track cpt
  GROUP BY cpt."TrackId", COUNT
  HAVING COUNT = (SELECT MAX(COUNT) FROM cant_por_track)
)
GROUP BY C."FirstName", C."LastName"
;

-- l) Obtener los álbumes que tiene al menos un track en TODAS las PlayLists.
-- este no esta bien...

SELECT DISTINCT Al."AlbumId", Al."Title"
FROM "Album" Al
JOIN "Track" T ON Al."AlbumId" = T."AlbumId"
JOIN "PlaylistTrack" PT ON T."TrackId" = PT."TrackId"
JOIN "Playlist" P ON PT."PlaylistId" = P."PlaylistId"
WHERE Al."AlbumId" IN (
    SELECT DISTINCT "Album"."AlbumId"
    FROM "Album"
    INNER JOIN "Track" ON "Album"."AlbumId" = "Track"."AlbumId"
    INNER JOIN "PlaylistTrack" ON "Track"."TrackId" = "PlaylistTrack"."TrackId"
    GROUP BY "Album"."AlbumId"
    HAVING COUNT(DISTINCT "PlaylistTrack"."PlaylistId") = (
        SELECT COUNT(DISTINCT "PlaylistId") FROM "Playlist" 
      )
  )
;

-- m) Obtener los artistas que tienen más álbumes en PlayList


SELECT Ar."Name", COUNT(A."AlbumId") cant_albums
FROM "Artist" Ar
JOIN "Album" A ON A."ArtistId" = Ar."ArtistId"
JOIN "Track" T ON T."AlbumId" = A."AlbumId"
GROUP BY Ar."Name"
ORDER BY cant_albums DESC
;


-- n) Obtener los playlist que no contengan ningún track de
-- los álbumes de los artistas “Black Sabbath” o “Chico Buarque”

SELECT DISTINCT P."PlaylistId", P."Name"
FROM "Playlist" P
JOIN "PlaylistTrack" PT ON PT."PlaylistId" = P."PlaylistId"
JOIN "Track" T ON T."TrackId" = PT."TrackId"
JOIN "Album" A ON A."AlbumId" = T."AlbumId"
WHERE T."AlbumId" NOT IN (
  SELECT A."AlbumId" FROM "Album" A
  JOIN "Artist" Ar ON Ar."ArtistId" = A."ArtistId"
  WHERE Ar."Name" IN ('Black Sabbath','Chico Buarque')
)
;

-- o) Obtener los clientes que compraron tracks de un único género

SELECT C."CustomerId", C."FirstName", C."LastName", generos_cliente.cant_gen
FROM "Customer" C
JOIN ( SELECT I."CustomerId", COUNT( DISTINCT T."GenreId" ) cant_gen FROM "Invoice" I
	   JOIN "InvoiceLine" IL ON IL."InvoiceId" = I."InvoiceId"
	   JOIN "Track" T ON T."TrackId" = IL."TrackId"
       GROUP BY I."CustomerId"
     ) AS generos_cliente ON C."CustomerId" = generos_cliente."CustomerId"
--WHERE generos_cliente.cant_gen = 1
-- No hay gente que haya comprado tracks de un unico genero
;







