/*
Advanced SQL Puzzles
https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Advanced%20SQL%20Puzzles
*/
USE SQLPuzzles;
GO

-- Exercises 11-20


-- Puzzle #11
DROP TABLE IF EXISTS TestCases;
GO

CREATE TABLE TestCases
(
RowNumber INTEGER,
TestCase VARCHAR(1),
PRIMARY KEY (RowNumber, TestCase)
);
GO

INSERT INTO TestCases VALUES
(1,'A'),(2,'B'),(3,'C');
GO

DECLARE @count INTEGER 
SET @count = (SELECT COUNT(*) FROM TestCases);

WITH Permutations_cte (Permutation, Id, Depth)
AS
(
SELECT 
	CAST(TestCase AS VARCHAR(MAX)),
    CONCAT(CAST(RowNumber AS VARCHAR(MAX)), ';'),
    1 AS Depth
FROM TestCases
UNION ALL
SELECT  
	CONCAT(perm.Permutation, ',', cases.TestCase),
    CONCAT(perm.Id, cases.RowNumber, ';'),
    perm.Depth + 1
FROM Permutations_cte perm, TestCases cases
WHERE perm.Depth < @count AND perm.Id NOT LIKE CONCAT('%', cases.RowNumber, ';%')
)

SELECT  
	Permutation
FROM Permutations_cte
WHERE Depth = @count
ORDER BY Permutation ASC;
GO

-- End #11

-- Puzzle #12
DROP TABLE IF EXISTS ProcessLog;
GO

CREATE TABLE ProcessLog
(
WorkFlow        VARCHAR(100),
ExecutionDate   DATE,
PRIMARY KEY (WorkFlow, ExecutionDate)
);
GO

INSERT INTO ProcessLog VALUES
('Alpha','6/01/2018'),('Alpha','6/14/2018'),('Alpha','6/15/2018'),
('Bravo','6/1/2018'),('Bravo','6/2/2018'),('Bravo','6/19/2018'),
('Charlie','6/1/2018'),('Charlie','6/15/2018'),('Charlie','6/30/2018');
GO

WITH DayDiff_cte AS
(
SELECT  
	WorkFlow,
    (DATEDIFF(DAY, LAG(ExecutionDate,1,NULL) OVER (PARTITION BY WorkFlow ORDER BY ExecutionDate), ExecutionDate)) AS DiffDate
FROM ProcessLog
)
SELECT  
	WorkFlow, 
	AVG(DiffDate)
FROM DayDiff_cte
WHERE DiffDate IS NOT NULL
GROUP BY Workflow;
GO

-- End #12

	
-- Puzzle #13
DROP TABLE IF EXISTS Inventory;
GO

CREATE TABLE Inventory
(
InventoryDate       DATE PRIMARY KEY,
QuantityAdjustment  INTEGER
);
GO

INSERT INTO Inventory VALUES
('7/1/2018',100),('7/2/2018',75),('7/3/2018',-150),
('7/4/2018',50),('7/5/2018',-75);
GO

SELECT
	InventoryDate,
	QuantityAdjustment,
	SUM(QuantityAdjustment) OVER (ORDER BY InventoryDate)
FROM Inventory;
GO

-- End #13


-- Puzzle #14
DROP TABLE IF EXISTS ProcessLog;
GO

CREATE TABLE ProcessLog
(
Workflow    VARCHAR(100),
StepNumber  INTEGER,
[Status]    VARCHAR(100),
PRIMARY KEY (Workflow, StepNumber)
);
GO

INSERT INTO ProcessLog VALUES
('Alpha',1,'Error'),('Alpha',2,'Complete'),('Bravo',1,'Complete'),('Bravo',2,'Complete'),
('Charlie',1,'Complete'),('Charlie',2,'Error'),('Delta',1,'Complete'),('Delta',2,'Running'),
('Echo',1,'Running'),('Echo',2,'Error'),('Foxtrot',1,'Error'),('Foxtrot',2,'Error');
GO

DROP TABLE IF EXISTS #Status;
GO

CREATE TABLE #Status
(
StatusProcess VARCHAR(100),
RankProcess INTEGER,
PRIMARY KEY (StatusProcess, RankProcess)
);
GO

INSERT INTO #Status VALUES
('Error', 1),
('Running', 2),
('Complete', 3);
GO

WITH CountError_cte AS
(
SELECT
	Workflow, 
	COUNT(DISTINCT [Status]) AS DistinctCount
FROM ProcessLog process1
WHERE EXISTS
(
SELECT 
	1
FROM ProcessLog process2
WHERE process1.Workflow = process2.Workflow AND [Status] = 'Error'
)
GROUP BY Workflow
),

Workflows_cte AS
(
SELECT 
	process.Workflow,
    (CASE WHEN DistinctCount > 1 THEN 'Indeterminate' ELSE process.[Status] END) AS [Status]
FROM ProcessLog process INNER JOIN
        CountError_cte countErr ON process.WorkFlow = countErr.WorkFlow
GROUP BY process.WorkFlow, (CASE WHEN DistinctCount > 1 THEN 'Indeterminate' ELSE process.[Status] END)
)

SELECT DISTINCT
	process.Workflow,
    FIRST_VALUE(process.[Status]) OVER (PARTITION  BY process.Workflow ORDER BY stat.RankProcess) AS [Status]
FROM ProcessLog process 
INNER JOIN #Status stat ON process.[Status] = stat.StatusProcess
WHERE process.Workflow NOT IN (SELECT Workflow FROM Workflows_cte)
UNION
SELECT
	Workflow,
	[Status]
FROM Workflows_cte
ORDER BY process.Workflow;
GO

-- End #14


-- Puzzle #15
DROP TABLE IF EXISTS DMLTable;
GO

CREATE TABLE DMLTable
(
SequenceNumber  INTEGER PRIMARY KEY,
String          VARCHAR(100)
);
GO

INSERT INTO DMLTable VALUES
(1,'SELECT'),
(5,'FROM'),
(7,'WHERE'),
(2,'Product'),
(6,'Products'),
(3,'UnitPrice'),
(9,'> 100'),
(4,'EffectiveDate'),
(8,'UnitPrice');
GO

WITH Concat_cte (ResultString, Depth) AS
(
SELECT  
	CAST('' AS NVARCHAR(MAX)),
    CAST(MAX(SequenceNumber) AS INTEGER)
FROM DMLTable
UNION ALL
SELECT  
	dml.String + ' ' + Concat_cte.ResultString, Concat_cte.Depth-1
FROM Concat_cte 
INNER JOIN DMLTable dml ON Concat_cte.Depth = dml.SequenceNumber
)
SELECT  
	ResultString
FROM Concat_cte
WHERE Depth = 0;
GO

-- End #15