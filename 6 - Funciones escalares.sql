/*
 Enrique Catal? Ba?uls

 Web:         http://www.solidq.com
 Blog:        http://blogs.solidq.com/es/
              http://www.enriquecatala.com 
 Microsoft Data Platform MVP:  
              https://mvp.microsoft.com/es-es/PublicProfile/5000312?fullName=Enrique%20Catala 
 Twitter:     http://twitter.com/enriquecatala 
*/
use dbTest
GO

if (object_id('dbo.TablaGrande') is not null)
    drop table dbo.TablaGrande
go

-- Creamos una tablita con 100k filas
--
with
    t0 as (select n = 1 union all select n = 1),
    t1 as (select n = 1 from t0 as a, t0 as b),
    t2 as (select n = 1 from t1 as a, t1 as b),
    t3 as (select n = 1 from t2 as a, t2 as b),
    t4 as (select n = 1 from t3 as a, t3 as b),
    t5 as (select n = 1 from t4 as a, t4 as b),
    result as (select row_number() over (order by n) as n from t5)	
select n col1 ,n+1 col2
into dbo.TablaGrande
from result where n <= 1000000

-- Le creo 2 ?ndices, por hacer algo, realmente tampoco es 
-- imprescindible
create clustered index ci_tablagrande on TablaGrande(col1 asc)
create nonclustered index nci2_tablaGrande on TablaGrande(col2 asc)

-- Creamos una funci?n tonta para ilustrar que incluso la cosa
-- mas increiblemente tonta produce resultados desastrosos
--
if (object_id('dbo.ChorraFuncion') is not null)
    drop function dbo.ChorraFuncion
go
create function dbo.ChorraFuncion( @a int,@b int)
returns varchar(100)
begin
return cast((@a+@b) as varchar(100))
end
go
-- ponemos en marcha la salida de tiempos
--
set statistics time on

-- Para no hacer trampas, borramos cualquier p?gina ?til 
-- para que sean ejecuciones v?rgenes
dbcc dropcleanbuffers
go

-- Desactivamos la feature (como si fuera version inferior a SQL 2019)
--   Por defecto es ON
--
ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF;
go
-- Usando la funci?n, aqui vemos los tiempos en mi m?quina:
-- 
-- SQL Server Execution Times:
--  CPU time = 5444 ms,  elapsed time = 6229 ms.
--

select max(dbo.ChorraFuncion(t1.col1,t2.col2))
from TablaGrande t1
    inner join TablaGrande t2 on t1.col1 = t2.col2
go


-- Expandiendo la funci?n (sin llamarla, pero haciendo lo mismo 
-- que hace), vemos como los tiempos son radicalmente mejores
-- SQL Server Execution Times:
--  CPU time = 3711 ms,  elapsed time = 1118 ms.
--
select max(cast((t1.col1 + t2.col2) as varchar(1000)))
from TablaGrande t1
    inner join TablaGrande t2 on t1.col1 = t2.col2
go


--
-- Truco: LA SOLUCI?N PASA POR CREAR LA FUNCION COMO FUNCION INLINE PERO DEVOLVIENDO UNA SELECT
--
create function dbo.ChorraFuncion_mejorada( @a int,@b int)
returns table
as
return select cast((@a+@b) as varchar(100)) as concatenado
go

-- 
-- El motor de SQL ahora si expande correctamente el c?digo. Si se revisa el plan de ejecuci?n y usos, es equivalente a la soluci?n inline manual.
-- 
select MAX(dd.concatenado)
from TablaGrande t1
    inner join TablaGrande t2 on t1.col1 = t2.col2
    cross apply dbo.ChorraFuncion_mejorada(t1.col1,t2.col2) dd
GO


-- Pero ahora veamos qué pasa en SQL Server 2019 por defecto...
-- 
ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = ON;
GO
DBCC DROPCLEANBUFFERS
GO
select max(dbo.ChorraFuncion(t1.col1,t2.col2))
from TablaGrande t1
    inner join TablaGrande t2 on t1.col1 = t2.col2
go
