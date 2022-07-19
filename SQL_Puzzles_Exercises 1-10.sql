/*
Advanced SQL Puzzles
https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Advanced%20SQL%20Puzzles
*/
USE SQLPuzzles;
GO


-- Puzzle #1
DROP TABLE IF EXISTS Cart1;
DROP TABLE IF EXISTS Cart2;
GO

CREATE TABLE Cart1
(Item VARCHAR(100) PRIMARY KEY
);
GO

CREATE TABLE Cart2
(
Item VARCHAR(100) PRIMARY KEY
);
GO

INSERT INTO Cart1 (Item) VALUES
('Sugar'),('Bread'),('Juice'),('Soda'),('Flour');
GO

INSERT INTO Cart2 VALUES
('Sugar'),('Bread'),('Butter'),('Cheese'),('Fruit');
GO

SELECT
	cart1.Item,
	cart2.Item
FROM Cart1 cart1
FULL OUTER JOIN Cart2 cart2 ON cart1.Item = cart2.Item
ORDER BY cart1.Item DESC;
GO
-- End #1

-- Puzzle #2
DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees
(
EmployeeID  INTEGER PRIMARY KEY,
ManagerID   INTEGER,
JobTitle    VARCHAR(100),
Salary      INTEGER
);
GO

INSERT INTO Employees VALUES
(1001,NULL,'President',185000),(2002,1001,'Director',120000),
(3003,1001,'Office Manager',97000),(4004,2002,'Engineer',110000),
(5005,2002,'Engineer',142000),(6006,2002,'Engineer',160000);
GO

SELECT
	empl.EmployeeID,
	empl.ManagerID,
	empl.JobTitle,
	empl.Salary,
	(SELECT 
		CASE
			WHEN empl.ManagerID IS NULL THEN 0
			WHEN empl.ManagerID = 1001 THEN 1
			WHEN empl.ManagerID = 2002 THEN 2
		END
	) AS 'Depth'
FROM Employees empl;
GO
-- End #2


-- Puzzle #3
DROP TABLE IF EXISTS EmployeePayRecords;
GO

CREATE TABLE EmployeePayRecords
(
EmployeeID  INTEGER,
FiscalYear  INTEGER,
StartDate   DATE,
EndDate     DATE,
PayRate     MONEY
);
GO

ALTER TABLE EmployeePayRecords 
	ALTER COLUMN EmployeeID INTEGER NOT NULL;
ALTER TABLE EmployeePayRecords 
	ALTER COLUMN FiscalYear INTEGER NOT NULL;
ALTER TABLE EmployeePayRecords 
	ALTER COLUMN StartDate DATE NOT NULL;
ALTER TABLE EmployeePayRecords 
	ALTER COLUMN EndDate DATE NOT NULL;
ALTER TABLE EmployeePayRecords 
	ALTER COLUMN PayRate MONEY NOT NULL;
GO

ALTER TABLE EmployeePayRecords 
	ADD CONSTRAINT PK_FiscalYearCalendar PRIMARY KEY (EmployeeID,FiscalYear);
ALTER TABLE EmployeePayRecords 
	ADD CONSTRAINT Check_Year_StartDate CHECK (FiscalYear = DATEPART(YYYY, StartDate));
ALTER TABLE EmployeePayRecords
	ADD CONSTRAINT Check_Month_StartDate CHECK (DATEPART(MM, StartDate) = 01);
ALTER TABLE EmployeePayRecords 
	ADD CONSTRAINT Check_Day_StartDate CHECK (DATEPART(DD, StartDate) = 01);
ALTER TABLE EmployeePayRecords 
	ADD CONSTRAINT Check_Year_EndDate CHECK (FiscalYear = DATEPART(YYYY, EndDate));
ALTER TABLE EmployeePayRecords 
	ADD CONSTRAINT Check_Month_EndDate CHECK (DATEPART(MM, EndDate) = 12);
ALTER TABLE EmployeePayRecords 
	ADD CONSTRAINT Check_Day_EndDate CHECK (DATEPART(DD, EndDate) = 31);
GO

ALTER TABLE EmployeePayRecords 
	ADD CHECK (PayRate > 0);
