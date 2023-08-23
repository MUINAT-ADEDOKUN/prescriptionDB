CREATE TABLE Drugs_Descriptions ( 
Description_ID INT NOT NULL IDENTITY(1,1)PRIMARY KEY,
Drugs_Name NVARCHAR(100)
);
CREATE TABLE Chemical_Substances (
Chemical_ID INT NOT NULL IDENTITY(1,1)PRIMARY KEY,
Chemical_Name NVARCHAR(100)
);
CREATE TABLE Drug_Chapters (
Chapter_ID INT NOT NULL IDENTITY(1,1)PRIMARY KEY,
Chapter_Title NVARCHAR(100)
);
CREATE TABLE ADDRESS (
Address_ID INT NOT NULL IDENTITY(1,1)PRIMARY KEY,
Address_1 NVARCHAR (50),
Address_2 NVARCHAR (50),
Address_3 NVARCHAR (50),
Address_4 NVARCHAR (50),
postcode NVARCHAR (50)
);
CREATE TABLE Practice_address (
practice_code VARCHAR(50) PRIMARY KEY,
Address_ID int 
);

ALTER TABLE dbo.Medical_Practice ADD CONSTRAINT PK_Medical_Practice PRIMARY KEY (PRACTICE_CODE)
ALTER TABLE dbo.Drugs ADD CONSTRAINT PK_Drugs PRIMARY KEY ([BNF_CODE])
ALTER TABLE dbo.Prescriptions ADD CONSTRAINT PK_Prescriptions PRIMARY KEY ([PRESCRIPTION_CODE])


INSERT INTO Drugs_Descriptions
SELECT DISTINCT BNF_description
from [dbo].[Drugs];


INSERT INTO Drug_chapters
SELECT DISTINCT BNF_chapter_plus_code
from [dbo].[Drugs];


INSERT INTO Chemical_Substances
SELECT DISTINCT [CHEMICAL_SUBSTANCE_BNF_DESCR]
from [dbo].[Drugs];

CREATE TABLE NEW_Drugs (
BNF_CODE VARCHAR(20) primary key,
Chemical_ID INT ,
Description_ID INT ,
Chapter_ID INT,
FOREIGN KEY (Chemical_ID) REFERENCES Chemical_Substances (Chemical_ID),
FOREIGN KEY (Description_ID) REFERENCES Drugs_Descriptions (Description_ID),
FOREIGN KEY (Chapter_ID) REFERENCES Drug_Chapters (Chapter_ID)
);



INSERT INTO NEW_Drugs
SELECT d.BNF_CODE, c.Chemical_ID, de.Description_ID, b.Chapter_ID
FROM Drugs d
JOIN Drug_Chapters b
ON d.BNF_CHAPTER_PLUS_CODE = b.Chapter_Title
JOIN Chemical_Substances c
ON d.CHEMICAL_SUBSTANCE_BNF_DESCR = c.Chemical_Name
JOIN Drugs_Descriptions de
ON d.BNF_DESCRIPTION = de.Drugs_Name;

select *
from Drugs 

ALTER TABLE dbo.Prescriptions ADD CONSTRAINT FK_Prescriptions_Medical_Practice FOREIGN KEY (PRACTICE_CODE) REFERENCES dbo.Medical_Practice (PRACTICE_CODE);
ALTER TABLE dbo.Prescriptions ADD CONSTRAINT FK_Prescriptions_Drugs FOREIGN KEY (BNF_CODE) REFERENCES dbo.Drugs (BNF_CODE);

SELECT *
FROM [dbo].[Drug_Chapters]

UPDATE Prescriptions
SET Chapter_ID = dc.Chapter_ID
FROM Prescriptions p
JOIN Drugs d ON p.BNF_CODE = d.BNF_CODE
JOIN Drug_Chapters dc ON dc.Chapter_ID = dc.Chapter_ID;

ALTER TABLE Prescriptions
DROP COLUMN Chapter_ID;

/*Write a query that returns details of all drugs which are in the form of tablets or
capsules*/
SELECT *
FROM Drugs_Descriptions
WHERE Drugs_Name like '%tablet%' OR Drugs_Name like '%capsules%';

ALTER TABLE Prescriptions
ALTER COLUMN items decimal(10,2);

