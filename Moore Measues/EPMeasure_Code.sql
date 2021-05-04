-- Title: Emergency Cancer Diagnosis eMeasure
-- Author: Paarth Kapadia

USE ORD_Singh_202001030D
GO

-- PARAMETER TABLE ================================================================================

-- Declare Parameter Variables
DECLARE @Search_Start DATETIME2
DECLARE @Search_Length_Months INT
DECLARE @Exclude_Length_Years INT
DECLARE @Lookback_Length_Days INT
DECLARE @CareHx_Length_Months INT

-- Set Parameter Variables
SET @Search_Start = '2019-01-01'
SET @Search_Length_Months = 12
SET @Exclude_Length_Years = -50
SET @Lookback_Length_Days = -30
SET @CareHx_Length_Months = 24

-- Create Parameter Table
IF (OBJECT_ID('Dflt._pk_ParameterTable') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_ParameterTable
	END

CREATE TABLE Dflt._pk_ParameterTable
(
	Search_Start DATETIME2
	,Search_Length_Months INT
	,Exclude_Length_Years INT
	,Lookback_Length_Days INT
	,CareHx_Length_Months INT
)

-- Insert Variables into Parameter Table
INSERT INTO Dflt._pk_ParameterTable
(
	Search_Start
	,Search_Length_Months
	,Exclude_Length_Years
	,Lookback_Length_Days
	,CareHx_Length_Months
)
VALUES
(
	@Search_Start
	,@Search_Length_Months
	,@Exclude_Length_Years
	,@Lookback_Length_Days
	,@CareHx_Length_Months
)
GO




-- PLANNED HOSPITALIZATION ICD-10-CM + ICD-10-PCS CODES TABLES ====================================

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




-- ************************************************************************************************
-- INCLUSION
-- ************************************************************************************************

-- I.01.A ---------------------------------------------------------------------------------------- 

-- Set the search period
DECLARE @STEP01_SearchStart DATETIME2
DECLARE @STEP01_SearchEnd DATETIME2

SET @STEP01_SearchStart = (SELECT params.Search_Start FROM Dflt._pk_ParameterTable AS params)
SET @STEP01_SearchEnd = DATEADD(MONTH, (SELECT params.Search_Length_Months FROM Dflt._pk_ParameterTable AS params), (SELECT params.Search_Start FROM Dflt._pk_ParameterTable AS params))

PRINT CHAR(13) + CHAR(10) + 'Step 01 - Search Period Start: ' + CAST(@STEP01_SearchStart AS VARCHAR)
PRINT 'Step 01 - Search Period End: ' + CAST(@STEP01_SearchEnd AS VARCHAR)

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_Z
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP01_Z
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,TypeOfEvent VARCHAR(50)
)

-- Get outpatient encounters with a diagnostic code associated with the cancer of study
INSERT INTO Dflt._pk_INCLUSION_STEP01_Z
SELECT DISTINCT sp.PatientSSN
    ,owl.PatientSID
    ,owl.VisitSID
    ,owl.VisitDateTime
    ,'OUTPATIENT ENCOUNTER'
FROM Src.Outpat_Workload AS owl
INNER JOIN Src.Outpat_WorkloadVDiagnosis AS owld ON (owl.VisitSID = owld.VisitSID)
INNER JOIN Src.SPatient_SPatient AS sp ON (owl.PatientSID = sp.PatientSID)
LEFT JOIN CDWWork.Dim.ICD10 AS icd10 ON (owld.ICD10SID = icd10.ICD10SID)
LEFT JOIN CDWWork.Dim.ICD9 AS icd9 ON (owld.ICD9SID = icd9.ICD9SID)
-- <<<<!CANCER SELECTION ZONE START!>>>>
WHERE (
        (
            icd10.ICD10Code LIKE '%C18%' OR icd10.ICD10Code LIKE '%C19%' OR icd10.ICD10Code LIKE '%C20%' -- COLORECTAL CANCER
            --icd10.ICD10Code LIKE '%C34%'		-- LUNG CANCER
            --icd10.ICD10Code LIKE '%C61%'		-- PROSTATE CANCER
            )
        OR (
            icd9.ICD9Code LIKE '153%' OR icd9.ICD9Code LIKE '154.0%' OR icd9.ICD9Code LIKE '154.1%' -- COLORECTAL CANCER
            --icd9.ICD9Code LIKE '162%'			-- LUNG CANCER
            --icd9.ICD9Code LIKE '185%'			-- PROSTATE CANCER
            )
        )
    AND owl.VisitDateTime BETWEEN @STEP01_SearchStart
        AND @STEP01_SearchEnd












