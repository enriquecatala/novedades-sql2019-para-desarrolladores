

USE  dbTest;
go


-- Creamos tabla empleado
CREATE TABLE EMP
	(EMPNO INT NOT NULL,
	ENAME VARCHAR(20),
	JOB VARCHAR(10),
	MGR INT,
	JOINDATE DATETIME,
	SALARY DECIMAL(7, 2),
	COMMISIION DECIMAL(7, 2),
	DNO INT)
 
INSERT INTO EMP VALUES 
(7369, 'SMITH', 'CLERK', 7902, '02-MAR-1970', 8000, NULL, 2),
(7499, 'ALLEN', 'SALESMAN', 7698, '20-MAR-1971', 1600, 3000, 3),
(7521, 'WARD', 'SALESMAN', 7698, '07-FEB-1983', 1250, 5000, 3),
(7566, 'JONES', 'MANAGER', 7839, '02-JUN-1961', 2975, 50000, 2),
(7654, 'MARTIN', 'SALESMAN', 7698, '28-FEB-1971', 1250, 14000, 3),
(7698, 'BLAKE', 'MANAGER', 7839, '01-JAN-1988', 2850, 12000, 3),
(7782, 'CLARK', 'MANAGER', 7839, '09-APR-1971', 2450, 13000, 1),
(7788, 'SCOTT', 'ANALYST', 7566, '09-DEC-1982', 3000, 1200, 2),
(7839, 'KING', 'PRESIDENT', NULL, '17-JUL-1971', 5000, 1456, 1),
(7844, 'TURNER', 'SALESMAN', 7698, '08-AUG-1971', 1500, 0, 3),
(7876, 'ADAMS', 'CLERK', 7788, '12-MAR-1973', 1100, 0, 2),
(7900, 'JAMES', 'CLERK', 7698, '03-NOV-1971', 950, 0, 3),
(7902, 'FORD', 'ANALYST', 7566, '04-MAR-1961', 3000, 0, 2),
(7934, 'MILLER', 'CLERK', 7782, '21-JAN-1972', 1300, 0, 1)



-- En formato tabla representamos la relaci�n 'ReportsTo' de la siguiente forma
select empno, ename,mgr from emp

-- Y ahora con grafos
-- Definimos el nodo Empleado y la rellenamos con datos de la tabla creada anteriormente
CREATE TABLE dbo.EmpNode(
	ID Int Identity(1,1),
	EMPNO NUMERIC(4) NOT NULL,
	ENAME VARCHAR(10),
	MGR NUMERIC(4),
	DNO INT
	) AS NODE;

INSERT INTO EmpNode(EMPNO,ENAME,MGR,DNO) 
select empno,ename,MGR,dno from emp

select * from EmpNode

-- Creamos la arista que representa la relaci�n 'ReportsTo'
CREATE TABLE empReportsTo(Deptno int) AS EDGE 
select * from empReportsTo

-- Cargamos las relaciones en el grafo
-- Opci�n 1
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 1), 
       (SELECT $node_id FROM EmpNode WHERE id = 13),20);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 2), 
       (SELECT $node_id FROM EmpNode WHERE id = 6),10);
	   INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 3), 
       (SELECT $node_id FROM EmpNode WHERE id = 6),10)
   INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 4), 
       (SELECT $node_id FROM EmpNode WHERE id = 9),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 5), 
       (SELECT $node_id FROM EmpNode WHERE id = 6),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 6), 
       (SELECT $node_id FROM EmpNode WHERE id = 9),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 7), 
       (SELECT $node_id FROM EmpNode WHERE id = 9),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 8), 
       (SELECT $node_id FROM EmpNode WHERE id = 4),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 9), 
       (SELECT $node_id FROM EmpNode WHERE id = 9),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 10), 
       (SELECT $node_id FROM EmpNode WHERE id = 6),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 11), 
       (SELECT $node_id FROM EmpNode WHERE id = 8),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 12), 
       (SELECT $node_id FROM EmpNode WHERE id = 6),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 13), 
       (SELECT $node_id FROM EmpNode WHERE id = 4),30);
INSERT INTO empReportsTo  VALUES ((SELECT $node_id FROM EmpNode WHERE ID = 14), 
       (SELECT $node_id FROM EmpNode WHERE id = 7),30);

 -- Opci�n 2
INSERT INTO empReportsTo 
SELECT e.$node_id, m.$node_id ,e.dno
FROM dbo.EmpNode e 
	inner JOIN dbo.EmpNode m ON e.empno = m.mgr;


-- Revisamos estructuras en sys.table
SELECT t.is_edge,t.is_node,*
FROM sys.tables t
WHERE name like 'emp%'

