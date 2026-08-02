/*
 
--  _______         _      _            _____  _                 
-- |__   __|       | |    | |          / ____|(_)                
--    | |     __ _ | |__  | |  ___    | (___   _  ____  ___  ___ 
--    | |    / _` || '_ \ | | / _ \    \___ \ | ||_  / / _ \/ __|
--    | |   | (_| || |_) || ||  __/    ____) || | / / |  __/\__ \
--    |_|    \__,_||_.__/ |_| \___|   |_____/ |_|/___| \___||___/
 
-- Author  : Luis.Chiriff@gmail.com
-- Date    : 2018-07-28 03:15:19
-- Purpose : Lists all tables in the database and allows you to sort via int
             
*/
 

-- Declaration

Declare @Results table (Name varchar(200),DRows bigint, DResv varchar(150), DData varchar(150), DIdx varchar(150), DUnU varchar(150), FixName int, RReserved bigint, RData bigint, RIndex bigint, RUnUsed bigint, IDx int identity(1,1))
Declare @List table (Name varchar(200), IDx int identity(1,1))
Declare @Mn int, @Mx int, @Name varchar(200), @SortType int

-- Config

SET @SortType = 5
--(1 = Name ASC, 2 = Name Desc, 3 = DRows Desc, 4 = RData Desc, 5 = RReserved Desc, 6 = RIndex Desc)

-- Gather

INSERT INTO @List
	SELECT '['+Schema_Name(uid)+'].['+Name+']' FROM SYSOBJECTS WHERE XTYPE = 'U' ORDER BY NAME ASC

SET @Mx = @@ROWCOUNT
SET @Mn = 1

WHILE(@Mn <= @Mx)
	BEGIN
	
	SELECT @Name = Name FROM @List WHERE IDx = @Mn
		
	INSERT INTO @Results (Name,DRows,DResv,DData,DIdx,DUnU)
		EXEC SP_SPACEUSED @Name
		
	UPDATE @Results SET Name = @Name, FixName = 1 WHERE FixName IS NULL
		
	SET @Mn += 1
	END

UPDATE @Results SET RData = CAST(REPLACE(DData,' KB','') as bigint)*1024, RReserved = CAST(REPLACE(DResv,' KB','') as bigint)*1024, RIndex = CAST(REPLACE(DIDx,' KB','') as bigint)*1024,
RUnUsed = CAST(REPLACE(DUnU,' KB','') as bigint)*1024

-- Return Data

SELECT Name, DRows, RReserved, RData, RIndex, RUnUsed, CAST(RReserved/1024/1024.0 as Decimal(9,2)) as ReservedInMB, (CASE @SortType WHEN 1 THEN 0 WHEN 2 THEN IDX WHEN 3 THEN DRows WHEN 4 THEN RData WHEN 5 THEN RReserved WHEN 6 THEN RIndex ELSE 0 END) as SortOrder
FROM @Results ORDER BY 8 desc, 1 asc
