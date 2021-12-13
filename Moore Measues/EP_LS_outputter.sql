-- Set Up
USE ORD_Singh_202001030D
SET NOCOUNT ON


-- Variables
DECLARE @EPNumerator INT
DECLARE @Denominator INT
DECLARE @LS_S1 INT
DECLARE @LS_S2 INT
DECLARE @LS_S3 INT
DECLARE @LS_S4 INT
DECLARE @LS_SOther INT
DECLARE @LS_Numerator_Early INT
DECLARE @LS_Numerator_Late INT


-- 1: EP - Numerator
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_EPNumerator') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_EPNumerator
	END

CREATE TABLE Dflt._ppkt_LCa_2019_EPNumerator
(
	PatientSSN VARCHAR(100)
	,DiagnosticEventDateTime DATE
	,DiagnosisEventLocation VARCHAR(200)
	,TypeOfCancer VARCHAR(300)
	,StageOfCancer VARCHAR(100)
	,TypeOfDiagnosisEvent VARCHAR(50)
	,EmergencyEventDate DATE
	,EmergencyEventLocation VARCHAR(200)
	,TypeOfEmergencyEvent VARCHAR(50)
	,HasPCPBeforeCutOff INT
	,HasPCPAfterCutOff INT
	,DeathDateTime DATETIME2
	,PatientSex VARCHAR(100)
	,PatientAge INT
	,PatientRace VARCHAR(100)
)

INSERT INTO Dflt._ppkt_LCa_2019_EPNumerator
SELECT *
FROM Dflt._ppkt_LCa_2019n_OUTPUT_TABLE AS a WHERE a.TypeOfDiagnosisEvent = 'REGISTRY ENTRY'

SET @EPNumerator = (SELECT COUNT(DISTINCT a.PatientSSN) FROM Dflt._ppkt_LCa_2019_EPNumerator AS a)

-- 2: EP/LS - Denominator
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_Denominator') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_Denominator
	END

CREATE TABLE Dflt._ppkt_LCa_2019_Denominator
(
	PatientSSN VARCHAR(100)
	,DiagnosticEventDateTime DATE
	,DiagnosisEventLocation VARCHAR(200)
	,TypeOfCancer VARCHAR(300)
	,StageOfCancer VARCHAR(100)
	,TypeOfDiagnosisEvent VARCHAR(50)
	,HasPCPBeforeCutOff INT
	,HasPCPAfterCutOff INT
	,DeathDateTime DATETIME2
	,PatientSex VARCHAR(100)
	,PatientAge INT
	,PatientRace VARCHAR(100)
)

INSERT INTO Dflt._ppkt_LCa_2019_Denominator
SELECT * 
FROM Dflt._ppkt_LCa_2019d_OUTPUT_TABLE AS a WHERE a.TypeOfDiagnosisEvent = 'REGISTRY ENTRY'

SET @Denominator = (SELECT COUNT(DISTINCT a.PatientSSN) FROM Dflt._ppkt_LCa_2019_Denominator AS a)

-- 3: LS - Stage is I
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_S1') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_S1
	END

CREATE TABLE Dflt._ppkt_LCa_2019_LS_S1
(
	PatientSSN VARCHAR(100)
	,DiagnosticEventDateTime DATE
	,DiagnosisEventLocation VARCHAR(200)
	,TypeOfCancer VARCHAR(300)
	,StageOfCancer VARCHAR(100)
	,TypeOfDiagnosisEvent VARCHAR(50)
	,HasPCPBeforeCutOff INT
	,HasPCPAfterCutOff INT
	,DeathDateTime DATETIME2
	,PatientSex VARCHAR(100)
	,PatientAge INT
	,PatientRace VARCHAR(100)
)

INSERT INTO Dflt._ppkt_LCa_2019_LS_S1
SELECT * 
FROM Dflt._ppkt_LCa_2019d_OUTPUT_TABLE AS a WHERE a.TypeOfDiagnosisEvent = 'REGISTRY ENTRY' AND a.StageOfCancer = 'I'

SET @LS_S1 = (SELECT COUNT(DISTINCT a.PatientSSN) FROM Dflt._ppkt_LCa_2019_LS_S1 AS a)

-- 4: LS - Stage is II
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_S2') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_S2
	END

CREATE TABLE Dflt._ppkt_LCa_2019_LS_S2
(
	PatientSSN VARCHAR(100)
	,DiagnosticEventDateTime DATE
	,DiagnosisEventLocation VARCHAR(200)
	,TypeOfCancer VARCHAR(300)
	,StageOfCancer VARCHAR(100)
	,TypeOfDiagnosisEvent VARCHAR(50)
	,HasPCPBeforeCutOff INT
	,HasPCPAfterCutOff INT
	,DeathDateTime DATETIME2
	,PatientSex VARCHAR(100)
	,PatientAge INT
	,PatientRace VARCHAR(100)
)