-- Consultando el grafo
-- Consulta primer nivel en la jerarqu�a
SELECT E.EMPNO,E.ENAME,E.MGR,E1.EMPNO,E1.ENAME,E1.MGR
FROM empnode e, empnode e1, empReportsTo m 
WHERE MATCH(e-(m)->e1)
	and e.ENAME='SMITH'

-- Consulta segundo nivel en la jerarqu�a
SELECT E.EMPNO,E.ENAME,E.MGR,E1.EMPNO,E1.ENAME,E1.MGR,E2.EMPNO,e2.ENAME,E2.MGR
FROM     empnode e, empnode e1, empReportsTo m ,empReportsTo m1, empnode e2
WHERE MATCH(e-(m)->e1-(m1)->e2)
	and e.ENAME='SMITH'

-- Consulta tercer nivel en la jerarqu�a
SELECT E.EMPNO,E.ENAME,E.MGR,E1.EMPNO,E1.ENAME,E1.MGR,E2.EMPNO,e2.ENAME,E2.MGR,E3.EMPNO,e3.ENAME,E3.MGR
FROM empnode e, empnode e1, empReportsTo m ,empReportsTo m1, empnode e2, empReportsTo M2, empnode e3
WHERE MATCH(e-(m)->e1-(m1)->e2-(m2)->e3)
  and e.ENAME='SMITH'

 -- Consulta descendente
 SELECT E.EMPNO,E.ENAME,E.MGR,E1.EMPNO,E1.ENAME,E1.MGR,E2.EMPNO,e2.ENAME,E2.MGR,E3.EMPNO,e3.ENAME,E3.MGR
FROM empnode e, empnode e1, empReportsTo m ,empReportsTo m1, empnode e2, empReportsTo M2, empnode e3
WHERE  MATCH(e<-(m)-e1<-(m1)-e2<-(m2)-e3)
	and e3.ename = 'SMITH'
GO

-- Constraints en Aristas
-- Modo compatibilidad 2017 no permite constraints
Use dbtest
Go


-- Creamos nodo adminitradores
DROP TABLE IF EXISTS administrator
CREATE TABLE administrator (ID INTEGER PRIMARY KEY, administratorName VARCHAR(100)) AS NODE;
INSERT INTO administrator
VALUES (1,'allompart')
Go
SELECT * FROM administrator


CREATE TABLE Users2 (ID INTEGER PRIMARY KEY, UserName VARCHAR(100)) AS NODE;
INSERT INTO Users2
VALUES (1,'UsuarioAdministrado')
Go
SELECT * FROM Users2


-- Autorizo a allompart a administrar los privilegios de usuarioAdministrado
DROP TABLE IF EXISTS [Authorization]
CREATE TABLE [Authorization]  AS EDGE
Go
 
INSERT INTO [Authorization] ($from_id ,$to_id )
VALUES (
(SELECT $node_id from administrator where ID=1)
,(SELECT $node_id from Users2 where ID=1))
select * from [Authorization]

-- Incluyo un segundo usuario 
INSERT INTO Users2
VALUES (2,'UsuarioAdministrado2')
Go


INSERT INTO [Authorization] ($from_id ,$to_id )
VALUES (
(SELECT $node_id from Users2 where ID=2),
(SELECT $node_id from administrator where ID=1))
select * from [Authorization]


-- Definici�n de constraint de arista
--
DROP TABLE IF EXISTS [Authorization]
CREATE TABLE [Authorization] 
(
	CONSTRAINT EC_Authorization Connection (Administrator TO Users2)
) As Edge
Go

INSERT INTO [Authorization] ($from_id ,$to_id )
VALUES (
   (SELECT $node_id from administrator where ID=1)
   ,(SELECT $node_id from Users2 where ID=1)
)
select * from [Authorization]


INSERT INTO Users2
VALUES (3,'UsuarioAdministrado3')
Go
 
-- esta es la novedad en 2019 :)
--
INSERT INTO [Authorization] ($from_id ,$to_id )
VALUES (
(SELECT $node_id from users2 where ID=3)
,(SELECT $node_id from administrator where ID=1)
)


CREATE TABLE UserGroups
(
	ID INTEGER PRIMARY KEY,
   [UserGroupName] NVARCHAR(100) NOT NULL,
   ) AS NODE
GO
INSERT INTO UserGroups
VALUES (1,'ReadUserGroup')
Go


Create table [Permissions] as edge


INSERT INTO [Authorization] ($from_id ,$to_id )
VALUES (
(SELECT $node_id from usergroups where ID=1)
,(SELECT $node_id from users2 where ID=1)
)


ALTER TABLE [Authorization] ADD CONSTRAINT  EC_Connection1_Authorization Connection 
(
   Administrator TO Users2,
   UserGroups TO Users2
)
GO

ALTER TABLE [Authorization] DROP CONSTRAINT EC_Authorization 
GO


INSERT INTO Users2
VALUES (4,'UsuarioAdministrado4')
Go

