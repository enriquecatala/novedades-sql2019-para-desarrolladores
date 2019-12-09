-- Enrique Catal� Ba�uls 
-- SolidQ: Seminario de planes de ejecuci�n 2019
-- 
-- Web :    http://www.solidq.com
-- Blog:    http://blogs.solidq.com/es/
-- Bio :    https://mvp.microsoft.com/es-es/PublicProfile/5000312?fullName=Enrique%20Catala
--
-- Official code to show the technology https://docs.microsoft.com/en-us/sql/relational-databases/performance/intelligent-query-processing?view=sqlallproducts-allversions#table-variable-deferred-compilation
--
-- Se propagan durante tiempo de compilaci�n y optimizacion la cardinalidad basada en la tabla base utilizada
-- Puntos interesantes:
--		Se mejoran los planes de ejecucion que utilizan tablas variable al no tener un valor fijo en ellas, todo lo dem�s sigue igual:
--			- No se incrementa la frecuencia de recompilacion, como si ocurre con las tablas temporales
--			- Se almacena junto al plan de ejecuci�n, el row count que se estim� en la compilaci�n inicial
--			- ...

-- IMPORTANTE: 
--		No se a�aden estad�sticas a tablas variable (para eso sigue usando tabla temporal)
--		Si el n� de filas varia en exceso entre ejecuciones, esta caracter�stica no mejorar� rendimiento porque no recompila (usa tablas temporales!)
--

-- Evaluamos rendimiento en modo compatibilidad 140 (SQL Server 2017)
USE [master]
GO
ALTER DATABASE [StackOverflow2010] SET COMPATIBILITY_LEVEL = 140
GO


USE [StackOverflow2010]
GO
declare @VoteStats table (PostId int, up int, down int) 
 
insert @VoteStats
select
    PostId, 
    up = sum(case when VoteTypeId = 2 then 1 else 0 end), 
    down = sum(case when VoteTypeId = 3 then 1 else 0 end)
from Votes
where VoteTypeId in (2,3)
group by PostId


set statistics time on
select top 100 p.Id as [Post Link] , up, down 
from @VoteStats 
join Posts p on PostId = p.Id
where down > (up * 0.5) and p.CommunityOwnedDate is null and p.ClosedDate is null
order by up desc
GO
set statistics time off
-- HASTA AQUI------------------------------------------------
-------------------------------------------------------------

-- SQL Server Execution Times:    
--		CPU time = 9370 ms,  elapsed time = 47489 ms.
-- SQL Server parse and compile time: 
--		CPU time = 0 ms, elapsed time = 0 ms.


-- Evaluamos rendimiento en modo compatibilidad 150 (SQL Server 2019)
USE [master]
GO
ALTER DATABASE [StackOverflow2010] SET COMPATIBILITY_LEVEL = 150
GO

USE [StackOverflow2010]
GO
declare @VoteStats table (PostId int, up int, down int) 
 
insert @VoteStats
select
    PostId, 
    up = sum(case when VoteTypeId = 2 then 1 else 0 end), 
    down = sum(case when VoteTypeId = 3 then 1 else 0 end)
from Votes
where VoteTypeId in (2,3)
group by PostId


set statistics time on
select top 100 p.Id as [Post Link] , up, down 
from @VoteStats 
join Posts p on PostId = p.Id
where down > (up * 0.5) and p.CommunityOwnedDate is null and p.ClosedDate is null
order by up desc
set statistics time off
GO
-- HASTA AQUI------------------------------------------------
-------------------------------------------------------------

-- SQL Server parse and compile time: 
--	   CPU time = 5 ms, elapsed time = 5 ms.
-- SQL Server Execution Times:
--	   CPU time = 1550 ms,  elapsed time = 217 ms.


