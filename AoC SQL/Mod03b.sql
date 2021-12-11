
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

-- Puzzle 2
--cusrsor variables
declare  @vRowID Int
		,@vBinaryCode Varchar(50)
		,@vBinaryCodeLength Int

-- other variables
declare	 @vOxyGen Varchar(50) = ''
		,@vCO2scrub Varchar(50) = ''
		,@vOxyGenDec	Int
		,@vCO2scrubDec Int
		,@vcount int
		,@vCountOne Int = 0
		,@vCountZero Int = 0
		,@vDisposition Int = 0
		,@vMaxSize Int = 0 
		,@vFilterBit Int = 0 

-- Temp Table
Declare @tEligibleRow table (EligRowID Int, EligBinaryCode Varchar(50) )

set @vCount = 0
select @vMaxSize = max(LEN(BinaryCode)) from SubDiagnostics

Insert into @tEligibleRow  (EligRowID, EligBinaryCode) select * from SubDiagnostics

WHILE @vcount < @vMaxSize 
BEGIN
	select @vCountZero = Count(*) from @tEligibleRow where LEFT(RIGHT(EligBinaryCode, @vMaxSize - @vcount), 1) = 0 
	select @vCountOne = Count(*) from @tEligibleRow where LEFT(RIGHT(EligBinaryCode, @vMaxSize - @vcount), 1) = 1

	if @vCountZero > @vCountOne
		set @vFilterBit = 0
	else 
		set @vFilterBit = 1
	set @vOxyGen = @vOxyGen + CONVERT(varchar, @vFilterBit)
	
	--delete the ones not required for next OxyGen calculation
	if @vFilterBit = 1
		DELETE FROM @tEligibleRow where LEFT(RIGHT(EligBinaryCode, @vMaxSize - @vcount), 1) = 0
	else
		DELETE FROM @tEligibleRow where LEFT(RIGHT(EligBinaryCode, @vMaxSize - @vcount), 1) = 1
   set @vcount = @vcount + 1
END

	;WITH N(V) AS 
		(
		  SELECT
			ROW_NUMBER()over(ORDER BY (SELECT 1))
		  FROM
			(VALUES(1),(1),(1),(1))M(a),
			(VALUES(1),(1),(1),(1))L(a),
			(VALUES(1),(1),(1),(1))K(a)
		)
		SELECT @vOxyGenDec = SUM(SUBSTRING(REVERSE(@vOxyGen),V,1)*POWER(CAST(2 as BIGINT), V-1))
		FROM   N
		WHERE  V <= LEN(@vOxyGen)

select @vOxyGenDec, @vOxyGen

set @vCount = 0
select @vMaxSize = max(LEN(BinaryCode)) from SubDiagnostics

Insert into @tEligibleRow  (EligRowID, EligBinaryCode) select * from SubDiagnostics

WHILE @vcount < @vMaxSize 
BEGIN
	select @vCountZero = Count(*) from @tEligibleRow where LEFT(RIGHT(EligBinaryCode, @vMaxSize - @vcount), 1) = 0 
	select @vCountOne = Count(*) from @tEligibleRow where LEFT(RIGHT(EligBinaryCode, @vMaxSize - @vcount), 1) = 1

	if @vCountZero <= @vCountOne
		set @vFilterBit = 0
	else 
		set @vFilterBit = 1
		
	set @vCO2scrub = @vCO2scrub + CONVERT(varchar, @vFilterBit)
	
	--delete the ones not required for next OxyGen calculation
	if @vFilterBit = 1
		DELETE FROM @tEligibleRow where LEFT(RIGHT(EligBinaryCode, @vMaxSize - @vcount), 1) = 0
	else
		DELETE FROM @tEligibleRow where LEFT(RIGHT(EligBinaryCode, @vMaxSize - @vcount), 1) = 1
   
	if (select count(*) from @tEligibleRow) = 1
	begin
		select @vCO2scrub = EligBinaryCode from @tEligibleRow
		set @vcount = 12
	end
	else
		set @vcount = @vcount + 1
END

	;WITH N(V) AS 
		(
		  SELECT
			ROW_NUMBER()over(ORDER BY (SELECT 1))
		  FROM
			(VALUES(1),(1),(1),(1))M(a),
			(VALUES(1),(1),(1),(1))L(a),
			(VALUES(1),(1),(1),(1))K(a)
		)
		SELECT @vCO2scrubDec = SUM(SUBSTRING(REVERSE(@vCO2scrub),V,1)*POWER(CAST(2 as BIGINT), V-1))
		FROM   N
		WHERE  V <= LEN(@vCO2scrub)

	select @vCO2scrubDec, @vCO2scrub

	select @vOxyGenDec * @vCO2scrubDec as PuzzleAnswer


drop table dbo.AoCDay3Input
drop table dbo.SubDiagnostics