INSERT INTO [Authorization] ($from_id ,$to_id )
VALUES (
(SELECT $node_id from users2 where ID=2)
,(SELECT $node_id from administrator where ID=1)
)

INSERT INTO [Authorization] ($from_id ,$to_id )
VALUES (
(SELECT $node_id from UserGroups where ID=1)
, (SELECT $node_id from users2 where ID=1)
)


INSERT INTO [Authorization] ($from_id ,$to_id )
VALUES (
(SELECT $node_id from users2 where ID=1),
(SELECT $node_id from UserGroups where ID=1)
 
)



-------------------------------
-- Demo Borrado de registros --
-------------------------------

select * from [Authorization]
select * from [Administrator]
select * from [users2]

delete from users2 where id=1


-----------
-- Consulta Vistas del sistema --
----------------

SELECT
       EC.name AS edge_constraint_name
     , OBJECT_NAME(EC.parent_object_id) AS [edge table]
     , OBJECT_NAME(ECC.from_object_id) AS [From Node table]
     , OBJECT_NAME(ECC.to_object_id) AS [To Node table],
	 EC.type_desc,
     EC.create_date 
  FROM sys.edge_constraints EC
 INNER JOIN sys.edge_constraint_clauses ECC
    ON EC.object_id = ECC.object_id
 WHERE ECC.from_object_id = object_id('administrator')



 ----
 -- Uso de Vistas
 ---- 
 -- Nodos heterog�neos
 -- En 2017
DROP TABLE IF EXISTS dbo.Follows;
DROP TABLE IF EXISTS dbo.Person;
DROP TABLE IF EXISTS dbo.Business;
DROP TABLE IF EXISTS dbo.Company;

CREATE TABLE dbo.Person(
	PersonID BIGINT NOT NULL PRIMARY KEY CLUSTERED,
	FULLNAME NVARCHAR(250) NOT NULL ) AS NODE;

CREATE TABLE dbo.Business(
	BusinessID BIGINT NOT NULL  PRIMARY KEY CLUSTERED,
	BusinessName NVARCHAR(250) NOT NULL UNIQUE ) AS NODE;

CREATE TABLE dbo.Company(
	CompanyID BIGINT NOT NULL  PRIMARY KEY CLUSTERED,
	CompanyName NVARCHAR(250) NOT NULL UNIQUE ) AS NODE;

CREATE TABLE dbo.Follows(
	Since DATETIME2 NULL,
        -- CONSTRAINT EDG_Person_Follows CONNECTION (Person TO Company, Business TO Company)
)
AS EDGE;

INSERT INTO dbo.Person
	VALUES (1,'John Doe'), (2,'Andres Martins');

INSERT INTO dbo.Business
	VALUES (1,'Foody Company'), (2,'Dressing Inc.');

INSERT INTO dbo.Company
	VALUES (1,'Creative Value Company'), (2,'Real Stuff');


INSERT INTO dbo.Follows
	SELECT	p1.$node_id as from_obj_id,
			(SELECT p2.$node_id as to_obj_id FROM dbo.Company p2 WHERE p2.CompanyID = 1),
			GETDATE()
		FROM dbo.Person p1
		WHERE p1.PersonID = 1


INSERT INTO dbo.Follows
	SELECT	p1.$node_id as from_obj_id,
			bus.to_obj_id,
			GETDATE()
		FROM dbo.Business p1
		CROSS APPLY (SELECT p2.$node_id as to_obj_id FROM dbo.Company p2 WHERE p2.CompanyID = 2) as bus


CREATE VIEW dbo.Followers AS 
	SELECT PersonId as Id, FullName
		FROM dbo.Person
	UNION ALL
	SELECT BusinessId, BusinessName
		FROM dbo.Business;

SELECT Followers.ID, Followers.FullName
	FROM Followers, Follows, Company
	WHERE MATCH(Followers-(Follows)->Company)
		AND CompanyName = 'Real Stuff'

-- En 2019


DROP TABLE IF EXISTS dbo.Follows;
DROP TABLE IF EXISTS dbo.Person;
DROP TABLE IF EXISTS dbo.Business;
DROP TABLE IF EXISTS dbo.Company;

CREATE TABLE dbo.Person(
	PersonID BIGINT NOT NULL PRIMARY KEY CLUSTERED,
	FULLNAME NVARCHAR(250) NOT NULL ) AS NODE;

CREATE TABLE dbo.Business(
	BusinessID BIGINT NOT NULL  PRIMARY KEY CLUSTERED,
	BusinessName NVARCHAR(250) NOT NULL UNIQUE ) AS NODE;

CREATE TABLE dbo.Company(
	CompanyID BIGINT NOT NULL  PRIMARY KEY CLUSTERED,
	CompanyName NVARCHAR(250) NOT NULL UNIQUE ) AS NODE;