/*Write a query that returns the total quantity for each of prescriptions */
SELECT PRESCRIPTION_CODE, ROUND(SUM(ITEMS * QUANTITY), 0) AS TOTAL_QUANTITY
FROM Prescriptions
GROUP BY PRESCRIPTION_CODE;
/*Write a query that returns a list of the distinct chemical substances which appear in
the Drugs table*/
select distinct([Chemical_Name])
from [dbo].[Chemical_Substances]
/*Write a query that returns the number of prescriptions for each
BNF_CHAPTER_PLUS_CODE, along with the average cost for that chapter code, and the
minimum and maximum prescription costs for that chapter code.*/
SELECT d.BNF_chapter_plus_code, 
COUNT(p.prescription_code) AS prescription_count,
AVG(p.actual_cost) AS average_cost,
MIN(p.actual_cost) AS minimum_cost,
MAX(p.actual_cost) AS maximum_cost
FROM Prescriptions p
JOIN Drugs d 
ON p.BNF_CODE = d.BNF_CODE
JOIN Drug_Chapters dc 
ON  dc.Chapter_ID = dc.Chapter_ID
GROUP BY d.BNF_chapter_plus_code;
/*Write a query that returns the most expensive prescription prescribed by each
practice, sorted in descending order by prescription cost (the ACTUAL_COST column in
the prescription table.) Return only those rows where the most expensive prescription
is more than £4000*/
SELECT mp.PRACTICE_NAME, p.prescription_code, p.actual_cost
FROM Prescriptions p
JOIN Medical_practice mp ON p.practice_code = mp.practice_code
WHERE p.actual_cost = (
  SELECT MAX(actual_cost)
  FROM Prescriptions
  WHERE practice_code = p.practice_code
)
AND p.actual_cost > 4000
ORDER BY p.actual_cost DESC;

/*  write a query that select all the prescription that contain drugs with chemical_id=10*/
SELECT *
FROM Prescriptions
WHERE EXISTS (
SELECT 1
FROM NEW_Drugs 
WHERE Prescriptions.BNF_CODE = NEW_Drugs.BNF_CODE
AND NEW_Drugs.Chemical_ID = 10
);
/*List all the chemical substances that are not used in any prescription*/
SELECT [Chemical_Name]
FROM [dbo].[Chemical_Substances]
WHERE NOT EXISTS (
    SELECT 1
    FROM [dbo].[NEW_Drugs]
    WHERE [dbo].[Chemical_Substances].[Chemical_ID] = [dbo].[NEW_Drugs].[Chemical_ID]
)
/* lists all drugs that have been prescribed in quantities greater than 1000*/
SELECT DISTINCT  Description_ID 
FROM NEW_Drugs 
WHERE EXISTS (
    SELECT 1
    FROM Prescriptions
    WHERE NEW_Drugs.BNF_CODE = Prescriptions.BNF_CODE
    AND ITEMS * QUANTITY > 1000
)
/*list the number of prescription for each chemical substance*/
SELECT cs.Chemical_Name, COUNT(*) AS Prescription_Count
FROM NEW_Drugs d
JOIN Chemical_Substances cs 
ON d.Chemical_ID = cs.Chemical_ID
JOIN Prescriptions p
ON d.BNF_CODE = p.BNF_CODE
GROUP BY cs.Chemical_Name
ORDER BY Prescription_Count DESC;

/*Using the UPPER function to retrieve all drugs starting with a A*/
SELECT *
FROM [dbo].[Drugs_Descriptions]
WHERE UPPER(Drugs_Name) LIKE 'A%'

/*list total number of prescription and total cost of medical practice*/
SELECT practice_name, COUNT(DISTINCT prescription_code) AS Total_Prescriptions, SUM(actual_cost) AS Total_Cost
FROM Medical_practice mp
JOIN Prescriptions p ON mp.practice_code = p.practice_code
GROUP BY practice_name
HAVING COUNT(DISTINCT prescription_code) > 500
ORDER BY Total_Cost DESC;

SELECT *
FROM Drugs_Descriptions
WHERE LEN(Drugs_Name) = 10

/* Return the medical practice with the highest average cost of prescriptions.*/
SELECT TOP 1 practice_code, AVG(actual_cost) AS average_cost
FROM Prescriptions
GROUP BY practice_code
ORDER BY average_cost DESC;

FROM [dbo].[Prescriptions]

select *
from Drug_Chapters