-- Get inpatient encounters with a diagnostic code associated with the cancer of study
INSERT INTO Dflt._pk_INCLUSION_STEP01_Z
SELECT DISTINCT sp.PatientSSN
    ,inp.PatientSID
    ,inp.InpatientSID
    ,inp.AdmitDateTime
    ,'INPATIENT ENCOUNTER'
FROM Src.Inpat_Inpatient AS inp
INNER JOIN Src.Inpat_InpatientDiagnosis AS inpd ON (inp.InpatientSID = inpd.InpatientSID)
INNER JOIN Src.SPatient_SPatient AS sp ON (inp.PatientSID = sp.PatientSID)
LEFT JOIN CDWWork.Dim.ICD10 AS icd10 ON (inpd.ICD10SID = icd10.ICD10SID)
LEFT JOIN CDWWork.Dim.ICD9 AS icd9 ON (inpd.ICD9SID = icd9.ICD9SID)
WHERE (
        (
            icd10.ICD10Code LIKE '%C18%' -- COLORECTAL CANCER
            OR icd10.ICD10Code LIKE '%C19%' -- COLORECTAL CANCER
            OR icd10.ICD10Code LIKE '%C20%' -- COLORECTAL CANCER
            --OR
            --icd10.ICD10Code LIKE '%C34%'		-- LUNG CANCER
            --OR
            --icd10.ICD10Code LIKE '%C61%'		-- PROSTATE CANCER
            )
        OR (
            icd9.ICD9Code LIKE '153%' -- COLORECTAL CANCER
            OR icd9.ICD9Code LIKE '154.0%' -- COLORECTAL CANCER
            OR icd9.ICD9Code LIKE '154.1%' -- COLORECTAL CANCER
            --OR
            --icd9.ICD9Code LIKE '162%'			-- LUNG CANCER
            --OR
            --icd9.ICD9Code LIKE '185%'			-- PROSTATE CANCER
            )
        )
    AND inp.AdmitDateTime BETWEEN @STEP01_SearchStart
        AND @STEP01_SearchEnd

-- Get cancer registry entries associated with the cancer of study
INSERT INTO Dflt._pk_INCLUSION_STEP01_Z
SELECT DISTINCT sp.PatientSSN
    ,reg.PatientSID
    ,reg.OncologyPrimaryIEN
    ,reg.DateDX
    ,'REGISTRY ENTRY'
FROM Src.Oncology_Oncology_Primary_165_5 AS reg
INNER JOIN Src.SPatient_SPatient AS sp ON (reg.PatientSID = sp.PatientSID)
WHERE reg.DateDX BETWEEN @STEP01_SearchStart
        AND @STEP01_SearchEnd
    AND (
        (
            reg.SitegpX LIKE 'COLO%'
            OR reg.ICDOSite LIKE 'COLO%'
            OR reg.PrimarysiteX LIKE 'COLO%'
            )
        OR (
            reg.SitegpX LIKE 'RECT%'
            OR reg.ICDOSite LIKE 'RECT%'
            OR reg.PrimarysiteX LIKE 'RECT%'
            )
        --OR
        --(
        --reg.SitegpX LIKE 'LUNG%'
        --OR
        --reg.ICDOSite LIKE 'LUNG%'
        --OR
        --reg.PrimarysiteX LIKE 'LUNG%'
        --)
        --OR
        --(
        --	reg.SitegpX LIKE 'PROSTATE%'
        --	OR
        --	reg.ICDOSite LIKE 'PROSTATE%'
        --	OR
        --	reg.PrimarysiteX LIKE 'PROSTATE%'
        --)
        )
GO




-- I.02.A ---------------------------------------------------------------------------------------- 

-- Set the exclusion period 
DECLARE @STEP02_ExcludeStart DATETIME2
DECLARE @STEP02_ExcludeEnd DATETIME2

SET @STEP02_ExcludeStart = DATEADD(YEAR, (SELECT params.Exclude_Length_Years FROM Dflt._pk_ParameterTable AS params), (SELECT params.Search_Start FROM Dflt._pk_ParameterTable AS params))
SET @STEP02_ExcludeEnd = (SELECT params.Search_Start FROM Dflt._pk_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Step 02 - Exclusion Period Start: ' + CAST(@STEP02_ExcludeStart AS VARCHAR)
PRINT 'Step 02 - Exclusion Period End: ' + CAST(@STEP02_ExcludeEnd AS VARCHAR)

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_Z
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP02_Z
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,TypeOfEvent VARCHAR(50)
)

-- Get outpatient encounters with a diagnostic code associated with the cancer of study
INSERT INTO Dflt._pk_INCLUSION_STEP02_Z
SELECT DISTINCT sp.PatientSSN
    ,owl.PatientSID
    ,owl.VisitSID
    ,owl.VisitDateTime
    ,'OUTPATIENT ENCOUNTER'
