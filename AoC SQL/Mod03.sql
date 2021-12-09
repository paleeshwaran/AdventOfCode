
/* Prerequisite before you start other modules */

-- Create a temp table to load the data
-- I have used BULK Insert, but you may use the import function as well and load the data in temp table
-- I have also added Identity so the records can be identified sequentially in the order of load

if OBJECT_ID('pi-dwh.dbo.SubDiagnostics') is not null drop table SubDiagnostics
go

create table dbo.SubDiagnostics
(
 RowID int identity,
 BinaryCode nvarchar(50),
 )

----Option 1
----TRUNCATE TABLE [dbo].SubDiagnostics
----BULK INSERT [dbo].SubDiagnostics
----FROM 'C:\Users\XXXX\Documents\AoC2021\AoCDay3Input'
----WITH ( FIRSTROW=1, FORMAT='txt');

----Option 2
-- For Import file using Tasks the if the file is loaded as two different columns then Merge them using the following command from Temp table before loading
truncate table dbo.SubDiagnostics
INSERT INTO dbo.SubDiagnostics (BinaryCode)
	SELECT 
			Convert(varchar(50), Column1) 
		FROM dbo.AoCDay3Input

-- Puzzle 1
--cusrsor variables
declare  @vRowID Int
		,@vBinaryCode Varchar(50)
		,@vBinaryCodeLength Int

-- other variables
declare	 @vCountZero Int = 0
		,@vCountOne Int = 0
		,@vGammaRate Varchar(50) = ''
		,@vEpsilonRate Varchar(50) = ''
		,@vGamaRateDec	Int
		,@vEpsilonRateDec Int
		,@vcount int

declare c1 cursor for 
	select  top 3 RowID
			, BinaryCode
			, LEN(BinaryCode) BinaryCodeLength
		from SubDiagnostics 
		order by RowID

	open c1
	fetch c1 into @vRowId, @vBinaryCode, @vBinaryCodeLength
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		set @vcount = 0
		set @vCountZero = 0 
		set @vCountOne = 0
		while @vcount < @vBinaryCodeLength
		BEGIN
			if LEFT(RIGHT(@vBinaryCode, @vBinaryCodeLength - @vcount), 1) = '0'
				set @vCountZero = @vCountZero + 1 
			else
				set @vCountOne = @vCountOne + 1 

			set @vcount = @vcount + 1
		END
		if @vCountZero > @vCountOne
		begin
			set @vGammaRate = @vGammaRate + '0'
			set @vEpsilonRate = @vEpsilonRate + '1'
		end
		else 
		begin
			set @vGammaRate = @vGammaRate + '1'
			set @vEpsilonRate = @vEpsilonRate + '0'
		end

		fetch c1 into @vRowId, @vBinaryCode, @vBinaryCodeLength
	END
	close c1
	deallocate c1
	select @vGammaRate as GammaRate, @vEpsilonRate  as EpsilonRate
	select  top 3 RowID
			, BinaryCode
			, LEN(BinaryCode) BinaryCodeLength
		from SubDiagnostics 
		order by RowID

drop table dbo.AoCDay3Input
drop table dbo.SubDiagnostics
