-- ================================================================================================
-- ================================================================================================
-- PARAMETERS + SET-UP
-- ================================================================================================
-- ================================================================================================



-- CONFIG
-- ************************************************************************************************


-- Set Database
USE ORD_Singh_201911038D


GO



-- PARAMETER TABLE
-- ************************************************************************************************


-- Declare Variables
DECLARE @SearchPeriodStart DATETIME2
DECLARE @SearchPeriodLength_Months INT
DECLARE @PostEDAdmitToHospitalLinkingPeriodLength_Hours INT
DECLARE @EDToEDLookforwardPeriodStartDelta_Days INT
DECLARE @EDToEDLookforwardPeriodLength_Days INT
DECLARE @EDToInpatientLookforwardPeriodStartDelta_Days INT
DECLARE @EDToInpatientLookforwardPeriodLength_Days INT
DECLARE @EDToPCPLookforwardPeriodStartDelta_Days INT
DECLARE @EDToPCPLookforwardPeriodLength_Days INT
DECLARE @StationID INT

-- Set Variables
SET @SearchPeriodStart = '2018-01-01'
SET @SearchPeriodLength_Months = 24
SET @PostEDAdmitToHospitalLinkingPeriodLength_Hours = 24
SET @EDToEDLookforwardPeriodStartDelta_Days = 1
SET @EDToEDLookforwardPeriodLength_Days = 10
SET @EDToInpatientLookforwardPeriodStartDelta_Days = 1
SET @EDToInpatientLookforwardPeriodLength_Days = 10
SET @EDToPCPLookforwardPeriodStartDelta_Days = 0
SET @EDToPCPLookforwardPeriodLength_Days = 7
SET @StationID = 580