FROM Src.Outpat_Workload AS owl
INNER JOIN Src.Outpat_WorkloadVDiagnosis AS owld ON (owl.VisitSID = owld.VisitSID)
INNER JOIN Src.SPatient_SPatient AS sp ON (owl.PatientSID = sp.PatientSID)
LEFT JOIN CDWWork.Dim.ICD10 AS icd10 ON (owld.ICD10SID = icd10.ICD10SID)
LEFT JOIN CDWWork.Dim.ICD9 AS icd9 ON (owld.ICD9SID = icd9.ICD9SID)
WHERE (
        (
            icd10.ICD10Code LIKE '%C18%' -- COLORECTAL CANCER
            OR icd10.ICD10Code LIKE '%C19%' -- COLORECTAL CANCER
            OR icd10.ICD10Code LIKE '%C20%' -- COLORECTAL CANCER
            --OR
            --icd10.ICD10Code LIKE '%C34%'		-- LUNG CANCER
            --OR
            --icd10.ICD10Code LIKE '%C61%'		-- PROSTATE CANCER
            )
        OR (
            icd9.ICD9Code LIKE '153%' -- COLORECTAL CANCER
            OR icd9.ICD9Code LIKE '154.0%' -- COLORECTAL CANCER
            OR icd9.ICD9Code LIKE '154.1%' -- COLORECTAL CANCER
            --OR
            --icd9.ICD9Code LIKE '162%'			-- LUNG CANCER
            --OR
            --icd9.ICD9Code LIKE '185%'			-- PROSTATE CANCER
            )
        )
    AND owl.VisitDateTime BETWEEN @STEP02_ExcludeStart
        AND @STEP02_ExcludeEnd

-- Get inpatient encounters with a diagnostic code associated with the cancer of study
INSERT INTO Dflt._pk_INCLUSION_STEP02_Z
SELECT DISTINCT sp.PatientSSN
    ,inp.PatientSID
    ,inp.InpatientSID
    ,inp.AdmitDateTime
    ,'INPATIENT ENCOUNTER'
FROM Src.Inpat_Inpatient AS inp
INNER JOIN Src.Inpat_InpatientDiagnosis AS inpd ON (inp.InpatientSID = inpd.InpatientSID)
INNER JOIN Src.SPatient_SPatient AS sp ON (inp.PatientSID = sp.PatientSID)
LEFT JOIN CDWWork.Dim.ICD10 AS icd10 ON (inpd.ICD10SID = icd10.ICD10SID)
LEFT JOIN CDWWork.Dim.ICD9 AS icd9 ON (inpd.ICD9SID = icd9.ICD9SID)
WHERE (
        (
            icd10.ICD10Code LIKE '%C18%' -- COLORECTAL CANCER
            OR icd10.ICD10Code LIKE '%C19%' -- COLORECTAL CANCER
            OR icd10.ICD10Code LIKE '%C20%' -- COLORECTAL CANCER
            --OR
            --icd10.ICD10Code LIKE '%C34%'		-- LUNG CANCER
            --OR
            --icd10.ICD10Code LIKE '%C61%'		-- PROSTATE CANCER
            )
        OR (
            icd9.ICD9Code LIKE '153%' -- COLORECTAL CANCER
            OR icd9.ICD9Code LIKE '154.0%' -- COLORECTAL CANCER
            OR icd9.ICD9Code LIKE '154.1%' -- COLORECTAL CANCER
            --OR
            --icd9.ICD9Code LIKE '162%'			-- LUNG CANCER
            --OR
            --icd9.ICD9Code LIKE '185%'			-- PROSTATE CANCER
            )
        )
    AND inp.AdmitDateTime BETWEEN @STEP02_ExcludeStart
        AND @STEP02_ExcludeEnd

-- Get cancer registry entries with the cancer of study
INSERT INTO Dflt._pk_INCLUSION_STEP02_Z
SELECT DISTINCT sp.PatientSSN
    ,reg.PatientSID
    ,reg.OncologyPrimaryIEN
    ,reg.DateDX
    ,'REGISTRY ENTRY'