GO
-- End #3


-- Puzzle #4
DROP TABLE IF EXISTS Orders;
GO

CREATE TABLE Orders
(
CustomerID      INTEGER,
OrderID         VARCHAR(100),
DeliveryState   VARCHAR(100),
Amount          MONEY,
PRIMARY KEY (CustomerID, OrderID)
);
GO

INSERT INTO Orders VALUES
(1001,'Ord936254','CA',340),(1001,'Ord143876','TX',950),(1001,'Ord654876','TX',670),
(1001,'Ord814356','TX',860),(2002,'Ord342176','WA',320),(3003,'Ord265789','CA',650),
(3003,'Ord387654','CA',830),(4004,'Ord476126','TX',120);
GO

WITH CaDelivery (CustomerID)
AS
(
	SELECT 
		CustomerID
	FROM Orders orders
	WHERE orders.DeliveryState = 'CA'
)
SELECT
	CaDelivery.CustomerID,
	orders.OrderID,
	orders.DeliveryState,
	orders.Amount
FROM Orders orders
INNER JOIN CaDelivery caDelivery ON caDelivery.CustomerID = orders.CustomerID
WHERE orders.DeliveryState = 'TX';
GO
-- End #4


-- Puzzle #5
DROP TABLE IF EXISTS PhoneDirectory;
GO

CREATE TABLE PhoneDirectory
(
CustomerID  INTEGER,
[Type]      VARCHAR(100),
PhoneNumber VARCHAR(12),
PRIMARY KEY (CustomerID, [Type])
);
GO

INSERT INTO PhoneDirectory VALUES
(1001,'Cellular','555-897-5421'),
(1001,'Work','555-897-6542'),
(1001,'Home','555-698-9874'),
(2002,'Cellular','555-963-6544'),
(2002,'Work','555-812-9856'),
(3003,'Cellular','555-987-6541');
GO

WITH Cellular (CustomerID, PhoneNumber)
AS
(
	SELECT 
		PhoneDirectory.CustomerID, 
		PhoneDirectory.PhoneNumber
	FROM PhoneDirectory
	WHERE PhoneDirectory.Type = 'Cellular'
),
Work (CustomerID, PhoneNumber)
AS
(
	SELECT 
		PhoneDirectory.CustomerID, 
		PhoneDirectory.PhoneNumber
	FROM PhoneDirectory
	WHERE PhoneDirectory.Type = 'Work'
),
Home (CustomerID, PhoneNumber)
AS
(
	SELECT 
		PhoneDirectory.CustomerID, 
		PhoneDirectory.PhoneNumber
	FROM PhoneDirectory
	WHERE PhoneDirectory.Type = 'Home'
)
SELECT DISTINCT
	PhoneDirectory.CustomerID,
	Cellular.PhoneNumber,
	Work.PhoneNumber,
	Home.PhoneNumber
FROM PhoneDirectory
FULL OUTER JOIN Cellular ON Cellular.CustomerID = PhoneDirectory.CustomerID
FULL OUTER JOIN Work ON Work.CustomerID = PhoneDirectory.CustomerID
FULL OUTER JOIN Home ON Home.CustomerID = PhoneDirectory.CustomerID
GO
-- End #5


-- Puzzle #6
DROP TABLE IF EXISTS WorkflowSteps;
GO

CREATE TABLE WorkflowSteps
(
Workflow        VARCHAR(100),
StepNumber      INTEGER,
CompletionDate  DATE,
PRIMARY KEY (Workflow, StepNumber)
);
GO

INSERT INTO WorkflowSteps VALUES
('Alpha',1,'7/2/2018'),('Alpha',2,'7/2/2018'),('Alpha',3,'7/1/2018'),
('Bravo',1,'6/25/2018'),('Bravo',2,NULL),('Bravo',3,'6/27/2018'),
('Charlie',1,NULL),('Charlie',2,'7/1/2018');
GO

SELECT
	WorkflowSteps.Workflow
FROM WorkflowSteps
GROUP BY WorkflowSteps.Workflow
HAVING COUNT(*) <> COUNT(WorkflowSteps.CompletionDate)
GO
-- End #6


