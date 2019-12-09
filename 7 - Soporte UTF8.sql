/*
 Enrique Catal? Ba?uls

 Web:         http://www.solidq.com
 Blog:        http://blogs.solidq.com/es/
              http://www.enriquecatala.com 
 Microsoft Data Platform MVP:  
              https://mvp.microsoft.com/es-es/PublicProfile/5000312?fullName=Enrique%20Catala 
 Twitter:     http://twitter.com/enriquecatala 
*/

-- Por fín UTF8 :)
--
SELECT 'a' COLLATE Latin1_General_100_CI_AS_SC_UTF8;


SELECT col.[name],
       COLLATIONPROPERTY(col.[name], 'CodePage') AS [CodePage],
       COLLATIONPROPERTY(col.[name], 'Version') AS [Version]
FROM   sys.fn_helpcollations() col
WHERE  col.[name] LIKE N'%[_]UTF8'
ORDER BY col.[name];
-- 1552 rows, all with CodePage = 65001

/*
5507 total Collations in SQL Server 2019, which is 1552 more than the 3955 that exist in SQL Server 2017
*/

-- El soporte UTF8 llega con su propia variación de collate,
-- tenlo en cuenta
SELECT 
	NCHAR(27581), -- 殽
	CONVERT(VARCHAR(3), NCHAR(27581) COLLATE Latin1_General_100_CI_AS_SC), -- ?
	CONVERT(VARCHAR(3), NCHAR(27581) COLLATE Latin1_General_100_CI_AS_SC_UTF8); -- 殽



USE tempdb
GO

DECLARE @t TABLE (t VARCHAR(10) COLLATE Latin1_General_100_CI_AI_SC_UTF8);
INSERT @t(t) VALUES(CONVERT(NVARCHAR(10),0x3DD8A9DC));
SELECT t FROM @t;
GO -- 2

DECLARE @x TABLE
(
	A NVARCHAR(200) COLLATE Latin1_General_100_CI_AI,
	B NVARCHAR(200) COLLATE Latin1_General_100_CI_AI_SC,
	C NVARCHAR(200) COLLATE Latin1_General_100_CI_AI_SC_UTF8
);

INSERT @x(A,B,C) 
VALUES (CONVERT(nvarchar(10),0x3DD8A9DC) + N'🇨🇦 and ASCII chars',
CONVERT(nvarchar(10),0x3DD8A9DC) +N'🇨🇦 and ASCII chars',
CONVERT(nvarchar(10),0x3DD8A9DC) +N'🇨🇦 and ASCII chars')

SELECT a, LEN(A) LenA, DATALENGTH(a) DataLengthA,
B, LEN(b) LenB, DATALENGTH(B) DataLengthB,
C, LEN(C) LenC, DATALENGTH(C) DataLengthC
FROM @x

SELECT 
	NCHAR(27581), -- 殽
	CONVERT(VARCHAR(3), NCHAR(27581) COLLATE Latin1_General_100_CI_AS_SC), -- ?
	CONVERT(VARCHAR(200), CONVERT(NVARCHAR(10),0x3DD8A9DC) COLLATE Latin1_General_100_CI_AS_SC_UTF8); -- 殽


DECLARE @t TABLE (t varchar(10) COLLATE Latin1_General_100_CI_AI_SC_UTF8);
INSERT @t(t) VALUES(0x3DD8A9DC),(CONVERT(nvarchar(10),0x3DD8A9DC));
SELECT t FROM @t;
GO -- 3