FROM Src.Oncology_Oncology_Primary_165_5 AS reg
INNER JOIN Src.SPatient_SPatient AS sp ON (reg.PatientSID = sp.PatientSID)
WHERE reg.DateDX BETWEEN @STEP02_ExcludeStart
        AND @STEP02_ExcludeEnd
    AND (
        (
            reg.SitegpX LIKE 'COLO%'
            OR reg.ICDOSite LIKE 'COLO%'
            OR reg.PrimarysiteX LIKE 'COLO%'
            )
        OR (
            reg.SitegpX LIKE 'RECT%'
            OR reg.ICDOSite LIKE 'RECT%'
            OR reg.PrimarysiteX LIKE 'RECT%'
            )
        --OR
        --(
        --	reg.SitegpX LIKE 'LUNG%' 
        --	OR 
        --	reg.ICDOSite LIKE 'LUNG%' 
        --	OR 
        --	reg.PrimarysiteX LIKE 'LUNG%'
        --)
        --OR
        --(
        --	reg.SitegpX LIKE 'PROSTATE%' 
        --	OR 
        --	reg.ICDOSite LIKE 'PROSTATE%' 
        --	OR
        --	reg.PrimarysiteX LIKE 'PROSTATE%'
        --)
        )
    -- <<<<!CANCER SELECTION ZONE END!>>>>
GO




-- I.03.A ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP03_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP03_A
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP03_A
(
	PatientSSN VARCHAR(10)
)

-- Get SSNs of patients in the search period that had cancer records in the exclusion period
INSERT INTO Dflt._pk_INCLUSION_STEP03_A
SELECT DISTINCT srch.PatientSSN
FROM Dflt._pk_INCLUSION_STEP01_Z AS srch
INNER JOIN Dflt._pk_INCLUSION_STEP02_Z AS exc ON (srch.PatientSSN = exc.PatientSSN)




-- I.03.B ---------------------------------------------------------------------------------------- 

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP03_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP03_Z
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP03_Z
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,TypeOfEvent VARCHAR(50)
)


/* Get cancer records from search period that don't belong to the list
of patients identified in iSTEP 03 PART A */
INSERT INTO Dflt._pk_INCLUSION_STEP03_Z
SELECT DISTINCT
	srch.PatientSSN
	,srch.PatientSID
	,srch.DiagnosisEventSID
	,srch.DiagnosisEventDateTime
	,srch.TypeOfEvent
FROM
	Dflt._pk_INCLUSION_STEP01_Z AS srch
WHERE
	srch.PatientSSN NOT IN
	(
		SELECT t.PatientSSN
		FROM Dflt._pk_INCLUSION_STEP03_A AS t
	)

GO




-- I.04.A ---------------------------------------------------------------------------------------- 

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP04_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP04_A
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP04_A
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,TypeOfEvent VARCHAR(50)
)

-- Get all registry diagnosis events from iSTEP 03 PART Z
INSERT INTO Dflt._pk_INCLUSION_STEP04_A
SELECT DISTINCT
	dx.PatientSSN
	,dx.PatientSID
	,dx.DiagnosisEventSID
	,dx.DiagnosisEventDateTime
	,dx.TypeOfEvent
FROM
	Dflt._pk_INCLUSION_STEP03_Z AS dx
WHERE dx.TypeOfEvent = 'REGISTRY ENTRY'




-- I.04.B ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP04_B') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP04_B
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP04_B
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,TypeOfEvent VARCHAR(50)
)

/* Get all first-time ICD occurence diagnosis events from iSTEP 03
PART Z for patients not in iSTEP 04 PART A */
INSERT INTO Dflt._pk_INCLUSION_STEP04_B
SELECT DISTINCT
	dx.PatientSSN
	,dx.PatientSID
	,dx.DiagnosisEventSID
	,dx.DiagnosisEventDateTime
	,dx.TypeOfEvent
FROM
	Dflt._pk_INCLUSION_STEP03_Z AS dx
WHERE
	dx.PatientSSN NOT IN
	(
		SELECT t.PatientSSN
		FROM Dflt._pk_INCLUSION_STEP04_A AS t
	)




-- I.04.C ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP04_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP04_Z
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP04_Z
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,TypeOfEvent VARCHAR(50)
)

-- For each patient, get the earliest diagnosis event from STEP 04 PART A
INSERT INTO Dflt._pk_INCLUSION_STEP04_Z
SELECT DISTINCT
	reg_dx.PatientSSN
	,reg_dx.PatientSID
	,reg_dx.DiagnosisEventSID
	,reg_dx.DiagnosisEventDateTime
	,reg_dx.TypeOfEvent
FROM
	Dflt._pk_INCLUSION_STEP04_A AS reg_dx
WHERE
	reg_dx.DiagnosisEventDateTime = 
	(
		SELECT TOP 1 t.DiagnosisEventDateTime
		FROM Dflt._pk_INCLUSION_STEP04_A AS t
		WHERE reg_dx.PatientSSN = t.PatientSSN
		ORDER BY t.DiagnosisEventDateTime ASC
	)

-- For each patient, get the earliest diagnosis event from STEP 04 PART B
INSERT INTO Dflt._pk_INCLUSION_STEP04_Z
SELECT DISTINCT
	icd_dx.PatientSSN
	,icd_dx.PatientSID
	,icd_dx.DiagnosisEventSID
	,icd_dx.DiagnosisEventDateTime
	,icd_dx.TypeOfEvent