INSERT INTO Dflt._ppkt_LCa_2019_LS_S2
SELECT * 
FROM Dflt._ppkt_LCa_2019d_OUTPUT_TABLE AS a WHERE a.TypeOfDiagnosisEvent = 'REGISTRY ENTRY' AND a.StageOfCancer = 'II'

SET @LS_S2 = (SELECT COUNT(DISTINCT a.PatientSSN) FROM Dflt._ppkt_LCa_2019_LS_S2 AS a)

-- 5: LS - Stage is III
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_S3') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_S3
	END

CREATE TABLE Dflt._ppkt_LCa_2019_LS_S3
(
	PatientSSN VARCHAR(100)
	,DiagnosticEventDateTime DATE
	,DiagnosisEventLocation VARCHAR(200)
	,TypeOfCancer VARCHAR(300)
	,StageOfCancer VARCHAR(100)
	,TypeOfDiagnosisEvent VARCHAR(50)
	,HasPCPBeforeCutOff INT
	,HasPCPAfterCutOff INT
	,DeathDateTime DATETIME2
	,PatientSex VARCHAR(100)
	,PatientAge INT
	,PatientRace VARCHAR(100)
)

INSERT INTO Dflt._ppkt_LCa_2019_LS_S3
SELECT * 
FROM Dflt._ppkt_LCa_2019d_OUTPUT_TABLE AS a WHERE a.TypeOfDiagnosisEvent = 'REGISTRY ENTRY' AND a.StageOfCancer = 'III'

SET @LS_S3 = (SELECT COUNT(DISTINCT a.PatientSSN) FROM Dflt._ppkt_LCa_2019_LS_S3 AS a)

-- 6: LS - Stage is IV
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_S4') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_S4
	END

CREATE TABLE Dflt._ppkt_LCa_2019_LS_S4
(
	PatientSSN VARCHAR(100)
	,DiagnosticEventDateTime DATE
	,DiagnosisEventLocation VARCHAR(200)
	,TypeOfCancer VARCHAR(300)
	,StageOfCancer VARCHAR(100)
	,TypeOfDiagnosisEvent VARCHAR(50)
	,HasPCPBeforeCutOff INT
	,HasPCPAfterCutOff INT
	,DeathDateTime DATETIME2
	,PatientSex VARCHAR(100)
	,PatientAge INT
	,PatientRace VARCHAR(100)
)

INSERT INTO Dflt._ppkt_LCa_2019_LS_S4
SELECT * 
FROM Dflt._ppkt_LCa_2019d_OUTPUT_TABLE AS a WHERE a.TypeOfDiagnosisEvent = 'REGISTRY ENTRY' AND a.StageOfCancer = 'IV'

SET @LS_S4 = (SELECT COUNT(DISTINCT a.PatientSSN) FROM Dflt._ppkt_LCa_2019_LS_S4 AS a)

-- 7: LS - Stage is not I-IV ("Other")
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_SOther') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_SOther
	END

CREATE TABLE Dflt._ppkt_LCa_2019_LS_SOther
(
	PatientSSN VARCHAR(100)
	,DiagnosticEventDateTime DATE
	,DiagnosisEventLocation VARCHAR(200)
	,TypeOfCancer VARCHAR(300)
	,StageOfCancer VARCHAR(100)
	,TypeOfDiagnosisEvent VARCHAR(50)
	,HasPCPBeforeCutOff INT
	,HasPCPAfterCutOff INT
	,DeathDateTime DATETIME2
	,PatientSex VARCHAR(100)
	,PatientAge INT
	,PatientRace VARCHAR(100)
)

INSERT INTO Dflt._ppkt_LCa_2019_LS_SOther
SELECT * 
FROM Dflt._ppkt_LCa_2019d_OUTPUT_TABLE AS a WHERE a.TypeOfDiagnosisEvent = 'REGISTRY ENTRY' AND (NOT (a.StageOfCancer = 'I' OR a.StageOfCancer = 'II' OR a.StageOfCancer = 'III' OR a.StageOfCancer = 'IV') OR a.StageOfCancer IS NULL)

SET @LS_SOther = (SELECT COUNT(DISTINCT a.PatientSSN) FROM Dflt._ppkt_LCa_2019_LS_SOther AS a)

-- 8: LS - Early Cancer Presentations
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_Early') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_Early
	END

