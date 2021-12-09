
/* Prerequisite before you start other modules */

-- Create a temp table to load the data
-- I have used BULK Insert, but you may use the import function as well and load the data in temp table
-- I have also added Identity so the records can be identified sequentially in the order of load

--if OBJECT_ID('pi-dwh.dbo.SeaDepth') is not null drop table SeaDepth
--go

--create table dbo.SeaDepth
--(
-- Rowid int identity,
-- seadepth int
-- )

--TRUNCATE TABLE [dbo].SeaDepth
--BULK INSERT [dbo].SeaDepth
--FROM 'C:\Users\XXXX\Documents\AoC2021\AdventCodeDay1Input'
--WITH ( FIRSTROW=1, FORMAT='txt');

-- For Import file using Tasks the if the file is loaded as two different columns then Merge them using the following command from Temp table before loading
--INSERT INTO dbo.SeaDepth (seadepth)
--	SELECT Case when Column2 is null then 
--			Convert(Varchar,Column1) 
--		else 
--			Convert(varchar, Column1) + Convert(varchar,Column2) 
--		end AS Dep 
--	FROM dbo.AoC2021Data

-- Puzzle 1
select count(*) PuzzleAnswer from 
	(
		select a.Rowid, a.seadepth, A.seadepth - B.seadepth as diff
		from SeaDepth a
		join SeaDepth b on a.Rowid = (b.Rowid +1)
	) a
	where diff > 0


-- Puzzle 2
if OBJECT_ID('tempdb..#temp1') is not null drop table #temp1
go

select a.Rowid, a.seadepth seadepth1, b.seadepth seadepth2, c.seadepth seadepth3, A.seadepth + B.seadepth + c.seadepth as slidingtotal
		into #temp1
		from SeaDepth a
		join SeaDepth b on a.Rowid = (b.Rowid +1)
		join SeaDepth c on a.Rowid =  (c.Rowid + 2)

if OBJECT_ID('tempdb..#temp2') is not null drop table #temp2
go

select RowId
		,slidingtotal current_value
		,prev_value
		, prev_value - slidingtotal as diff
		,case when prev_value = 0 then 'FirstRow' 
				 when prev_value - slidingtotal = 0 then 'No change'
				 when prev_value - slidingtotal > 0 then 'Decreased'
				 when prev_value - slidingtotal < 0 then 'Increased'
			end as slidingnote
into #temp2
from
	(
		select RowId 
			,slidingtotal 
			,lag(slidingtotal,1,0) over ( order by RowId) as prev_value 
		from #temp1
	) a

--uncomment the where clause

select slidingnote, count(*) PuzzleAnswer from #temp2 
--where slidingnote = 'Increased'
group by slidingnote

drop table dbo.Aoc2021Data
drop table dbo.SeaDepth
drop table #temp1
drop table #temp2