FROM
	Dflt._pk_INCLUSION_STEP04_B AS icd_dx
WHERE
	icd_dx.DiagnosisEventDateTime = 
	(
		SELECT TOP 1 t.DiagnosisEventDateTime
		FROM Dflt._pk_INCLUSION_STEP04_B AS t
		WHERE icd_dx.PatientSSN = t.PatientSSN
		ORDER BY t.DiagnosisEventDateTime ASC
	)

GO




-- I.05.A ----------------------------------------------------------------------------------------

-- Set the emergency care (EC) search period 
DECLARE @STEP05_SearchStart DATETIME2
DECLARE @STEP05_SearchEnd DATETIME2

SET @STEP05_SearchStart = DATEADD(DAY, (SELECT params.Lookback_Length_Days FROM Dflt._pk_ParameterTable AS params), (SELECT params.Search_Start FROM Dflt._pk_ParameterTable AS params))
SET @STEP05_SearchEnd = DATEADD(MONTH, (SELECT params.Search_Length_Months FROM Dflt._pk_ParameterTable AS params), (SELECT params.Search_Start FROM Dflt._pk_ParameterTable AS params))

PRINT CHAR(13) + CHAR(10) + 'Step 05 - Emergency Care Search Period Start: ' + CAST(@STEP05_SearchStart AS VARCHAR)
PRINT 'Step 05 - Emergency Care Search Period End: ' + CAST(@STEP05_SearchEnd AS VARCHAR)

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP05_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP05_A
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP05_A
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,ECEventSID BIGINT
	,ECEventDateTime DATETIME2
	,TypeOfEvent VARCHAR(50)
)

-- Get all inpatient visits that fall under the Emergency Care (EC) search period
INSERT INTO Dflt._pk_INCLUSION_STEP05_A
SELECT DISTINCT sp.PatientSSN
    ,inp.PatientSID
    ,inp.InpatientSID
    ,inp.AdmitDateTime
    ,'INPATIENT'
FROM Src.Inpat_Inpatient AS inp
INNER JOIN Src.SPatient_SPatient AS sp ON (inp.PatientSID = sp.PatientSID)
WHERE inp.AdmitDateTime BETWEEN @STEP05_SearchStart
        AND @STEP05_SearchEnd
    AND sp.PatientSSN IN (
        SELECT t.PatientSSN
        FROM Dflt._pk_INCLUSION_STEP04_Z AS t
        )




-- I.05.B ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP05_B') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP05_B
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP05_B
(
	PatientSSN VARCHAR(10)
	,ECEventSID BIGINT
)

-- Select all Emergency Care events with a ICD-10-CM code implying planned admission
INSERT INTO Dflt._pk_INCLUSION_STEP05_B
SELECT DISTINCT ec.PatientSSN
    ,ec.ECEventSID
FROM Dflt._pk_INCLUSION_STEP05_A AS ec
INNER JOIN Src.Inpat_InpatientDiagnosis AS inpd ON (ec.ECEventSID = inpd.InpatientSID)
INNER JOIN CDWWork.Dim.ICD10 AS icd10 ON (inpd.ICD10SID = icd10.ICD10SID)
WHERE REPLACE(icd10.ICD10Code, '.', '') IN (
        SELECT t.ICD10CMCode
        FROM Dflt._pk_SETUP_PlannedHospitalization_ICD10CMCodes AS t
        )

-- Select all Emergency Care events with a ICD-10-PCS code implying planned admission
INSERT INTO Dflt._pk_INCLUSION_STEP05_B
SELECT DISTINCT ec.PatientSSN
    ,ec.ECEventSID
FROM Dflt._pk_INCLUSION_STEP05_A AS ec
INNER JOIN Src.Inpat_InpatientICDProcedure AS inpip ON (ec.ECEventSID = inpip.InpatientSID)
INNER JOIN CDWWork.Dim.ICD10Procedure AS icd10p ON (inpip.ICD10ProcedureSID = icd10p.ICD10ProcedureSID)
WHERE REPLACE(icd10p.ICD10ProcedureCode, '.', '') IN (
        SELECT t.ICD10PCSCode
        FROM Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes AS t
        )




-- I.05.C ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP05_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP05_Z
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP05_Z
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,ECEventSID BIGINT
	,ECEventDateTime DATETIME2
	,TypeOfEvent VARCHAR(50)
)

/* Select all Emergency Care events in iSTEP 05 PART A that were not
identified as being planned in iSTEP 05 PART B */
INSERT INTO Dflt._pk_INCLUSION_STEP05_Z
SELECT DISTINCT
	ec.PatientSSN
	,ec.PatientSID
	,ec.ECEventSID
	,ec.ECEventDateTime
	,ec.TypeOfEvent