CREATE TABLE dbo.Follows(
	Since DATETIME2 NULL,
        CONSTRAINT EDG_Person_Follows CONNECTION (Person TO Company, Business TO Company)
)
AS EDGE;

INSERT INTO dbo.Person
	VALUES (1,'John Doe'), (2,'Andres Martins');

INSERT INTO dbo.Business
	VALUES (1,'Foody Company'), (2,'Dressing Inc.');

INSERT INTO dbo.Company
	VALUES (1,'Creative Value Company'), (2,'Real Stuff');


INSERT INTO dbo.Follows
	SELECT	p1.$node_id as from_obj_id,
			(SELECT p2.$node_id as to_obj_id FROM dbo.Company p2 WHERE p2.CompanyID = 1),
			GETDATE()
		FROM dbo.Person p1
		WHERE p1.PersonID = 1


INSERT INTO dbo.Follows
	SELECT	p1.$node_id as from_obj_id,
			bus.to_obj_id,
			GETDATE()
		FROM dbo.Business p1
		CROSS APPLY (SELECT p2.$node_id as to_obj_id FROM dbo.Company p2 WHERE p2.CompanyID = 2) as bus


CREATE VIEW dbo.Followers AS 
	SELECT PersonId as Id, FullName
		FROM dbo.Person
	UNION ALL
	SELECT BusinessId, BusinessName
		FROM dbo.Business;

SELECT Followers.ID, Followers.FullName
	FROM Followers, Follows, Company
	WHERE MATCH(Followers-(Follows)->Company)
		AND CompanyName = 'Real Stuff'


-- Aristas heterogeneas
-- En 2017
DROP TABLE IF EXISTS dbo.Likes;
DROP TABLE IF EXISTS dbo.WorksFor;
DROP TABLE IF EXISTS dbo.Person;
DROP TABLE IF EXISTS dbo.Company;

CREATE TABLE dbo.Person(
	PersonID BIGINT NOT NULL PRIMARY KEY CLUSTERED,
	FULLNAME NVARCHAR(250) NOT NULL ) AS NODE;

CREATE TABLE dbo.Company(
	CompanyID BIGINT NOT NULL  PRIMARY KEY CLUSTERED,
	CompanyName NVARCHAR(250) NOT NULL UNIQUE ) AS NODE;

CREATE TABLE dbo.Likes(
	Since DATETIME2 NOT NULL,
--     CONSTRAINT EDG_Person_Likes CONNECTION (Person TO Company)
)
AS EDGE;

CREATE TABLE dbo.WorksFor(
	Since DATETIME2 NOT NULL,
--    CONSTRAINT EDG_Person_WorksFor CONNECTION (Person TO Company)
)
AS EDGE;

INSERT INTO dbo.Person
	VALUES (1,'John Doe'), (2,'Andres Martins');

INSERT INTO dbo.Company
	VALUES (1,'Creative Value Company'), (2,'Real Stuff');


INSERT INTO dbo.Likes
	SELECT	p1.$node_id as from_obj_id,
			(SELECT p2.$node_id as to_obj_id FROM dbo.Company p2 WHERE p2.CompanyID = 2),
			GETDATE()
		FROM dbo.Person p1
		WHERE p1.PersonID = 1;


INSERT INTO dbo.WorksFor
	SELECT	p1.$node_id as from_obj_id,
			bus.to_obj_id,
			GETDATE()
		FROM dbo.Person p1
		CROSS APPLY (SELECT p2.$node_id as to_obj_id FROM dbo.Company p2 WHERE p2.CompanyID = 2) as bus;

CREATE VIEW dbo.RelatesTo AS 
	SELECT Since, 'likes' as opStatus
		FROM dbo.Likes
	UNION ALL
	SELECT Since, 'works for' as opStatus
		FROM dbo.WorksFor;

-- Consulta 2019
SELECT Person.FullName, Company.CompanyName
	FROM Person, Company, RelatesTo
	WHERE MATCH(Person-(RelatesTo)->Company)
		and RelatesTo.opStatus in ('likes','works for')
	GROUP BY Person.FullName, Company.CompanyName
	HAVING COUNT(DISTINCT RelatesTo.opStatus) = 2 

-- Consulta 2017 
set statistics io on
set statistics time on
SELECT FullName, CompanyName
	FROM
		(SELECT Person.FullName, Company.CompanyName, 'likes' as opStatus
			FROM Person, Company, Likes
			WHERE MATCH(Person-(Likes)->Company)
		UNION ALL
		SELECT Person.FullName, Company.CompanyName, 'works for' as opStatus
			FROM Person, Company, WorksFor
			WHERE MATCH(Person-(WorksFor)->Company)
		) res
	GROUP BY FullName, CompanyName
	HAVING COUNT(DISTINCT opStatus) = 2;  