-- Puzzle #7
DROP TABLE IF EXISTS Candidates;
DROP TABLE IF EXISTS Requirements;
GO

CREATE TABLE Candidates
(
CandidateID INTEGER,
Occupation  VARCHAR(100),
PRIMARY KEY (CandidateID, Occupation)
);
GO

INSERT INTO Candidates VALUES
(1001,'Geologist'),(1001,'Astrogator'),(1001,'Biochemist'),
(1001,'Technician'),(2002,'Surgeon'),(2002,'Machinist'),
(3003,'Cryologist'),(4004,'Selenologist');
GO

CREATE TABLE Requirements
(
Requirement VARCHAR(100) PRIMARY KEY
);
GO

INSERT INTO Requirements VALUES
('Geologist'),('Astrogator'),('Technician');
GO

SELECT DISTINCT
	Candidates.CandidateID
FROM Candidates
INNER JOIN Requirements ON Requirements.Requirement = Candidates.Occupation;
GO
-- End #7


-- Puzzle #8
DROP TABLE IF EXISTS WorkflowCases;
GO

CREATE TABLE WorkflowCases
(
Workflow    VARCHAR(100) PRIMARY KEY,
Case1       INTEGER,
Case2       INTEGER,
Case3       INTEGER
);
GO

INSERT INTO WorkflowCases VALUES
('Alpha',0,0,0),('Bravo',0,1,1),('Charlie',1,0,0),('Delta',0,0,0);
GO

SELECT
	WorkflowCases.Workflow,
	WorkflowCases.Case1 + WorkflowCases.Case2 + WorkflowCases.Case3 AS 'Passed'
FROM WorkflowCases;
GO
-- End #8


-- Puzzle #9
DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees
(
EmployeeID  INTEGER,
License     VARCHAR(100),
PRIMARY KEY (EmployeeID, License)
);
GO

INSERT INTO Employees VALUES
(1001,'Class A'),
(1001,'Class B'),
(1001,'Class C'),
(2002,'Class A'),
(2002,'Class B'),
(2002,'Class C'),
(3003,'Class A'),
(3003,'Class D');
GO

WITH CountEmployee (EmployeeID, CountLicense) AS (
SELECT
	EmployeeID,
	COUNT(*) AS 'CountLicense'
FROM Employees
GROUP BY EmployeeID
),
CountCombined AS (
SELECT  
	empl1.EmployeeID AS 'EmployeeID',
    empl2.EmployeeID AS 'EmployeeID2',
    COUNT(*) AS LicenseCountCombo
FROM Employees empl1 
INNER JOIN Employees empl2 ON empl1.License = empl2.License
WHERE empl1.EmployeeID <> empl2.EmployeeID
GROUP BY empl1.EmployeeID, empl2.EmployeeID
)
SELECT  
	CountCombined.EmployeeID,
	CountCombined.EmployeeID2
FROM CountCombined 
INNER JOIN CountEmployee ON CountCombined.LicenseCountCombo = CountEmployee.CountLicense AND CountCombined.EmployeeID <> CountEmployee.EmployeeID;
GO
-- End #9


-- Puzzle #10
DROP TABLE IF EXISTS SampleData;
GO

CREATE TABLE SampleData
(
IntegerValue INTEGER
);
GO

INSERT INTO SampleData VALUES
(5),(6),(10),(10),(13),(14),(17),(20),(81),(90),(76);
GO

SELECT
	AVG(SampleData.IntegerValue) AS 'Mean',
	(SELECT 
		SampleData.IntegerValue
	FROM SampleData 
	ORDER BY SampleData.IntegerValue 
	OFFSET CEILING(COUNT(SampleData.IntegerValue)/2) ROWS 
	FETCH NEXT 1 ROWS ONLY) AS 'Median',
	(SELECT TOP 1
		SampleData.IntegerValue
		FROM SampleData
		GROUP BY SampleData.IntegerValue
		ORDER BY COUNT(SampleData.IntegerValue) DESC
	) AS 'Mode',
	MAX(SampleData.IntegerValue) - MIN(SampleData.IntegerValue) AS 'Range'
FROM SampleData;
GO
-- End #10