FROM
	Dflt._pk_INCLUSION_STEP05_A AS ec
WHERE
	ec.ECEventSID NOT IN
	(
		SELECT pec.ECEventSID
		FROM Dflt._pk_INCLUSION_STEP05_B AS pec
	)

GO




-- I.06.A ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP06_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP06_A
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP06_A
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,DiagnosisTypeOfEvent VARCHAR(50)
	,ECEventSID BIGINT
	,ECEventDateTime DATETIME2
	,ECTypeOfEvent VARCHAR(50)
)

/* Select dyads of Emergency Care events and Diagnosis Events such
that the Emergency Care precedes the Diagnosis Event by at most 30
days (and by at least 0 days; i.e., on the day of). */


INSERT INTO Dflt._pk_INCLUSION_STEP06_A
SELECT DISTINCT dx.PatientSSN
    ,dx.PatientSID
    ,dx.DiagnosisEventSID
    ,dx.DiagnosisEventDateTime
    ,dx.TypeOfEvent
    ,ec.ECEventSID
    ,ec.ECEventDateTime
    ,ec.TypeOfEvent
FROM Dflt._pk_INCLUSION_STEP04_Z AS dx
INNER JOIN Dflt._pk_INCLUSION_STEP05_Z AS ec ON (
        dx.PatientSSN = ec.PatientSSN
        AND dx.DiagnosisEventDateTime BETWEEN DATEADD(DAY, (
                        SELECT params.Lookback_Length_Days
                        FROM Dflt._pk_ParameterTable AS params
                        ), ec.ECEventDateTime)
            AND ec.ECEventDateTime
        )




-- I.06.B ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP06_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP06_Z
	END

CREATE TABLE Dflt._pk_INCLUSION_STEP06_Z
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,DiagnosisTypeOfEvent VARCHAR(50)
	,ECEventSID BIGINT
	,ECEventDateTime DATETIME2
	,ECTypeOfEvent VARCHAR(50)
)

-- For each patient, select the dyad with the latest emergency care event from iSTEP 06 PART A
INSERT INTO Dflt._pk_INCLUSION_STEP06_Z
SELECT DISTINCT
	ecdx.PatientSSN
	,ecdx.PatientSID
	,ecdx.DiagnosisEventSID
	,ecdx.DiagnosisEventDateTime
	,ecdx.DiagnosisTypeOfEvent
	,ecdx.ECEventSID
	,ecdx.ECEventDateTime
	,ecdx.ECTypeOfEvent
FROM
	Dflt._pk_INCLUSION_STEP06_A AS ecdx
WHERE
	ecdx.ECEventDateTime = 
	(
		SELECT TOP 1 t.ECEventDateTime
		FROM Dflt._pk_INCLUSION_STEP06_A AS t
		WHERE ecdx.PatientSSN = t.PatientSSN
		ORDER BY t.ECEventDateTime DESC
	)

GO




-- I.07 ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_INCLUSION_FINAL') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_FINAL
	END

CREATE TABLE Dflt._pk_INCLUSION_FINAL
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,DiagnosisTypeOfEvent VARCHAR(50)
	,ECEventSID BIGINT
	,ECEventDateTime DATETIME2
	,ECTypeOfEvent VARCHAR(50)
)

-- Save records after the inclusion steps
INSERT INTO Dflt._pk_INCLUSION_FINAL
SELECT DISTINCT
	prev.PatientSSN
	,prev.PatientSID
	,prev.DiagnosisEventSID
	,prev.DiagnosisEventDateTime
	,prev.DiagnosisTypeOfEvent
	,prev.ECEventSID
	,prev.ECEventDateTime
	,prev.ECTypeOfEvent
FROM
	Dflt._pk_INCLUSION_STEP06_Z AS prev

GO




-- ************************************************************************************************
-- EXCLUSION
-- ************************************************************************************************

-- II.01.A ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_A
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP01_A
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,DiagnosisTypeOfEvent VARCHAR(50)
	,HistoricalEventSID BIGINT
	,HistoricalEventDateTime DATETIME2
	,HistoricalTypeOfEvent VARCHAR(50)
)

-- Get all historical inpatient records for patients
INSERT INTO Dflt._pk_EXCLUSION_STEP01_A
SELECT DISTINCT inc.PatientSSN
    ,inc.PatientSID
    ,inc.DiagnosisEventSID
    ,inc.DiagnosisEventDateTime
    ,inc.DiagnosisTypeOfEvent
    ,inp.InpatientSID
    ,inp.AdmitDateTime
    ,'INPATIENT'