-- Create parameter table
IF (OBJECT_ID('Dflt._pk_SETUP_ParameterTable') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_ParameterTable
	END

CREATE TABLE Dflt._pk_SETUP_ParameterTable
(
	SearchPeriodStart DATETIME2
	,SearchPeriodLength_Months INT
	,PostEDAdmitToHospitalLinkingPeriodLength_Hours INT
	,EDToEDLookforwardPeriodStartDelta_Days INT
	,EDToEDLookforwardPeriodLength_Days INT
	,EDToInpatientLookforwardPeriodStartDelta_Days INT
	,EDToInpatientLookforwardPeriodLength_Days INT
	,EDToPCPLookforwardPeriodStartDelta_Days INT
	,EDToPCPLookforwardPeriodLength_Days INT
	,StationID INT

)


-- Insert Variables into Parameter Table
INSERT INTO Dflt._pk_SETUP_ParameterTable
(
	SearchPeriodStart
	,SearchPeriodLength_Months
	,PostEDAdmitToHospitalLinkingPeriodLength_Hours
	,EDToEDLookforwardPeriodStartDelta_Days
	,EDToEDLookforwardPeriodLength_Days
	,EDToInpatientLookforwardPeriodStartDelta_Days
	,EDToInpatientLookforwardPeriodLength_Days
	,EDToPCPLookforwardPeriodStartDelta_Days
	,EDToPCPLookforwardPeriodLength_Days
	,StationID
)
VALUES
(
	@SearchPeriodStart
	,@SearchPeriodLength_Months
	,@PostEDAdmitToHospitalLinkingPeriodLength_Hours
	,@EDToEDLookforwardPeriodStartDelta_Days
	,@EDToEDLookforwardPeriodLength_Days
	,@EDToInpatientLookforwardPeriodStartDelta_Days
	,@EDToInpatientLookforwardPeriodLength_Days
	,@EDToPCPLookforwardPeriodStartDelta_Days
	,@EDToPCPLookforwardPeriodLength_Days
	,@StationID
)


GO



-- PLANNED HOSPITALIZATION ICD-10-CM + ICD-10-PCS CODES TABLES
-- ************************************************************************************************


-- Create tables
IF (OBJECT_ID('Dflt._pk_SETUP_PlannedHospitalization_ICD10CMCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_PlannedHospitalization_ICD10CMCodes
	END

CREATE TABLE Dflt._pk_SETUP_PlannedHospitalization_ICD10CMCodes
(
	ICD10CMCode VARCHAR(50)
)

IF (OBJECT_ID('Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes
	END

CREATE TABLE Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes
(
	ICD10PCSCode VARCHAR(50)
)


-- Compile codes
INSERT INTO Dflt._pk_SETUP_PlannedHospitalization_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T1_Plan_T1_AlwaysPlannedConditions AS ex


INSERT INTO Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes
SELECT ex.[ICD-10-PCS CODE]
FROM Dflt._pk_UTIL_EncounterTypeICD_T1_Plan_T1_AlwaysPlannedProcedures AS ex

INSERT INTO Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes
SELECT ex.[ICD-10-PCS CODE]
FROM Dflt._pk_UTIL_EncounterTypeICD_T1_Plan_T1_SometimesPlannedProcedures AS ex


GO



-- EXTERNAL CAUSES TO EXCLUDE ICD-10-CM CODES TABLES
-- ************************************************************************************************


-- Create tables
IF (OBJECT_ID('Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
	END

CREATE TABLE Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
(
	ICD10CMCode VARCHAR(50)
)


-- Compile codes
INSERT INTO Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T3_Accident_T1_ExternalCauses AS ex

INSERT INTO Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T3_Accident_T2_InjuryGeneral AS ex

INSERT INTO Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T3_Accident_T3_InjuryBloodVessels AS ex

INSERT INTO Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T3_Accident_T4_InjuryOrgan AS ex

INSERT INTO Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T3_Accident_T5_InjuryCNS AS ex

INSERT INTO Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T3_Accident_T6_InjuryUnspecified AS ex

INSERT INTO Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T3_Accident_T7_Fracture AS ex

INSERT INTO Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T3_Accident_T8_OpenWounds AS ex

INSERT INTO Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T3_Accident_T9_Toxic AS ex


GO




-- ================================================================================================
-- ================================================================================================
-- INCLUSION
-- ================================================================================================
-- ================================================================================================



-- STEP 01
-- ************************************************************************************************


--Variables
DECLARE @STEP01_v01_SearchStart DATETIME2
DECLARE @STEP01_v01_SearchEnd DATETIME2
DECLARE @STEP01_v01_Sta3n INT

SET @STEP01_v01_SearchStart = (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP01_v01_SearchEnd = DATEADD(MONTH, (SELECT params.SearchPeriodLength_Months FROM Dflt._pk_SETUP_ParameterTable AS params), (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params))
SET @STEP01_v01_Sta3n = (SELECT params.StationID FROM Dflt._pk_SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 01v01 - Search Period Start: ' + CAST(@STEP01_v01_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 01v01 - Search Period End: ' + CAST(@STEP01_v01_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 01v01 - Sta3n: ' + CAST(@STEP01_v01_Sta3n AS VARCHAR)


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_v01
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP01_v01
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get ED encounter records from search period
INSERT INTO Dflt._pk_INCLUSION_STEP01_v01
SELECT DISTINCT
	edl.PatientSID
	,edl.VisitSID
	,edl.PatientArrivalDateTime
	,edl.DispositionDateTime
FROM Src.EDIS_EDISLog AS edl
WHERE 
	edl.PatientArrivalDateTime BETWEEN
		@STEP01_v01_SearchStart
		AND
		@STEP01_v01_SearchEnd
	AND
	edl.Sta3n = @STEP01_v01_Sta3n
	AND
	edl.VisitSID != -1


GO



--Variables
DECLARE @STEP01_v02_EDToHospAdmitPeriodHours INT
DECLARE @STEP01_v02_SearchStart DATETIME2
DECLARE @STEP01_v02_SearchEnd DATETIME2
DECLARE @STEP01_v02_Sta3n INT

SET @STEP01_v02_EDToHospAdmitPeriodHours = (SELECT params.PostEDAdmitToHospitalLinkingPeriodLength_Hours FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP01_v02_SearchStart = (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP01_v02_SearchEnd = DATEADD(HOUR, @STEP01_v02_EDToHospAdmitPeriodHours, DATEADD(MONTH, (SELECT params.SearchPeriodLength_Months FROM Dflt._pk_SETUP_ParameterTable AS params), (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)))
SET @STEP01_v02_Sta3n = (SELECT params.StationID FROM Dflt._pk_SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 01v02 - ED to Hospital Admission Period (Hours): ' + CAST(@STEP01_v02_EDToHospAdmitPeriodHours AS VARCHAR)
PRINT 'Inclusion Step 01v02 - Search Period Start: ' + CAST(@STEP01_v02_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 01v02 - Search Period End: ' + CAST(@STEP01_v02_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 01v02 - Sta3n: ' + CAST(@STEP01_v02_Sta3n AS VARCHAR)


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_v02
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP01_v02
(
	PatientSID BIGINT
	,InpatientEncounterSID BIGINT
	,InpatientEncounterDateTime DATETIME2
)


-- Get inpatient encounter records in relevant period
INSERT INTO Dflt._pk_INCLUSION_STEP01_v02
SELECT DISTINCT
	inp.PatientSID
	,inp.InpatientSID
	,inp.AdmitDateTime
FROM Src.Inpat_Inpatient AS inp
WHERE 
	inp.AdmitDateTime BETWEEN
		@STEP01_v02_SearchStart
		AND
		@STEP01_v02_SearchEnd
	AND
	inp.Sta3n = @STEP01_v02_Sta3n
	AND
	inp.InpatientSID != -1


GO


--Variables
DECLARE @STEP01_v03_EDToHospAdmitPeriodHours INT

SET @STEP01_v03_EDToHospAdmitPeriodHours = (SELECT params.PostEDAdmitToHospitalLinkingPeriodLength_Hours FROM Dflt._pk_SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 01v03 - ED to Hospital Admission Period (Hours): ' + CAST(@STEP01_v03_EDToHospAdmitPeriodHours AS VARCHAR)


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_v03
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP01_v03
(
	IndexEncounterSID BIGINT
)


-- Get records from STEP01v01 that are followed by records from STEP01v02
INSERT INTO Dflt._pk_INCLUSION_STEP01_v03
SELECT DISTINCT
	prev.IndexEncounterSID
FROM
	Dflt._pk_INCLUSION_STEP01_v01 AS prev INNER JOIN Dflt._pk_INCLUSION_STEP01_v02 AS ex_inp ON
	(
		prev.PatientSID = ex_inp.PatientSID
		AND
		ex_inp.InpatientEncounterDateTime BETWEEN
			prev.IndexEncounterEndDateTime
			AND
			DATEADD(HOUR, @STEP01_v03_EDToHospAdmitPeriodHours, prev.IndexEncounterEndDateTime)
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_vFIN
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP01_vFIN
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get records from STEP01v01 that aren't in STEP01v03
INSERT INTO Dflt._pk_INCLUSION_STEP01_vFIN
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk_INCLUSION_STEP01_v01 AS prev
WHERE
	prev.IndexEncounterSID NOT IN 
	(
		SELECT t.IndexEncounterSID
		FROM Dflt._pk_INCLUSION_STEP01_v03 AS t
	)


GO



-- STEP 02
-- ************************************************************************************************


--Variables
DECLARE @STEP02_v01_EDToEDStart INT
DECLARE @STEP02_v01_EDToEDLength INT
DECLARE @STEP02_v01_SearchStart DATETIME2
DECLARE @STEP02_v01_SearchEnd DATETIME2
DECLARE @STEP02_v01_Sta3n INT

SET @STEP02_v01_EDToEDStart = (SELECT params.EDToEDLookforwardPeriodStartDelta_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v01_EDToEDLength = (SELECT params.EDToEDLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v01_SearchStart = (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v01_SearchEnd = DATEADD(DAY, @STEP02_v01_EDToEDLength, DATEADD(MONTH, (SELECT params.SearchPeriodLength_Months FROM Dflt._pk_SETUP_ParameterTable AS params), (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)))
SET @STEP02_v01_Sta3n = (SELECT params.StationID FROM Dflt._pk_SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 02v01 - ED-to-ED Period Start Delta (Days): ' + CAST(@STEP02_v01_EDToEDStart AS VARCHAR)
PRINT 'Inclusion Step 02v01 - ED-to-ED Period Length (Days): ' + CAST(@STEP02_v01_EDToEDLength AS VARCHAR)
PRINT 'Inclusion Step 02v01 - Search Period Start: ' + CAST(@STEP02_v01_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 02v01 - Search Period End: ' + CAST(@STEP02_v01_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 02v01 - Sta3n: ' + CAST(@STEP02_v01_Sta3n AS VARCHAR)


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v01
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_v01
(
	PatientSID BIGINT
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
)


-- Get ED encounter records from search period
INSERT INTO Dflt._pk_INCLUSION_STEP02_v01
SELECT DISTINCT
	edl.PatientSID
	,edl.VisitSID
	,edl.PatientArrivalDateTime
	,edl.DispositionDateTime
FROM Src.EDIS_EDISLog AS edl
WHERE 
	edl.PatientArrivalDateTime BETWEEN
		@STEP02_v01_SearchStart
		AND
		@STEP02_v01_SearchEnd
	AND
	edl.Sta3n = @STEP02_v01_Sta3n
	AND
	edl.VisitSID != -1


GO


--Variables
DECLARE @STEP02_v02_EDToEDStart INT
DECLARE @STEP02_v02_EDToEDLength INT
DECLARE @STEP02_v02_PostEDAdmitToInpatientLength INT
DECLARE @STEP02_v02_SearchStart DATETIME2
DECLARE @STEP02_v02_SearchEnd DATETIME2
DECLARE @STEP02_v02_Sta3n INT

SET @STEP02_v02_EDToEDStart = (SELECT params.EDToEDLookforwardPeriodStartDelta_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v02_EDToEDLength = (SELECT params.EDToEDLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v02_PostEDAdmitToInpatientLength = (SELECT params.PostEDAdmitToHospitalLinkingPeriodLength_Hours FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v02_SearchStart = (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v02_SearchEnd = DATEADD(HOUR, @STEP02_v02_PostEDAdmitToInpatientLength, DATEADD(DAY, @STEP02_v02_EDToEDLength, DATEADD(MONTH, (SELECT params.SearchPeriodLength_Months FROM Dflt._pk_SETUP_ParameterTable AS params), (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params))))
SET @STEP02_v02_Sta3n = (SELECT params.StationID FROM Dflt._pk_SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 02v02 - ED-to-ED Period Start Delta (Days): ' + CAST(@STEP02_v02_EDToEDStart AS VARCHAR)
PRINT 'Inclusion Step 02v02 - ED-to-ED Period Length (Days): ' + CAST(@STEP02_v02_EDToEDLength AS VARCHAR)
PRINT 'Inclusion Step 02v02 - PostED Admit to Inpatient Period Length (Hours): ' + CAST(@STEP02_v02_PostEDAdmitToInpatientLength AS VARCHAR)
PRINT 'Inclusion Step 02v02 - Search Period Start: ' + CAST(@STEP02_v02_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 02v02 - Search Period End: ' + CAST(@STEP02_v02_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 02v02 - Sta3n: ' + CAST(@STEP02_v02_Sta3n AS VARCHAR)


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v02
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_v02
(
	PatientSID BIGINT
	,InpatientEncounterSID BIGINT
	,InpatientEncounterStartDateTime DATETIME2
	,InpatientEncounterEndDateTime DATETIME2
)


-- Get ED encounter records from search period
INSERT INTO Dflt._pk_INCLUSION_STEP02_v02
SELECT DISTINCT
	inp.PatientSID
	,inp.InpatientSID
	,inp.AdmitDateTime
	,inp.DischargeDateTime
FROM Src.Inpat_Inpatient AS inp
WHERE 
	inp.AdmitDateTime BETWEEN
		@STEP02_v02_SearchStart
		AND
		@STEP02_v02_SearchEnd
	AND
	inp.Sta3n = @STEP02_v02_Sta3n
	AND
	inp.InpatientSID != -1


GO


--Variables
DECLARE @STEP02_v03_EDToEDStart INT
DECLARE @STEP02_v03_EDToEDLength INT
DECLARE @STEP02_v03_PostEDAdmitToInpatientLength INT
DECLARE @STEP02_v03_SearchStart DATETIME2
DECLARE @STEP02_v03_SearchEnd DATETIME2
DECLARE @STEP02_v03_Sta3n INT

SET @STEP02_v03_EDToEDStart = (SELECT params.EDToEDLookforwardPeriodStartDelta_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v03_EDToEDLength = (SELECT params.EDToEDLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v03_PostEDAdmitToInpatientLength = (SELECT params.PostEDAdmitToHospitalLinkingPeriodLength_Hours FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v03_SearchStart = (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v03_SearchEnd = DATEADD(HOUR, @STEP02_v03_PostEDAdmitToInpatientLength, DATEADD(DAY, @STEP02_v03_EDToEDLength, DATEADD(MONTH, (SELECT params.SearchPeriodLength_Months FROM Dflt._pk_SETUP_ParameterTable AS params), (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params))))
SET @STEP02_v03_Sta3n = (SELECT params.StationID FROM Dflt._pk_SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 02v03 - ED-to-ED Period Start Delta (Days): ' + CAST(@STEP02_v03_EDToEDStart AS VARCHAR)
PRINT 'Inclusion Step 02v03 - ED-to-ED Period Length (Days): ' + CAST(@STEP02_v03_EDToEDLength AS VARCHAR)
PRINT 'Inclusion Step 02v03 - PostED Admit to Inpatient Period Length (Hours): ' + CAST(@STEP02_v03_PostEDAdmitToInpatientLength AS VARCHAR)
PRINT 'Inclusion Step 02v03 - Search Period Start: ' + CAST(@STEP02_v03_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 02v03 - Search Period End: ' + CAST(@STEP02_v03_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 02v03 - Sta3n: ' + CAST(@STEP02_v03_Sta3n AS VARCHAR)


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v03
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_v03
(
	PatientSID BIGINT
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
)


-- Get ED encounter records from search period
INSERT INTO Dflt._pk_INCLUSION_STEP02_v03
SELECT DISTINCT
	prev.PatientSID
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
FROM
	Dflt._pk_INCLUSION_STEP02_v01 AS prev INNER JOIN Dflt._pk_INCLUSION_STEP02_v02 AS inp_ex ON
	(
		prev.PatientSID = inp_ex.PatientSID
		AND		
		inp_ex.InpatientEncounterStartDateTime BETWEEN
			prev.ReturnEncounterEndDateTime
			AND
			DATEADD(HOUR, @STEP02_v03_PostEDAdmitToInpatientLength, prev.ReturnEncounterEndDateTime)
	)


GO


--Variables
DECLARE @STEP02_v04_EDToEDStart INT
DECLARE @STEP02_v04_EDToEDLength INT
DECLARE @STEP02_v04_PostEDAdmitToInpatientLength INT
DECLARE @STEP02_v04_SearchStart DATETIME2
DECLARE @STEP02_v04_SearchEnd DATETIME2
DECLARE @STEP02_v04_Sta3n INT

SET @STEP02_v04_EDToEDStart = (SELECT params.EDToEDLookforwardPeriodStartDelta_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v04_EDToEDLength = (SELECT params.EDToEDLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v04_PostEDAdmitToInpatientLength = (SELECT params.PostEDAdmitToHospitalLinkingPeriodLength_Hours FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v04_SearchStart = (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v04_SearchEnd = DATEADD(HOUR, @STEP02_v04_PostEDAdmitToInpatientLength, DATEADD(DAY, @STEP02_v04_EDToEDLength, DATEADD(MONTH, (SELECT params.SearchPeriodLength_Months FROM Dflt._pk_SETUP_ParameterTable AS params), (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params))))
SET @STEP02_v04_Sta3n = (SELECT params.StationID FROM Dflt._pk_SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 02v04 - ED-to-ED Period Start Delta (Days): ' + CAST(@STEP02_v04_EDToEDStart AS VARCHAR)
PRINT 'Inclusion Step 02v04 - ED-to-ED Period Length (Days): ' + CAST(@STEP02_v04_EDToEDLength AS VARCHAR)
PRINT 'Inclusion Step 02v04 - PostED Admit to Inpatient Period Length (Hours): ' + CAST(@STEP02_v04_PostEDAdmitToInpatientLength AS VARCHAR)
PRINT 'Inclusion Step 02v04 - Search Period Start: ' + CAST(@STEP02_v04_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 02v04 - Search Period End: ' + CAST(@STEP02_v04_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 02v04 - Sta3n: ' + CAST(@STEP02_v04_Sta3n AS VARCHAR)


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v04
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_v04
(
	PatientSID BIGINT
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
)


-- Get ED encounter records from search period
INSERT INTO Dflt._pk_INCLUSION_STEP02_v04
SELECT DISTINCT
	prev.PatientSID
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
FROM
	Dflt._pk_INCLUSION_STEP02_v01 AS prev
WHERE
	prev.ReturnEncounterSID NOT IN
	(
		SELECT t.ReturnEncounterSID
		FROM Dflt._pk_INCLUSION_STEP02_v03 AS t
	)


GO


--Variables
DECLARE @STEP02_v05_EDToInpatientStart INT
DECLARE @STEP02_v05_EDToInpatientLength INT
DECLARE @STEP02_v05_SearchStart DATETIME2
DECLARE @STEP02_v05_SearchEnd DATETIME2
DECLARE @STEP02_v05_Sta3n INT

SET @STEP02_v05_EDToInpatientStart = (SELECT params.EDToInpatientLookforwardPeriodStartDelta_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v05_EDToInpatientLength = (SELECT params.EDToInpatientLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v05_SearchStart = (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v05_SearchEnd = DATEADD(DAY, @STEP02_v05_EDToInpatientLength, DATEADD(MONTH, (SELECT params.SearchPeriodLength_Months FROM Dflt._pk_SETUP_ParameterTable AS params), (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)))
SET @STEP02_v05_Sta3n = (SELECT params.StationID FROM Dflt._pk_SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 02v05 - ED-to-Inpatient Period Start Delta (Days): ' + CAST(@STEP02_v05_EDToInpatientStart AS VARCHAR)
PRINT 'Inclusion Step 02v05 - ED-to-Inpatient Period Length (Days): ' + CAST(@STEP02_v05_EDToInpatientLength AS VARCHAR)
PRINT 'Inclusion Step 02v05 - Search Period Start: ' + CAST(@STEP02_v05_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 02v05 - Search Period End: ' + CAST(@STEP02_v05_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 02v05 - Sta3n: ' + CAST(@STEP02_v05_Sta3n AS VARCHAR)


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v05
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_v05
(
	PatientSID BIGINT
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
)


-- Get inpatient encounter records from search period
INSERT INTO Dflt._pk_INCLUSION_STEP02_v05
SELECT DISTINCT
	inp.PatientSID
	,inp.InpatientSID
	,inp.AdmitDateTime
	,inp.DischargeDateTime
FROM Src.Inpat_Inpatient AS inp
WHERE 
	inp.AdmitDateTime BETWEEN
		@STEP02_v05_SearchStart
		AND
		@STEP02_v05_SearchEnd
	AND
	inp.Sta3n = @STEP02_v05_Sta3n
	AND
	inp.InpatientSID != -1


GO


--Variables
DECLARE @STEP02_v06_EDToPCPStart INT
DECLARE @STEP02_v06_EDToPCPLength INT
DECLARE @STEP02_v06_SearchStart DATETIME2
DECLARE @STEP02_v06_SearchEnd DATETIME2
DECLARE @STEP02_v06_Sta3n INT

SET @STEP02_v06_EDToPCPStart = (SELECT params.EDToPCPLookforwardPeriodStartDelta_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v06_EDToPCPLength = (SELECT params.EDToPCPLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v06_SearchStart = (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)
SET @STEP02_v06_SearchEnd = DATEADD(DAY, @STEP02_v06_EDToPCPLength, DATEADD(MONTH, (SELECT params.SearchPeriodLength_Months FROM Dflt._pk_SETUP_ParameterTable AS params), (SELECT params.SearchPeriodStart FROM Dflt._pk_SETUP_ParameterTable AS params)))
SET @STEP02_v06_Sta3n = (SELECT params.StationID FROM Dflt._pk_SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 02v06 - ED-to-PCP Period Start Delta (Days): ' + CAST(@STEP02_v06_EDToPCPStart AS VARCHAR)
PRINT 'Inclusion Step 02v06 - ED-to-PCP Period Length (Days): ' + CAST(@STEP02_v06_EDToPCPLength AS VARCHAR)
PRINT 'Inclusion Step 02v06 - Search Period Start: ' + CAST(@STEP02_v06_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 02v06 - Search Period End: ' + CAST(@STEP02_v06_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 02v06 - Sta3n: ' + CAST(@STEP02_v06_Sta3n AS VARCHAR)


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v06') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v06
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_v06
(
	PatientSID BIGINT
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
)


-- Get PCP encounter records from search period
INSERT INTO Dflt._pk_INCLUSION_STEP02_v06
SELECT DISTINCT
	owl.PatientSID
	,owl.VisitSID
	,owl.VisitDateTime
	,owl.COProcessCompleteDateTime
FROM
	Src.Outpat_Workload AS owl LEFT JOIN CDWWork.Dim.StopCode AS stopcode1 ON
	(
		owl.PrimaryStopCodeSID = stopcode1.StopCodeSID
	)
		LEFT JOIN CDWWork.Dim.StopCode AS stopcode2 ON
		(
			owl.PrimaryStopCodeSID = stopcode2.StopCodeSID
		)
WHERE 
	owl.VisitDateTime BETWEEN
		@STEP02_v06_SearchStart
		AND
		@STEP02_v06_SearchEnd
	AND
	owl.Sta3n = @STEP02_v06_Sta3n
	AND
	owl.VisitSID != -1
	AND
	(
		(
			--PCP Stop Codes
			stopcode1.StopCode IN
			(
				--156		-- Home-Based Primary Care - Psychologist
				157	-- Home-Based Primary Care - Psychiatrist
				,170	-- Hospital-Based Home Care???????????????????????????????????????????????????????????????????????????????????????????????????????????????????
				--,171	-- Home-Based Primary Care - RN or LPN
				--,172	-- Hospital-Based Home Care (extender)???????????????????????????????????????????????????????????????????????????????????????????????????????????????????
				--,173	-- Home-Based Primary Care - Social Worker
				--,174	-- Home-Based Primary Care - Therapist
				--,175	-- Home-Based Primary Care - Dietician
				--,176	-- Home-Based Primary Care - Clinical Pharmacist
				,177	-- Home-Based Primary Care - Other
				,178	-- Home-Based Primary Care - Telephone
				,301	-- General Internal Medicine
				,322	-- Women's Clinic/Comprehensive Woman's Primary Clinic
				,323	-- Primary Care Medicine
				,338	-- Telephone Primary Care !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!EXCLUDE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				,348	-- Primary Care Group/Shared Appointment
				,350	-- Geripact/Geriatric Primary Care					
				,531	-- Mental Health Primary Care (Indivdual)
				,534	-- Mental Health Integrated Care (Individual)
				,539	-- Mental Health Integrated Care (Group)
				--,634	-- Can't find????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
			)
			OR
			ISNULL(stopcode2.StopCode, 0) IN
			(
				--156	-- Home-Based Primary Care - Psychologist
				157	-- Home-Based Primary Care - Psychiatrist
				,170	-- Hospital-Based Home Care???????????????????????????????????????????????????????????????????????????????????????????????????????????????????
				--,171	-- Home-Based Primary Care - RN or LPN
				--,172	-- Hospital-Based Home Care (extender)???????????????????????????????????????????????????????????????????????????????????????????????????????????????????
				--,173	-- Home-Based Primary Care - Social Worker
				--,174	-- Home-Based Primary Care - Therapist
				--,175	-- Home-Based Primary Care - Dietician
				--,176	-- Home-Based Primary Care - Clinical Pharmacist
				,177	-- Home-Based Primary Care - Other
				,178	-- Home-Based Primary Care - Telephone
				,301	-- General Internal Medicine
				,322	-- Women's Clinic/Comprehensive Woman's Primary Clinic
				,323	-- Primary Care Medicine
				,338	-- Telephone Primary Care !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!EXCLUDE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				,348	-- Primary Care Group/Shared Appointment
				,350	-- Geripact/Geriatric Primary Care
				,531	-- Mental Health Primary Care (Indivdual)
				,534	-- Mental Health Integrated Care (Individual)
				,539	-- Mental Health Integrated Care (Group)				
				--,634	-- Can't find????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
			)		
		)
		AND 
		ISNULL(stopcode2.StopCode, 0) NOT IN 
		(
			107		-- EKG
			,115	-- Ultrasound
			,152	-- Angiogram Catherization
			,311	-- Cardiac Implantable Electronic Devices
			,321	-- GI Endoscopy
			,328	-- Medical/Surgery Day Unit
			,329	-- Medical Procedure Unit
			,333	-- Cardiac Catherization
			,334	-- Cardiac Stress Test
			,430	-- Cysto Room in Urology Clinic
			,435	-- Surgical Procedure Unit
			,474	-- Research
			,999	-- Don't know????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
		)
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v07') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v07
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_v07
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
)


-- Get ED encounters that were after other ED encounters 
INSERT INTO Dflt._pk_INCLUSION_STEP02_v07
SELECT DISTINCT
	prev.PatientSID
	,idx_ed.IndexEncounterSID
	,idx_ed.IndexEncounterStartDateTime
	,idx_ed.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
FROM
	Dflt._pk_INCLUSION_STEP02_v04 AS prev INNER JOIN Dflt._pk_INCLUSION_STEP01_vFIN AS idx_ed ON
	(
		prev.PatientSID = idx_ed.PatientSID
		AND
		prev.ReturnEncounterStartDateTime BETWEEN
			DATEADD(DAY, (SELECT params.EDToEDLookforwardPeriodStartDelta_Days FROM Dflt._pk_SETUP_ParameterTable AS params), idx_ed.IndexEncounterEndDateTime)
			AND
			DATEADD(DAY, (SELECT params.EDToEDLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params), idx_ed.IndexEncounterEndDateTime)
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v08') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v08
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_v08
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
)


-- Get Inpatient encounters that were after ED encounters 
INSERT INTO Dflt._pk_INCLUSION_STEP02_v08
SELECT DISTINCT
	prev.PatientSID
	,idx_ed.IndexEncounterSID
	,idx_ed.IndexEncounterStartDateTime
	,idx_ed.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
FROM
	Dflt._pk_INCLUSION_STEP02_v05 AS prev INNER JOIN Dflt._pk_INCLUSION_STEP01_vFIN AS idx_ed ON
	(
		prev.PatientSID = idx_ed.PatientSID
		AND
		prev.ReturnEncounterStartDateTime BETWEEN
			DATEADD(DAY, (SELECT params.EDToInpatientLookforwardPeriodStartDelta_Days FROM Dflt._pk_SETUP_ParameterTable AS params), idx_ed.IndexEncounterEndDateTime)
			AND
			DATEADD(DAY, (SELECT params.EDToInpatientLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params), idx_ed.IndexEncounterEndDateTime)
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v09') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v09
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_v09
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
)


-- Get Inpatient encounters that were after ED encounters
INSERT INTO Dflt._pk_INCLUSION_STEP02_v09
SELECT DISTINCT
	prev.PatientSID
	,idx_ed.IndexEncounterSID
	,idx_ed.IndexEncounterStartDateTime
	,idx_ed.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
FROM
	Dflt._pk_INCLUSION_STEP02_v06 AS prev INNER JOIN Dflt._pk_INCLUSION_STEP01_vFIN AS idx_ed ON
	(
		prev.PatientSID = idx_ed.PatientSID
		AND
		prev.ReturnEncounterStartDateTime BETWEEN
			DATEADD(DAY, (SELECT params.EDToPCPLookforwardPeriodStartDelta_Days FROM Dflt._pk_SETUP_ParameterTable AS params), idx_ed.IndexEncounterEndDateTime)
			AND
			DATEADD(DAY, (SELECT params.EDToPCPLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params), idx_ed.IndexEncounterEndDateTime)
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_vFIN
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_vFIN
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
	,ReturnType VARCHAR(50)
	,SPFlag SMALLINT
)


-- Compile all Index Encounter - Return Encounter dyads into one table
INSERT INTO Dflt._pk_INCLUSION_STEP02_vFIN
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,'EDToED'
	,-1
FROM Dflt._pk_INCLUSION_STEP02_v07 AS prev

INSERT INTO Dflt._pk_INCLUSION_STEP02_vFIN
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,'EDToInpatient'
	,-1
FROM Dflt._pk_INCLUSION_STEP02_v08 AS prev

INSERT INTO Dflt._pk_INCLUSION_STEP02_vFIN
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,'EDToPCP'
	,-1
FROM Dflt._pk_INCLUSION_STEP02_v09 AS prev


GO



-- STEP 03
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP03_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP03_vFIN
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP03_vFIN
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
	,ReturnType VARCHAR(50)
	,SPFlag SMALLINT
)


-- Select Earliest return visits for each index visit
INSERT INTO Dflt._pk_INCLUSION_STEP03_vFIN
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,prev.ReturnType
	,prev.SPFlag
FROM Dflt._pk_INCLUSION_STEP02_vFIN AS prev
WHERE
	prev.ReturnEncounterSID =
	(
		SELECT TOP 1 t.ReturnEncounterSID
		FROM Dflt._pk_INCLUSION_STEP02_vFIN AS t
		WHERE
			t.PatientSID = prev.PatientSID
			AND
			t.IndexEncounterSID = prev.IndexEncounterSID
		ORDER BY t.ReturnEncounterSID ASC
	)


GO



-- Step 04
-- ************************************************************************************************


-- create tables
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP04_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP04_vFIN
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP04_vFIN
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
	,ReturnType VARCHAR(50)
	,SPFlag SMALLINT
)


-- select dyads based on specific diagnostic discrepancies
-- Selects the dyads with correct diagnostic codes for resp diagnostic discrepancy
INSERT INTO Dflt._pk_INCLUSION_STEP04_vFIN
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,prev.ReturnType
	,1
FROM 
	Dflt._pk_INCLUSION_STEP03_vFIN AS prev LEFT JOIN Src.Outpat_WorkloadVDiagnosis AS owld1 ON
	(
		prev.IndexEncounterSID = owld1.VisitSID
	)
		LEFT JOIN CDWWork.Dim.ICD10 AS icd10_1 ON
		(
			owld1.ICD10SID = icd10_1.ICD10SID
		)
			LEFT JOIN Src.Outpat_WorkloadVDiagnosis AS owld2 ON
			(
				prev.ReturnEncounterSID = owld2.VisitSID
			)
				LEFT JOIN CDWWork.Dim.ICD10 AS icd10_2 ON
				(
					owld2.ICD10SID = icd10_2.ICD10SID
				)
WHERE
	(
		-- URI
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J06%'
		OR
		-- Cough
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'R05'
	)
	AND NOT
	(
		-- New Pneumonia
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J12%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J13%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J14%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J15%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J16%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J17%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J18%'
		OR

		-- COPD Exacerbation
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J440'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J441'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'J449'
		OR

		-- CHF Exacerbation
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'I5021'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'I5023'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'I5031'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'I5033'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'I5041'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'I5043'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'I50811'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'I50813'
	)
	AND
	(
		-- New Pneumonia
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J12%'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J13%'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J14%'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J15%'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J16%'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J17%'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J18%'
		OR

		-- COPD Exacerbation
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J440'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J441'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'J449'
		OR

		-- CHF Exacerbation
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'I5021'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'I5023'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'I5031'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'I5033'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'I5041'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'I5043'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'I50811'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'I50813'
	)
	AND
	prev.ReturnType LIKE 'EDToPCP'

-- Selects the dyads with correct diagnostic codes for abdominal diagnostic discrepancy
INSERT INTO Dflt._pk_INCLUSION_STEP04_vFIN
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,prev.ReturnType
	,2
FROM 
	Dflt._pk_INCLUSION_STEP03_vFIN AS prev LEFT JOIN Src.Outpat_WorkloadVDiagnosis AS owld1 ON
	(
		prev.IndexEncounterSID = owld1.VisitSID
	)
		LEFT JOIN CDWWork.Dim.ICD10 AS icd10_1 ON
		(
			owld1.ICD10SID = icd10_1.ICD10SID
		)
			LEFT JOIN Src.Outpat_WorkloadVDiagnosis AS owld2 ON
			(
				prev.ReturnEncounterSID = owld2.VisitSID
			)
				LEFT JOIN CDWWork.Dim.ICD10 AS icd10_2 ON
				(
					owld2.ICD10SID = icd10_2.ICD10SID
				)
WHERE
	(
		-- UTI
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'N390'
		OR
		-- Non-specific Abdominal Pain
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'R10%'
	)
	AND NOT
	(
		-- Diverticulitis
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'K57%'
		OR

		-- Pyelonephritis
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'N10%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'N111'
		OR

		-- Appendicitis
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'K35%'
	)
	AND
	(
		-- Diverticulitis
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'K57%'
		OR

		-- Pyelonephritis
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'N10%'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'N111'
		OR

		-- Appendicitis
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'K35%'
	)
	AND
	prev.ReturnType LIKE 'EDToPCP'

-- Selects the dyads with correct diagnostic codes for MSK diagnostic discrepancy
INSERT INTO Dflt._pk_INCLUSION_STEP04_vFIN
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,prev.ReturnType
	,3
FROM 
	Dflt._pk_INCLUSION_STEP03_vFIN AS prev LEFT JOIN Src.Outpat_WorkloadVDiagnosis AS owld1 ON
	(
		prev.IndexEncounterSID = owld1.VisitSID
	)
		LEFT JOIN CDWWork.Dim.ICD10 AS icd10_1 ON
		(
			owld1.ICD10SID = icd10_1.ICD10SID
		)
			LEFT JOIN Src.Outpat_WorkloadVDiagnosis AS owld2 ON
			(
				prev.ReturnEncounterSID = owld2.VisitSID
			)
				LEFT JOIN CDWWork.Dim.ICD10 AS icd10_2 ON
				(
					owld2.ICD10SID = icd10_2.ICD10SID
				)
WHERE
	(
		-- Non-specific MSK Symptoms/Diagnoses
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'M6283%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'S039%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'M7966%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'M7962%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'M255%'
	)
	AND NOT
	(
		-- Fracture
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'M84%'
		OR

		-- Cellulitis
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'L03%'
		OR

		-- SEA
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'G061'
		OR

		-- Discitis
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'M464%'
		OR

		-- Pyelonephritis
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'N10%'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'N111'
	)
	AND
	(
		-- Fracture
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'M84%'
		OR

		-- Cellulitis
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'L03%'
		OR

		-- SEA
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'G061'
		OR

		-- Discitis
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'M464%'
		OR

		-- Pyelonephritis
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'N10%'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'N111'
	)
	AND
	prev.ReturnType LIKE 'EDToPCP'

-- Selects the dyads with correct diagnostic codes for MSK diagnostic discrepancy
INSERT INTO Dflt._pk_INCLUSION_STEP04_vFIN
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,prev.ReturnType
	,4
FROM 
	Dflt._pk_INCLUSION_STEP03_vFIN AS prev LEFT JOIN Src.Outpat_WorkloadVDiagnosis AS owld1 ON
	(
		prev.IndexEncounterSID = owld1.VisitSID
	)
		LEFT JOIN CDWWork.Dim.ICD10 AS icd10_1 ON
		(
			owld1.ICD10SID = icd10_1.ICD10SID
		)
			LEFT JOIN Src.Outpat_WorkloadVDiagnosis AS owld2 ON
			(
				prev.ReturnEncounterSID = owld2.VisitSID
			)
				LEFT JOIN CDWWork.Dim.ICD10 AS icd10_2 ON
				(
					owld2.ICD10SID = icd10_2.ICD10SID
				)
WHERE
	(
		-- Headache
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'R51'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'G43*'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'G44*'
	)
	AND NOT
	(
		-- Temporal Arteritis
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'M315'
		OR
		REPLACE(icd10_1.ICD10Code, '.', '') LIKE 'M316'
	)
	AND
	(
		-- Temporal Arteritis
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'M315'
		OR
		REPLACE(icd10_2.ICD10Code, '.', '') LIKE 'M316'
	)
	AND
	prev.ReturnType LIKE 'EDToPCP'

-- selects for all other non-edtopcp records that don't have any diagnostic codes for inclusion criteria
INSERT INTO Dflt._pk_INCLUSION_STEP04_vFIN
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,prev.ReturnType
	,prev.SPFlag
FROM 
	Dflt._pk_INCLUSION_STEP03_vFIN AS prev
WHERE
	prev.ReturnType NOT LIKE 'EDToPCP'
	

GO



-- CONCLUSION
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk_INCLUSION_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_CONCLUSION
	END

CREATE TABLE Dflt._pk_INCLUSION_CONCLUSION
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
	,ReturnType VARCHAR(50)
	,SPFlag SMALLINT
)


-- Select Earliest return visits for each index visit
INSERT INTO Dflt._pk_INCLUSION_CONCLUSION
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,prev.ReturnType
	,prev.SPFlag
FROM Dflt._pk_INCLUSION_STEP04_vFIN AS prev




-- ================================================================================================
-- ================================================================================================
-- EXCLUSION
-- ================================================================================================
-- ================================================================================================



-- STEP 01
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_v01
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP01_v01
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get all unique index encounters and patients
INSERT INTO Dflt._pk_EXCLUSION_STEP01_v01
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk_INCLUSION_CONCLUSION AS prev


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_v02
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP01_v02
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,TypeDischarge VARCHAR(50)
)


-- Get records with discharge for hospice
INSERT INTO Dflt._pk_EXCLUSION_STEP01_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,'Nursing'
FROM
	Dflt._pk_EXCLUSION_STEP01_v01 AS prev INNER JOIN Src.EDIS_EDISLog AS edis ON
	(
		prev.IndexEncounterSID = edis.VisitSID
	)
		INNER JOIN CDWWork.Dim.EDISTrackingCode AS etc ON
		(
			edis.DispositionEDISTrackingCodeSID = etc.EDISTrackingCodeSID
		)
WHERE
	etc.TrackingCodeName LIKE '%NURSING%'

INSERT INTO Dflt._pk_EXCLUSION_STEP01_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,'AMA'
FROM
	Dflt._pk_EXCLUSION_STEP01_v01 AS prev INNER JOIN Src.EDIS_EDISLog AS edis ON
	(
		prev.IndexEncounterSID = edis.VisitSID
	)
		INNER JOIN CDWWork.Dim.EDISTrackingCode AS etc ON
		(
			edis.DispositionEDISTrackingCodeSID = etc.EDISTrackingCodeSID
		)
WHERE
	etc.TrackingCodeName LIKE '%AMA%'
	AND
	etc.EDISTrackingCodeSID NOT IN	--Rule out things that aret AMA that have the letters AMA in them
	(
		800001595
		,800002592
		,1000000290
		,1000000866
		,1000002855
		,1200002834
		,1400002744
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_vFIN
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP01_vFIN
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
	,ReturnType VARCHAR(50)
	,SPFlag SMALLINT
)


-- Select Earliest return visits for each index visit
INSERT INTO Dflt._pk_EXCLUSION_STEP01_vFIN
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,prev.ReturnType
	,prev.SPFlag
FROM Dflt._pk_INCLUSION_CONCLUSION AS prev
WHERE
	prev.IndexEncounterSID NOT IN
	(
		SELECT t.IndexEncounterSID
		FROM Dflt._pk_EXCLUSION_STEP01_v02 AS t
	)
	AND
	prev.ReturnType LIKE 'EDToPCP'


GO



-- CONCLUSION
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_CONCLUSION
	END

CREATE TABLE Dflt._pk_EXCLUSION_CONCLUSION
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
	,ReturnType VARCHAR(50)
	,SPFlag SMALLINT
)


-- Select Earliest return visits for each index visit
INSERT INTO Dflt._pk_EXCLUSION_CONCLUSION
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,prev.ReturnType
	,prev.SPFlag
FROM Dflt._pk_EXCLUSION_STEP01_vFIN AS prev



GO




-- ================================================================================================
-- ================================================================================================
-- RESULTS
-- ================================================================================================
-- ================================================================================================


-- Create tables 
IF (OBJECT_ID('Dflt._pk_RESULTS_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_RESULTS_CONCLUSION
	END

CREATE TABLE Dflt._pk_RESULTS_CONCLUSION
(
	PatientSSN BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,IndexEncounterState VARCHAR(50)
	,IndexEncounteCity VARCHAR(50)
	,ReturnEncounterSID BIGINT
	,ReturnEncounterStartDateTime DATETIME2
	,ReturnEncounterEndDateTime DATETIME2
	,ReturnEncounterState VARCHAR(50)
	,ReturnEncounterCity VARCHAR(50)
	,ReturnType VARCHAR(50)
	,SPFlag INT
	,StopCode1 VARCHAR(1000)
	,StopCode1Desc VARCHAR(1000)
	,StopCode2 VARCHAR(1000)
	,StopCode2Desc VARCHAR(1000)
)


-- Save records in result format with additional info needed for hcart review
INSERT INTO Dflt._pk_RESULTS_CONCLUSION
SELECT
	sp.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,i_stt.[State]
	,i_sta.City
	,prev.ReturnEncounterSID
	,prev.ReturnEncounterStartDateTime
	,prev.ReturnEncounterEndDateTime
	,r_stt.[State]
	,r_sta.City
	,prev.ReturnType
	,prev.SPFlag
	,stopcode1.StopCode
	,stopcode1.StopCodeName
	,stopcode2.StopCode
	,stopcode2.StopCodeName
FROM
	Dflt._pk_EXCLUSION_CONCLUSION AS prev LEFT JOIN Src.Outpat_Workload AS i_owl ON
	(
		i_owl.VisitSID = prev.IndexEncounterSID
	)
		LEFT JOIN CDWWork.Dim.Sta3n AS i_sta ON
		(
			i_sta.Sta3n = i_owl.Sta3n
		)
			LEFT JOIN CDWWork.Dim.[State] AS i_stt ON
			(
				i_sta.StateSID = i_stt.StateSID
			)
				LEFT JOIN Src.Outpat_Workload AS r_owl ON
				(
					r_owl.VisitSID = prev.ReturnEncounterSID
				)
					LEFT JOIN CDWWork.Dim.Sta3n AS r_sta ON
					(
						r_sta.Sta3n = r_owl.Sta3n
					)
						LEFT JOIN CDWWork.Dim.[State] AS r_stt ON
						(
							r_sta.StateSID = r_stt.StateSID
						)
							INNER JOIN Src.SPatient_SPatient AS sp on
							(
								sp.PatientSID = prev.PatientSID
							)
								LEFT JOIN CDWWork.Dim.StopCode AS stopcode1 ON
								(
									r_owl.PrimaryStopCodeSID = stopcode1.StopCodeSID
								)
									LEFT JOIN CDWWork.Dim.StopCode AS stopcode2 ON
									(
										r_owl.PrimaryStopCodeSID = stopcode2.StopCodeSID
									)
WHERE
	prev.ReturnType LIKE 'EDToPCP'


GO




-- ================================================================================================
-- ================================================================================================
-- DISPLAY + CLEAN UP
-- ================================================================================================
-- ================================================================================================



-- DISPLAY RESULTS
-- ************************************************************************************************


-- Print
IF (OBJECT_ID('Dflt._pk_RESULTS_AHRQML_PostEDReturnToPCP') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_RESULTS_AHRQML_PostEDReturnToPCP
	END

SELECT * 
INTO Dflt._pk_RESULTS_AHRQML_PostEDReturnToPCP
FROM Dflt._pk_RESULTS_CONCLUSION

SELECT * FROM Dflt._pk_RESULTS_AHRQML_PostEDReturnToPCP


GO



-- DELETE TABLES
-- ************************************************************************************************


-- Set Up
IF (OBJECT_ID('Dflt._pk_SETUP_ParameterTable') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_ParameterTable
	END

IF (OBJECT_ID('Dflt._pk_SETUP_PlannedHospitalization_ICD10CMCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_PlannedHospitalization_ICD10CMCodes
	END

IF (OBJECT_ID('Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes
	END

IF (OBJECT_ID('Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_EncounterForAccident_ICD10CMCodes
	END


-- Inclusion
IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_v01
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_v02
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_v03
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_vFIN
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v01
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v02
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v03
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v04
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v05
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v06') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v06
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v07') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v07
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v08') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v08
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_v09') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_v09
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_vFIN
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP03_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP03_vFIN
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP04_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP04_vFIN
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_CONCLUSION
	END


-- Exclusion
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_v01
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_v02
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_vFIN
	END


-- Results
IF (OBJECT_ID('Dflt._pk_RESULTS_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_RESULTS_CONCLUSION
	END

	
GO