CREATE TABLE Dflt._ppkt_LCa_2019_LS_Early
(
	PatientSSN VARCHAR(100)
	,DiagnosticEventDateTime DATE
	,DiagnosisEventLocation VARCHAR(200)
	,TypeOfCancer VARCHAR(300)
	,StageOfCancer VARCHAR(100)
	,TypeOfDiagnosisEvent VARCHAR(50)
	,HasPCPBeforeCutOff INT
	,HasPCPAfterCutOff INT
	,DeathDateTime DATETIME2
	,PatientSex VARCHAR(100)
	,PatientAge INT
	,PatientRace VARCHAR(100)
)

INSERT INTO Dflt._ppkt_LCa_2019_LS_Early
SELECT * 
FROM Dflt._ppkt_LCa_2019d_OUTPUT_TABLE AS a WHERE a.TypeOfDiagnosisEvent = 'REGISTRY ENTRY' AND (a.StageOfCancer = 'I' OR a.StageOfCancer = 'II')

SET @LS_Numerator_Early = @LS_S1 + @LS_S2

-- 9: LS - Late Cancer Presentations
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_Late') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_Late
	END

CREATE TABLE Dflt._ppkt_LCa_2019_LS_Late
(
	PatientSSN VARCHAR(100)
	,DiagnosticEventDateTime DATE
	,DiagnosisEventLocation VARCHAR(200)
	,TypeOfCancer VARCHAR(300)
	,StageOfCancer VARCHAR(100)
	,TypeOfDiagnosisEvent VARCHAR(50)
	,HasPCPBeforeCutOff INT
	,HasPCPAfterCutOff INT
	,DeathDateTime DATETIME2
	,PatientSex VARCHAR(100)
	,PatientAge INT
	,PatientRace VARCHAR(100)
)

INSERT INTO Dflt._ppkt_LCa_2019_LS_Late
SELECT * 
FROM Dflt._ppkt_LCa_2019d_OUTPUT_TABLE AS a WHERE a.TypeOfDiagnosisEvent = 'REGISTRY ENTRY' AND (a.StageOfCancer = 'III' OR a.StageOfCancer = 'IV')

SET @LS_Numerator_Late = @LS_S3 + @LS_S4


-- Print
PRINT 'Total Cancer Diagnoses: ' + CAST(@Denominator AS VARCHAR)
PRINT CHAR(13) + CHAR(10) + 'EP Numerator: ' + CAST(@EPNumerator AS VARCHAR)
PRINT CHAR(13) + CHAR(10) + 'LS Numerator (Stage III and IV presentations): ' + CAST(@LS_Numerator_Late AS VARCHAR)
PRINT CHAR(13) + CHAR(10) + 'Stage I Presentations: ' + CAST(@LS_S1 AS VARCHAR)
PRINT 'Stage II Presentations: ' + CAST(@LS_S2 AS VARCHAR)
PRINT 'Stage III Presentations: ' + CAST(@LS_S3 AS VARCHAR)
PRINT 'Stage IV Presentations: ' + CAST(@LS_S4 AS VARCHAR)
PRINT 'Stage "Other" Presentations: ' + CAST(@LS_SOther AS VARCHAR)

SELECT DISTINCT 
a.PatientSSN AS PatientSSN
,'EP' AS TypeOfEvaluation
,'_LCa_' AS StudyDescField1
,'Registry' AS StudyDescField2
,a.StageOfCancer AS StudyDescField3
,a.EmergencyEventDate AS AntecedentEventStartDateTime
,a.EmergencyEventLocation AS AntecedentEventLocation
,a.DiagnosticEventDateTime AS SubsequentEventStartDateTime
,a.DiagnosisEventLocation AS SubsequentEventLocation
FROM Dflt._ppkt_LCa_2019_EPNumerator AS a

SELECT DISTINCT 
a.PatientSSN AS PatientSSN
,'LS' AS TypeOfEvaluation
,'_LCa_' AS StudyDescField1
,'Registry' AS StudyDescField2
,a.StageOfCancer AS StudyDescField3
,a.DiagnosticEventDateTime AS SubsequentEventStartDateTime
,a.DiagnosisEventLocation AS SubsequentEventLocation
FROM Dflt._ppkt_LCa_2019_LS_Late AS a


-- Clean Up
IF (OBJECT_ID('Dflt._ppkt_LCa_2019_EPNumerator') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_EPNumerator
	END

IF (OBJECT_ID('Dflt._ppkt_LCa_2019_Denominator') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_Denominator
	END

IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_S1') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_S1
	END

IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_S2') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_S2
	END

IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_S3') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_S3
	END

IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_S4') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_S4
	END

IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_SOther') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_SOther
	END

IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_Early') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_Early
	END

IF (OBJECT_ID('Dflt._ppkt_LCa_2019_LS_Late') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._ppkt_LCa_2019_LS_Late
	END

SET NOCOUNT OFF