FROM Dflt._pk_INCLUSION_FINAL AS inc
INNER JOIN Src.SPatient_SPatient AS sp ON (
        inc.PatientSSN = sp.PatientSSN
        AND sp.PatientSID != - 1
        )
INNER JOIN Src.Inpat_Inpatient AS inp ON (
        sp.PatientSID = inp.PatientSID
        AND inp.PatientSID != - 1
        )

-- Get all historical outpatient records for patients
INSERT INTO Dflt._pk_EXCLUSION_STEP01_A
SELECT DISTINCT inc.PatientSSN
    ,inc.PatientSID
    ,inc.DiagnosisEventSID
    ,inc.DiagnosisEventDateTime
    ,inc.DiagnosisTypeOfEvent
    ,owl.VisitSID
    ,owl.VisitDateTime
    ,'OUTPATIENT'
FROM Dflt._pk_INCLUSION_FINAL AS inc
INNER JOIN Src.SPatient_SPatient AS sp ON (
        inc.PatientSSN = sp.PatientSSN
        AND sp.PatientSID != - 1
        )
INNER JOIN Src.Outpat_Workload AS owl ON (
        sp.PatientSID = owl.PatientSID
        AND owl.PatientSID != - 1
        )




-- II.01.B ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_Z
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP01_Z
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,DiagnosisTypeOfEvent VARCHAR(50)
	,HistoricalEventSID BIGINT
	,HistoricalEventDateTime DATETIME2
	,HistoricalTypeOfEvent VARCHAR(50)
	,DxHxDelta INT
)

-- For each patient, get the earliest historical event from eSTEP 01 PART A
INSERT INTO Dflt._pk_EXCLUSION_STEP01_Z
SELECT DISTINCT
	hx.*
	,DATEDIFF(MONTH, hx.HistoricalEventDateTime, hx.DiagnosisEventDateTime)
FROM
	Dflt._pk_EXCLUSION_STEP01_A AS hx
WHERE
	hx.HistoricalEventDateTime = 
	(
		SELECT TOP 1 t.HistoricalEventDateTime
		FROM Dflt._pk_EXCLUSION_STEP01_A AS t
		WHERE hx.PatientSSN = t.PatientSSN
		ORDER BY t.HistoricalEventDateTime ASC
	)

GO




-- II.02.A ----------------------------------------------------------------------------------------

-- Set the emergency care (EC) search period 
DECLARE @STEP02_CareHxThreshold INT

SET @STEP02_CareHxThreshold = (SELECT params.CareHx_Length_Months FROM Dflt._pk_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'eStep 02 - Minimum Care History Threshold: ' + CAST(@STEP02_CareHxThreshold AS VARCHAR)

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP02_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP02_Z
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP02_Z
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,DiagnosisTypeOfEvent VARCHAR(50)
	,ECEventSID BIGINT
	,ECEventDateTime DATETIME2
	,ECTypeOfEvent VARCHAR(50)
)

/* Select records from the Inclusion steps that have their earliest
histoical encounter > the threshold ago. */
INSERT INTO Dflt._pk_EXCLUSION_STEP02_Z
SELECT DISTINCT
	prev.PatientSSN
	,prev.PatientSID
	,prev.DiagnosisEventSID
	,prev.DiagnosisEventDateTime
	,prev.DiagnosisTypeOfEvent
	,prev.ECEventSID
	,prev.ECEventDateTime
	,prev.ECTypeOfEvent
FROM
	Dflt._pk_INCLUSION_FINAL AS prev INNER JOIN Dflt._pk_EXCLUSION_STEP01_Z AS ehx ON
	(
		prev.PatientSSN = ehx.PatientSSN
		AND
		prev.DiagnosisEventSID = ehx.DiagnosisEventSID
		AND
		ehx.DxHxDelta > @STEP02_CareHxThreshold
	)


GO




-- II.03 ----------------------------------------------------------------------------------------

