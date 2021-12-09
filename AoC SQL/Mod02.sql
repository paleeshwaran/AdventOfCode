
/* Prerequisite before you start other modules */

-- Create a temp table to load the data
-- I have used BULK Insert, but you may use the import function as well and load the data in temp table
-- I have also added Identity so the records can be identified sequentially in the order of load

if OBJECT_ID('pi-dwh.dbo.SubNav') is not null drop table SubNav
go

create table dbo.SubNav
(
 RowID int identity,
 NavigationCode varchar(20),
 DistanceNumber Int
 )

----Option 1
----TRUNCATE TABLE [dbo].SubNav
----BULK INSERT [dbo].SubNav
----FROM 'C:\Users\XXXX\Documents\AoC2021\AoCDay2Input'
----WITH ( FIRSTROW=1, FORMAT='txt');

----Option 2
-- For Import file using Tasks the if the file is loaded as two different columns then Merge them using the following command from Temp table before loading
truncate table dbo.SubNav
INSERT INTO dbo.SubNav (NavigationCode, DistanceNumber)
	SELECT 
			Convert(varchar(20), Column1), Convert(int, Column2) 
		FROM dbo.AoCDay2Input

-- Puzzle 1
if OBJECT_ID('tempdb..#temp1') is not null drop table #temp1
go

select NavigationCode, sum(DistanceNumber) DistanceNumber
	into #temp1
	from 
	(
		select a.Rowid
		, case when NavigationCode = 'up' or NavigationCode = 'down' Then 'depth' else  NavigationCode end NavigationCode 
		, case when NavigationCode = 'up' then DistanceNumber * - 1 else DistanceNumber end as DistanceNumber 
		from SubNav a
	) a
Group by NavigationCode 

select MAX(DistanceNumber * Prev_value) as FinalDistance
from (
	select NavigationCode
			, DistanceNumber
			, lag(DistanceNumber,1,0) over ( order by NavigationCode) as prev_value  
	from #temp1
	) a

-- Puzzle 2
if OBJECT_ID('tempdb..#temp2') is not null drop table #temp2
go

select 
	Rowid
	, NavigationCode 
	, case when NavigationCode = 'up' then DistanceNumber * - 1 else DistanceNumber end as DistanceNumber 
into #temp2
from SubNav 

declare @vDepthFactor int = 0
		,@vRunningDepth int = 0
		,@vHorizontalPos int = 0
		,@vTotalDepth int = 0

--cusrsor variables
declare  @vRowID Int
		,@vNavigationCode Varchar(20)
		,@vDistanceNumber int
		,@vAim	int
		

declare c1 cursor for 
	select  a.RowID
			, a.NavigationCode
			, a.DistanceNumber
			,case when b.NavigationCode = 'down' or b.NavigationCode = 'up' then sum(b.DistanceNumber) over (order by b.RowID) else 0 end as Aim
		from #temp2 a
		left join #temp2 b on a.RowID = b.RowID and b.NavigationCode in ('down','up')
		order by 1

	open c1
	fetch c1 into @vRowId, @vNavigationCode, @vDistanceNumber, @vAim
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		IF @vRowID > 1
		BEGIN
			if @vNavigationCode = 'forward' 
			begin
				set @vHorizontalPos = @vHorizontalPos + @vDistanceNumber
				set @vRunningDepth = @vDistanceNumber * @vDepthFactor
				set @vTotalDepth = @vTotalDepth + @vRunningDepth 
			end
			if @vNavigationCode = 'down' or @vNavigationCode = 'up'
				set @vDepthFactor = @vDistanceNumber + @vDepthFactor
		END
		ELSE
			set @vHorizontalPos = @vDistanceNumber 
		print @vDepthFactor
		print @vRunningDepth 
		print @vHorizontalPos
		print ' '
		fetch c1 into @vRowId, @vNavigationCode, @vDistanceNumber, @vAim
	END
	set @vTotalDepth = @vHorizontalPos * @vTotalDepth
	close c1
	deallocate c1
	select @vDepthFactor as vDepthFactor 
		,@vRunningDepth as vRunningDepth
		,@vHorizontalPos as vHorizontalPos
		,@vTotalDepth as PuzzleAnswer

	select top 20 a.RowID
			, a.NavigationCode
			, a.DistanceNumber
			,case when b.NavigationCode = 'down' or b.NavigationCode = 'up' then sum(b.DistanceNumber) over (order by b.RowID) else 0 end as Aim
		from #temp2 a
		left join #temp2 b on a.RowID = b.RowID and b.NavigationCode in ('down','up')
		order by 1


--SELECT RowID
--	, NavigationCode
--	, DistanceNumber
--	, Aim, ISNULL(Lag(Aim) OVER (order by RowID),0) as PrevAim
--	, case when Aim = 0 then ISNULL(lag(AiM) OVER (order by RowID),0) else aim end as AimFactor
--FROM #temp2 

drop table dbo.AoCDay2Input
drop table dbo.SubNav
drop table #temp1
drop table #temp2