IF (OBJECT_ID('Dflt._pk_EXCLUSION_FINAL') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_FINAL
	END

CREATE TABLE Dflt._pk_EXCLUSION_FINAL
(
	PatientSSN VARCHAR(10)
	,PatientSID BIGINT
	,DiagnosisEventSID BIGINT
	,DiagnosisEventDateTime DATETIME2
	,DiagnosisTypeOfEvent VARCHAR(50)
	,ECEventSID BIGINT
	,ECEventDateTime DATETIME2
	,ECTypeOfEvent VARCHAR(50)
)

-- Save records after exclusion steps
INSERT INTO Dflt._pk_EXCLUSION_FINAL
SELECT DISTINCT
	exc.PatientSSN
	,exc.PatientSID
	,exc.DiagnosisEventSID
	,exc.DiagnosisEventDateTime
	,exc.DiagnosisTypeOfEvent
	,exc.ECEventSID
	,exc.ECEventDateTime
	,exc.ECTypeOfEvent
FROM Dflt._pk_EXCLUSION_STEP02_Z AS exc

GO




-- ************************************************************************************************
-- CONCLUSION
-- ************************************************************************************************

-- PRINT
-- ================================================================================================

SELECT DISTINCT
	CONCAT('''', fin.PatientSSN, '''')
	,CAST(fin.DiagnosisEventDateTime AS DATE)
	,CONCAT('''', reg.CitytownAtDX, ', ', '''', reg.StateatdXX)
	,CAST(fin.ECEventDateTime AS DATE)
	,CONCAT('''', st3.City, ', ', '''', sta.StateAbbrev)
FROM
	Dflt._pk_EXCLUSION_FINAL AS fin LEFT JOIN Src.Oncology_Oncology_Primary_165_5 AS reg ON 
	(
		fin.DiagnosisEventSID = reg.OncologyPrimaryIEN 
		AND 
		fin.DiagnosisEventDateTime = reg.DateDX
		AND 
		fin.PatientSID = reg.PatientSID 	
	)
		LEFT JOIN Src.Inpat_Inpatient AS inp ON
		(
			fin.ECEventSID = inp.InpatientSID
		)
			LEFT JOIN CDWWork.Dim.Sta3n AS st3 ON
			(
				inp.Sta3n = st3.Sta3n
			)
				LEFT JOIN CDWWork.Dim.[State] AS sta ON
				(
					st3.StateSID = sta.StateSID
				)

WHERE
	fin.DiagnosisTypeOfEvent = 'REGISTRY ENTRY'
	AND
	fin.ECTypeOfEvent = 'INPATIENT'




-- SAVE TABLE (PLEASE REPLACE "Dflt._pk_OUTPUT_TABLE" WITH THE NAME YOU WANT)
-- ================================================================================================

IF (OBJECT_ID('Dflt._pk_OUTPUT_TABLE') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_OUTPUT_TABLE
	END

CREATE TABLE Dflt._pk_OUTPUT_TABLE
(
	PatientSSN VARCHAR(100)
	,DiagnosisEventDate DATE
	,DiagnosisEventLocation VARCHAR(100)
	,EmergencyEventDate DATE
	,EmergencyEventLocation VARCHAR(100)
)

INSERT INTO Dflt._pk_OUTPUT_TABLE
SELECT DISTINCT
	CONCAT('''', fin.PatientSSN, '''')
	,CAST(fin.DiagnosisEventDateTime AS DATE)
	,CONCAT('''', reg.CitytownAtDX, ', ', '''', reg.StateatdXX)
	,CAST(fin.ECEventDateTime AS DATE)
	,CONCAT('''', st3.City, ', ', '''', sta.StateAbbrev)
FROM
	Dflt._pk_EXCLUSION_FINAL AS fin LEFT JOIN Src.Oncology_Oncology_Primary_165_5 AS reg ON 
	(
		fin.DiagnosisEventSID = reg.OncologyPrimaryIEN 
		AND 
		fin.DiagnosisEventDateTime = reg.DateDX
		AND 
		fin.PatientSID = reg.PatientSID 	
	)
		LEFT JOIN Src.Inpat_Inpatient AS inp ON
		(
			fin.ECEventSID = inp.InpatientSID
		)
			LEFT JOIN CDWWork.Dim.Sta3n AS st3 ON
			(
				inp.Sta3n = st3.Sta3n
			)
				LEFT JOIN CDWWork.Dim.[State] AS sta ON
				(
					st3.StateSID = sta.StateSID
				)

WHERE
	fin.DiagnosisTypeOfEvent = 'REGISTRY ENTRY'
	AND
	fin.ECTypeOfEvent = 'INPATIENT'




-- DELETE TABLES ==================================================================================

IF (OBJECT_ID('Dflt._pk_ParameterTable') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_ParameterTable
	END

IF (OBJECT_ID('Dflt._pk_SETUP_PlannedHospitalization_ICD10CMCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_PlannedHospitalization_ICD10CMCodes
	END

IF (OBJECT_ID('Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_SETUP_PlannedHospitalization_ICD10PCSCodes
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP01_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP01_Z
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP02_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP02_Z
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP03_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP03_A
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP03_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP03_Z
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP04_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP04_A
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP04_B') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP04_B
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP04_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP04_Z
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP05_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP05_A
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP05_B') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP05_B
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP05_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP05_Z
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP06_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP06_A
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_STEP06_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_STEP06_Z
	END

IF (OBJECT_ID('Dflt._pk_INCLUSION_FINAL') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_INCLUSION_FINAL
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_A') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_A
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_Z
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP02_Z') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP02_Z
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_FINAL') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_FINAL
	END
