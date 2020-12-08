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


-- SEARCH OBJECT
-- ************************************************************************************************


-- Create search object
IF (OBJECT_ID('Dflt._pk__SETUP_SearchObject') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_SearchObject
	END

CREATE TABLE Dflt._pk__SETUP_SearchObject
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,a_Type VARCHAR(50) DEFAULT 'CARE_ESCALATION_INPATIENT_MOVEMENT'
	,a_ID BIGINT DEFAULT NULL
	,a_StartDateTime DATETIME2 DEFAULT NULL
	,a_EndDateTime DATETIME2 DEFAULT NULL
	,r_l1_Type VARCHAR(50) DEFAULT 'ED_ENCOUNTER'
	,r_l1_ID BIGINT DEFAULT NULL
	,r_l1_StartDateTime DATETIME2 DEFAULT NULL
	,r_l1_EndDateTime DATETIME2 DEFAULT NULL
	,r_l2_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_l2_ID BIGINT DEFAULT NULL
	,r_l2_StartDateTime DATETIME2 DEFAULT NULL
	,r_l2_EndDateTime DATETIME2 DEFAULT NULL
)


GO


-- PARAMETER TABLE
-- ************************************************************************************************


-- Declare Variables
DECLARE @ss_Start_Dt DATETIME2
DECLARE @ss_Length_M INT
DECLARE @ss_Sta3n INT
DECLARE @co_EDAdmit_H INT

-- Set Variables
SET @ss_Start_Dt = '2018-01-01'
SET @ss_Length_M = 1
SET @ss_Sta3n = 580
SET @co_EDAdmit_H = 24


-- Create parameter table
IF (OBJECT_ID('Dflt._pk__SETUP_ParameterTable') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_ParameterTable
	END

CREATE TABLE Dflt._pk__SETUP_ParameterTable
(
	ss_Start_Dt DATETIME2
	,ss_Length_M INT
	,ss_Sta3n INT
	,co_EDAdmit_H INT
)


-- Insert Variables into Parameter Table
INSERT INTO Dflt._pk__SETUP_ParameterTable
(
	ss_Start_Dt
	,ss_Length_M
	,ss_Sta3n
	,co_EDAdmit_H
)
VALUES
(
	@ss_Start_Dt
	,@ss_Length_M
	,@ss_Sta3n
	,@co_EDAdmit_H
)


GO


-- WARD SPECIALTY VALUES TABLE
-- ************************************************************************************************


-- Create parameter table
IF (OBJECT_ID('Dflt._pk__SETUP_WardSpecialtiesTable') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_WardSpecialtiesTable
	END

CREATE TABLE Dflt._pk__SETUP_WardSpecialtiesTable
(
	SpecialtyName VARCHAR(50)
	,IsGenMed INT
	,IsAcute INT
)


-- Insert specialties into War Specialties Table
INSERT INTO
	Dflt._pk__SETUP_WardSpecialtiesTable
	(
		SpecialtyName
		,IsGenMed
		,IsAcute
	)
VALUES
	('STROKE UNIT', 1, 0)
	,('PULMONARY, NON-TB', 1, 0)
	,('zGENERAL(ACUTE MEDICINE', 1, 0)
	,('ACUTE PSYCHIATRY (<45 DAYS)', 1, 0)
	,('zLONG TERM PSYCHIATRY(>45 DA', 1, 0)
	,('zACUTE PSYCHIATRY (<45 DAYS)', 1, 0)
	,('PULMONARY, TUBERCULOSIS', 1, 0)
	,('SIPU (SPEC INPT PTSD UNIT)', 1, 0)
	,('ZZ POLYTRAUMA REHAB UNIT', 1, 0)
	,('GEM ACUTE MEDICINE', 1, 0)
	,('GEN MEDICINE (ACUTE)', 1, 0)
	,('GENERAL(ACUTE MEDICINE)', 1, 0)
	,('zGEM PSYCHIATRIC BEDS', 1, 0)
	,('PSYCH RESID REHAB TRMT PROG', 1, 0)
	,('z GEM ACUTE MEDICINE', 1, 0)
	,('zPULMONARY, NON-TB', 1, 0)
	,('ZZ PULMONARY, TUBERCULOSIS', 1, 0)
	,('zGEM INTERMEDIATE CARE', 1, 0)
	,('INTERMEDIATE MEDICINE', 1, 0)
	,('GEM PSYCHIATRIC BEDS', 1, 0)
	,('ZZ STROKE UNIT', 1, 0)
	,('MEDICAL OBSERVATION', 1, 0)
	,('zPULMONARY, TUBERCULOSI', 1, 0)
	,('vPEDIATRICS', 1, 0)
	,('ZZ PULMONARY, NON-TB', 1, 0)
	,('GENERAL SURGERY', 1, 0)
	,('GEM NEUROLOGY', 1, 0)
	,('CARDIOLOGY', 1, 0)
	,('ZZPULMONARY DISEASE', 1, 0)
	,('GASTROENTEROLOGY', 1, 0)
	,('THORACIC SURGERY', 1, 0)
	,('zGEM NEUROLOGY', 1, 0)
	,('HEMATOLOGY/ONCOLOGY', 1, 0)
	,('zHEMATOLOGY/ONCOLOGY', 1, 0)
	,('zSTROKE UNIT', 1, 0)
	,('HIGH INTENSITY GEN INPT', 1, 0)
	,('UROLOGY', 1, 0)
	,('NEUROLOGY', 1, 0)
	,('CARDIAC INTENSIVE CARE UNIT', 0, 1)
	,('MEDICAL ICU', 0, 1)
	,('SURGICAL ICU', 0, 1)
	,('zSURGICAL ICU', 0, 1)


GO


-- PLANNED HOSPITALIZATION ICD-10-CM + ICD-10-PCS CODES TABLES
-- ************************************************************************************************


-- Create tables
IF (OBJECT_ID('Dflt._pk__SETUP_PlannedHospitalization_ICD10CMCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_PlannedHospitalization_ICD10CMCodes
	END

CREATE TABLE Dflt._pk__SETUP_PlannedHospitalization_ICD10CMCodes
(
	ICD10CMCode VARCHAR(50)
)

IF (OBJECT_ID('Dflt._pk__SETUP_PlannedHospitalization_ICD10PCSCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_PlannedHospitalization_ICD10PCSCodes
	END

CREATE TABLE Dflt._pk__SETUP_PlannedHospitalization_ICD10PCSCodes
(
	ICD10PCSCode VARCHAR(50)
)


-- Compile codes
INSERT INTO Dflt._pk__SETUP_PlannedHospitalization_ICD10CMCodes
SELECT ex.[ICD-10-CM Code]
FROM Dflt._pk_UTIL_EncounterTypeICD_T1_Plan_T1_AlwaysPlannedConditions AS ex


INSERT INTO Dflt._pk__SETUP_PlannedHospitalization_ICD10PCSCodes
SELECT ex.[ICD-10-PCS CODE]
FROM Dflt._pk_UTIL_EncounterTypeICD_T1_Plan_T1_AlwaysPlannedProcedures AS ex

INSERT INTO Dflt._pk__SETUP_PlannedHospitalization_ICD10PCSCodes
SELECT ex.[ICD-10-PCS CODE]
FROM Dflt._pk_UTIL_EncounterTypeICD_T1_Plan_T1_SometimesPlannedProcedures AS ex


GO



-- ================================================================================================
-- ================================================================================================
-- INCLUSION
-- ================================================================================================
-- ================================================================================================



-- STEP 01
-- ************************************************************************************************


-- STEP 01v01
-- ------------------------------------------------------------------------------------------------


-- Variables
DECLARE @STEP01_v01_SearchStart DATETIME2
DECLARE @STEP01_v01_SearchEnd DATETIME2
DECLARE @STEP01_v01_Sta3n INT

SET @STEP01_v01_SearchStart = (SELECT params.ss_Start_Dt FROM Dflt._pk__SETUP_ParameterTable AS params)
SET @STEP01_v01_SearchEnd = DATEADD(MONTH, (SELECT params.ss_Length_M FROM Dflt._pk__SETUP_ParameterTable AS params), (SELECT params.ss_Start_Dt FROM Dflt._pk__SETUP_ParameterTable AS params))
SET @STEP01_v01_Sta3n = (SELECT params.ss_Sta3n FROM Dflt._pk__SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 01v01 - Search Period Start: ' + CAST(@STEP01_v01_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 01v01 - Search Period End: ' + CAST(@STEP01_v01_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 01v01 - Sta3n: ' + CAST(@STEP01_v01_Sta3n AS VARCHAR)


-- Create table
IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP01_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP01_v01
	END

CREATE TABLE Dflt._pk__INCLUSION_STEP01_v01
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t_ID BIGINT DEFAULT NULL
	,t_StartDateTime DATETIME2 DEFAULT NULL
	,t_EndDateTime DATETIME2 DEFAULT NULL
)


-- Algebra
INSERT INTO Dflt._pk__INCLUSION_STEP01_v01
(
	p_SSN 
	,t_ID 
	,t_StartDateTime 
	,t_EndDateTime
)
SELECT DISTINCT
	sp.PatientSSN
	,inp.InpatientSID
	,inp.AdmitDateTime
	,inp.DischargeDateTime
FROM
	Src.Inpat_Inpatient AS inp INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		inp.PatientSID = sp.PatientSID
	)
WHERE
	inp.AdmitDateTime BETWEEN
		@STEP01_v01_SearchStart
		AND
		@STEP01_v01_SearchEnd
	AND
		inp.InpatientSID != -1
	AND
		inp.AdmitDateTime IS NOT NULL
	AND
		inp.DischargeDateTime IS NOT NULL


GO


-- STEP 01v02
-- ------------------------------------------------------------------------------------------------


-- Variables
DECLARE @STEP01_v02_EDAdmitLinker INT
DECLARE @STEP01_v02_SearchStart DATETIME2
DECLARE @STEP01_v02_SearchEnd DATETIME2
DECLARE @STEP01_v02_Sta3n INT

SET @STEP01_v02_EDAdmitLinker = (SELECT params.co_EDAdmit_H FROM Dflt._pk__SETUP_ParameterTable AS params)
SET @STEP01_v02_SearchStart = DATEADD(HOUR, -1 * @STEP01_v02_EDAdmitLinker, (SELECT params.ss_Start_Dt FROM Dflt._pk__SETUP_ParameterTable AS params))
SET @STEP01_v02_SearchEnd = DATEADD(MONTH, (SELECT params.ss_Length_M FROM Dflt._pk__SETUP_ParameterTable AS params), (SELECT params.ss_Start_Dt FROM Dflt._pk__SETUP_ParameterTable AS params))
SET @STEP01_v02_Sta3n = (SELECT params.ss_Sta3n FROM Dflt._pk__SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 01v02 - ED to Inpatient Admit Linking Period: ' + CAST(@STEP01_v02_EDAdmitLinker AS VARCHAR)
PRINT 'Inclusion Step 01v02 - Search Period Start: ' + CAST(@STEP01_v02_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 01v02 - Search Period End: ' + CAST(@STEP01_v02_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 01v02 - Sta3n: ' + CAST(@STEP01_v02_Sta3n AS VARCHAR)


-- Create table
IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP01_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP01_v02
	END

CREATE TABLE Dflt._pk__INCLUSION_STEP01_v02
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t_ID BIGINT DEFAULT NULL
	,t_StartDateTime DATETIME2 DEFAULT NULL
	,t_EndDateTime DATETIME2 DEFAULT NULL
)


-- Algebra
INSERT INTO Dflt._pk__INCLUSION_STEP01_v02
(
	p_SSN 
	,t_ID 
	,t_StartDateTime 
	,t_EndDateTime
)
SELECT DISTINCT
	sp.PatientSSN
	,edl.VisitSID
	,edl.PatientArrivalDateTime
	,edl.DispositionDateTime
FROM
	Src.EDIS_EDISLog AS edl INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		edl.PatientSID = sp.PatientSID
	)
WHERE
	edl.DispositionDateTime BETWEEN
		@STEP01_v02_SearchStart
		AND
		@STEP01_v02_SearchEnd
	AND
		edl.VisitSID != -1
	AND
		edl.DispositionDateTime IS NOT NULL
	AND
		edl.PatientArrivalDateTime IS NOT NULL


GO


-- STEP 01v03
-- ------------------------------------------------------------------------------------------------


-- Variables
DECLARE @STEP01_v03_EDAdmitLinker INT
DECLARE @STEP01_v03_SearchStart DATETIME2
DECLARE @STEP01_v03_SearchEnd DATETIME2
DECLARE @STEP01_v03_Sta3n INT

SET @STEP01_v03_EDAdmitLinker = (SELECT params.co_EDAdmit_H FROM Dflt._pk__SETUP_ParameterTable AS params)
SET @STEP01_v03_SearchStart = DATEADD(HOUR, -1 * @STEP01_v03_EDAdmitLinker, (SELECT params.ss_Start_Dt FROM Dflt._pk__SETUP_ParameterTable AS params))
SET @STEP01_v03_SearchEnd = DATEADD(MONTH, (SELECT params.ss_Length_M FROM Dflt._pk__SETUP_ParameterTable AS params), (SELECT params.ss_Start_Dt FROM Dflt._pk__SETUP_ParameterTable AS params))
SET @STEP01_v03_Sta3n = (SELECT params.ss_Sta3n FROM Dflt._pk__SETUP_ParameterTable AS params)

PRINT CHAR(13) + CHAR(10) + 'Inclusion Step 01v03 - ED to Inpatient Admit Linking Period: ' + CAST(@STEP01_v03_EDAdmitLinker AS VARCHAR)
PRINT 'Inclusion Step 01v03 - Search Period Start: ' + CAST(@STEP01_v03_SearchStart AS VARCHAR)
PRINT 'Inclusion Step 01v03 - Search Period End: ' + CAST(@STEP01_v03_SearchEnd AS VARCHAR)
PRINT 'Inclusion Step 01v03 - Sta3n: ' + CAST(@STEP01_v03_Sta3n AS VARCHAR)


-- Create table
IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP01_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP01_v03
	END

CREATE TABLE Dflt._pk__INCLUSION_STEP01_v03
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
)


-- Algebra
INSERT INTO Dflt._pk__INCLUSION_STEP01_v03
(
	p_SSN 
	,t1_ID 
	,t1_StartDateTime 
	,t1_EndDateTime 
	,t2_ID 
	,t2_StartDateTime 
	,t2_EndDateTime 
)
SELECT DISTINCT
	qedl.p_SSN
	,qedl.t_ID
	,qedl.t_StartDateTime
	,qedl.t_EndDateTime
	,qinp.t_ID
	,qinp.t_StartDateTime
	,qinp.t_EndDateTime
FROM
	Dflt._pk__INCLUSION_STEP01_v01 AS qinp INNER JOIN Dflt._pk__INCLUSION_STEP01_v02 AS qedl ON
	(
		qinp.p_SSN = qedl.p_SSN
		AND
		qinp.t_StartDateTime BETWEEN
			qedl.t_EndDateTime
			AND
			DATEADD(HOUR, @STEP01_v03_EDAdmitLinker, qedl.t_EndDateTime)
	)


GO


-- STEP 01vFIN
-- ------------------------------------------------------------------------------------------------


-- Create tables
IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP01_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP01_vFIN
	END

CREATE TABLE Dflt._pk__INCLUSION_STEP01_vFIN
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,a_Type VARCHAR(50) DEFAULT 'CARE_ESCALATION_INPATIENT_MOVEMENT'
	,a_ID BIGINT DEFAULT NULL
	,a_StartDateTime DATETIME2 DEFAULT NULL
	,a_EndDateTime DATETIME2 DEFAULT NULL
	,r_l1_Type VARCHAR(50) DEFAULT 'ED_ENCOUNTER'
	,r_l1_ID BIGINT DEFAULT NULL
	,r_l1_StartDateTime DATETIME2 DEFAULT NULL
	,r_l1_EndDateTime DATETIME2 DEFAULT NULL
	,r_l2_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_l2_ID BIGINT DEFAULT NULL
	,r_l2_StartDateTime DATETIME2 DEFAULT NULL
	,r_l2_EndDateTime DATETIME2 DEFAULT NULL
)


-- Algebra
INSERT INTO Dflt._pk__INCLUSION_STEP01_vFIN
(
	p_SSN
	,a_ID
	,a_StartDateTime
	,a_EndDateTime
	,r_l1_ID
	,r_l1_StartDateTime
	,r_l1_EndDateTime
	,r_l2_ID
	,r_l2_StartDateTime
	,r_l2_EndDateTime
)
SELECT DISTINCT
	prev.p_SSN
	,NULL
	,NULL
	,NULL
	,prev.t1_ID
	,prev.t1_StartDateTime
	,prev.t1_EndDateTime
	,prev.t2_ID
	,prev.t2_StartDateTime
	,prev.t2_EndDateTime
FROM
	Dflt._pk__INCLUSION_STEP01_v03 AS prev
	

GO


-- STEP 02
-- ************************************************************************************************


-- STEP 02v00
-- ------------------------------------------------------------------------------------------------


-- Create table
IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP02_v00') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP02_v00
	END

CREATE TABLE Dflt._pk__INCLUSION_STEP02_v00
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t_Type VARCHAR(50) DEFAULT 'INPATIENT_MOVEMENT'
	,t_ID BIGINT DEFAULT NULL
	,t_StartDateTime DATETIME2 DEFAULT NULL
	,t_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
)


-- Algebra
INSERT INTO Dflt._pk__INCLUSION_STEP02_v00
(
	p_SSN 
	,t_ID 
	,t_StartDateTime 
	,t_EndDateTime
	,r_ID
	,r_StartDateTime
	,r_EndDateTime
)
SELECT DISTINCT
	prev.p_SSN
	,mvt.Inpatient535TransactionSID
	,mvt.MovementDateTime
	,NULL
	,prev.r_l2_ID
	,prev.r_l2_StartDateTime
	,prev.r_l2_EndDateTime
FROM
	Dflt._pk__INCLUSION_STEP01_vFIN AS prev INNER JOIN Src.Inpat_Inpatient535Transaction AS mvt ON
	(
		prev.r_l2_ID = mvt.InpatientSID
	)


GO


-- STEP 02v01
-- ------------------------------------------------------------------------------------------------


-- Create table
IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP02_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP02_v01
	END

CREATE TABLE Dflt._pk__INCLUSION_STEP02_v01
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t_Type VARCHAR(50) DEFAULT 'INPATIENT_MOVEMENT'
	,t_ID BIGINT DEFAULT NULL
	,t_StartDateTime DATETIME2 DEFAULT NULL
	,t_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
)


-- Algebra
INSERT INTO Dflt._pk__INCLUSION_STEP02_v01
(
	p_SSN 
	,t_ID 
	,t_StartDateTime 
	,t_EndDateTime
	,r_ID
	,r_StartDateTime
	,r_EndDateTime
	,r_WardEscFrom
)
SELECT DISTINCT
	prev.p_SSN
	,mvt.Inpatient535TransactionSID
	,mvt.MovementDateTime
	,NULL
	,prev.r_ID
	,prev.r_StartDateTime
	,prev.r_EndDateTime
	,spc.Specialty
FROM
	Dflt._pk__INCLUSION_STEP02_v00 AS prev INNER JOIN Src.Inpat_Inpatient535Transaction AS mvt ON
	(
		prev.r_ID = mvt.InpatientSID
	)
		INNER JOIN CDWWork.Dim.Specialty AS spc ON
		(
			spc.SpecialtySID = mvt.LosingSpecialtySID
		)
WHERE
	mvt.DischargeMovementFlag IS NULL
	AND
	DATEDIFF(HOUR, mvt.AdmitDateTime, mvt.MovementDateTime) <= 24
	AND
	spc.Specialty IN
	(
		SELECT dummy.SpecialtyName
		FROM Dflt._pk__SETUP_WardSpecialtiesTable AS dummy
		WHERE dummy.IsGenMed = 1
	)


GO


-- STEP 02v02
-- ------------------------------------------------------------------------------------------------


-- Create table
IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP02_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP02_v02
	END

CREATE TABLE Dflt._pk__INCLUSION_STEP02_v02
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
)


-- Algebra
INSERT INTO Dflt._pk__INCLUSION_STEP02_v02
(
	p_SSN 
	,t1_ID 
	,t1_StartDateTime 
	,t1_EndDateTime
	,t2_ID 
	,t2_StartDateTime 
	,t2_EndDateTime
	,r_ID
	,r_StartDateTime
	,r_EndDateTime
	,r_WardEscFrom
	,r_WardEscTo
)
SELECT DISTINCT
	prev.p_SSN
	,prev.t_ID
	,prev.t_StartDateTime
	,prev.t_EndDateTime
	,mvt.Inpatient535TransactionSID
	,mvt.MovementDateTime
	,NULL
	,prev.r_ID
	,prev.r_StartDateTime
	,prev.r_EndDateTime
	,prev.r_WardEscFrom
	,spc.Specialty
FROM
	Dflt._pk__INCLUSION_STEP02_v01 AS prev INNER JOIN Src.Inpat_Inpatient535Transaction AS mvt ON
	(
		prev.r_ID = mvt.InpatientSID
	)
		INNER JOIN CDWWork.Dim.Specialty AS spc ON
		(
			spc.SpecialtySID = mvt.LosingSpecialtySID
		)
WHERE
	mvt.MovementDateTime > prev.t_StartDateTime
	AND
	mvt.MovementDateTime =
	(
		SELECT MIN(dummy.t_StartDateTime)
		FROM Dflt._pk__INCLUSION_STEP02_v00 AS dummy
		WHERE
			dummy.r_ID = mvt.InpatientSID
			AND
			dummy.t_StartDateTime > prev.t_StartDateTime
	)
	AND
	spc.Specialty IN
	(
		SELECT dummy.SpecialtyName
		FROM Dflt._pk__SETUP_WardSpecialtiesTable AS dummy
		WHERE dummy.IsAcute = 1
	)


GO


-- STEP 02vFIN
-- ------------------------------------------------------------------------------------------------


-- Create table
IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP02_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP02_vFIN
	END

CREATE TABLE Dflt._pk__INCLUSION_STEP02_vFIN
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
)

-- Algebra
INSERT INTO Dflt._pk__INCLUSION_STEP02_vFIN
(
	p_SSN 
	,t1_ID 
	,t1_StartDateTime 
	,t1_EndDateTime
	,t2_ID 
	,t2_StartDateTime 
	,t2_EndDateTime
	,r_ID
	,r_StartDateTime
	,r_EndDateTime
	,r_WardEscFrom
	,r_WardEscTo
)
SELECT DISTINCT
	prev.p_SSN 
	,prev.t1_ID 
	,prev.t1_StartDateTime 
	,prev.t1_EndDateTime
	,prev.t2_ID 
	,prev.t2_StartDateTime 
	,prev.t2_EndDateTime
	,prev.r_ID
	,prev.r_StartDateTime
	,prev.r_EndDateTime
	,prev.r_WardEscFrom
	,prev.r_WardEscTo
FROM Dflt._pk__INCLUSION_STEP02_v02 AS prev


GO


-- FINIZE INCLUSION
-- ************************************************************************************************


-- CONCLUSION
-- ------------------------------------------------------------------------------------------------


-- Create table
IF (OBJECT_ID('Dflt._pk__INCLUSION_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_CONCLUSION
	END

CREATE TABLE Dflt._pk__INCLUSION_CONCLUSION
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
)

-- Algebra
INSERT INTO Dflt._pk__INCLUSION_CONCLUSION
(
	p_SSN 
	,t1_ID 
	,t1_StartDateTime 
	,t1_EndDateTime
	,t2_ID 
	,t2_StartDateTime 
	,t2_EndDateTime
	,r_ID
	,r_StartDateTime
	,r_EndDateTime
	,r_WardEscFrom
	,r_WardEscTo
)
SELECT DISTINCT
	prev.p_SSN 
	,prev.t1_ID 
	,prev.t1_StartDateTime 
	,prev.t1_EndDateTime
	,prev.t2_ID 
	,prev.t2_StartDateTime 
	,prev.t2_EndDateTime
	,prev.r_ID
	,prev.r_StartDateTime
	,prev.r_EndDateTime
	,prev.r_WardEscFrom
	,prev.r_WardEscTo
FROM Dflt._pk__INCLUSION_STEP02_vFIN AS prev


GO



-- ================================================================================================
-- ================================================================================================
-- EXCLUSION
-- ================================================================================================
-- ================================================================================================



-- STEP 01
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP01_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP01_v01
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP01_v01
(
	p_SSN VARCHAR(10)
	,r_StartDateTime DATETIME2
)


-- Get all unique index encounters and patients
INSERT INTO Dflt._pk__EXCLUSION_STEP01_v01
SELECT DISTINCT
	prev.p_SSN
	,prev.r_StartDateTime
FROM Dflt._pk__INCLUSION_CONCLUSION AS prev


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP01_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP01_v02
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP01_v02
(
	p_SSN VARCHAR(10)
	,r_StartDateTime DATETIME2
	,AgeAtEncounter INT
)


-- Create age filter for index visits
INSERT INTO Dflt._pk__EXCLUSION_STEP01_v02
SELECT DISTINCT
	p_SSN 
	,r_StartDateTime 
	,DATEDIFF(YEAR,sp.BirthDateTime, prev.r_StartDateTime)
FROM
	Dflt._pk__EXCLUSION_STEP01_v01 AS prev INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		prev.p_SSN = sp.PatientSSN
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP01_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP01_vFIN
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP01_vFIN
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
)


-- Get patient records that don't have return encounters with external cause codes to exclude
INSERT INTO Dflt._pk__EXCLUSION_STEP01_vFIN
SELECT DISTINCT 
	prev.*
FROM
	Dflt._pk__INCLUSION_CONCLUSION AS prev INNER JOIN Dflt._pk__EXCLUSION_STEP01_v02 AS ages ON
	(
		prev.r_StartDateTime = ages.r_StartDateTime
		AND
		ages.p_SSN = prev.p_SSN
	)
WHERE
	ages.AgeAtEncounter >= 18
	AND
	ages.AgeAtEncounter <= 85


GO


-- STEP 02
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v01
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_v01
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get all unique index encounters and patients
INSERT INTO Dflt._pk__EXCLUSION_STEP02_v01
SELECT DISTINCT
	prev.p_SSN
	,prev.r_ID
	,prev.r_StartDateTime
	,prev.r_EndDateTime
FROM Dflt._pk__EXCLUSION_STEP01_vFIN AS prev


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v02
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_v02
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
	,PriorEncounterType VARCHAR(50)
)


-- Get all prior enconuters for each index encounter
INSERT INTO Dflt._pk__EXCLUSION_STEP02_v02
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,inp.InpatientSID
	,inp.AdmitDateTime
	,inp.DischargeDateTime
	,'Inpatient'
FROM
	Src.Inpat_Inpatient AS inp INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		inp.PatientSID = sp.PatientSID
	)
		INNER JOIN Dflt._pk__EXCLUSION_STEP02_v01 AS prev ON
		(
			prev.PatientSSN = sp.PatientSSN
			AND
			inp.AdmitDateTime BETWEEN
				DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
				AND
				prev.IndexEncounterStartDateTime
		)
WHERE
	inp.InpatientSID != -1

INSERT INTO Dflt._pk__EXCLUSION_STEP02_v02
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,edl.VisitSID
	,edl.PatientArrivalDateTime
	,edl.DispositionDateTime
	,'ED'
FROM
	Src.EDIS_EDISLog AS edl INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		edl.PatientSID = sp.PatientSID
	)
		INNER JOIN Dflt._pk__EXCLUSION_STEP02_v01 AS prev ON
		(
			prev.PatientSSN = sp.PatientSSN
			AND
			edl.PatientArrivalDateTime BETWEEN
				DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
				AND
				prev.IndexEncounterStartDateTime
		)
WHERE
	edl.VisitSID != -1

INSERT INTO Dflt._pk__EXCLUSION_STEP02_v02
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,owl.VisitSID
	,owl.VisitDateTime
	,owl.VisitDateTime
	,'Outpatient'
FROM
	Src.Outpat_Workload AS owl INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		owl.PatientSID = sp.PatientSID
	)
		INNER JOIN Dflt._pk__EXCLUSION_STEP02_v01 AS prev ON
		(
			prev.PatientSSN = sp.PatientSSN
			AND
			owl.VisitDateTime BETWEEN
				DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
				AND
				prev.IndexEncounterStartDateTime
		)
WHERE
	owl.VisitSID != -1
	AND
	owl.VisitSID NOT IN
	(
		SELECT t.PriorEncounterSID
		FROM Dflt._pk__EXCLUSION_STEP02_v02 AS t
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v03
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_v03
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get index encounters that had a fee invoice one year before them
INSERT INTO Dflt._pk__EXCLUSION_STEP02_v03
SELECT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM
	Src.Fee_FeeInpatInvoice AS finp_inv INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		finp_inv.PatientSID = sp.PatientSID
	)
		INNER JOIN Dflt._pk__EXCLUSION_STEP02_v01 AS prev ON
		(
			sp.PatientSSN = prev.PatientSSN
			AND
			finp_inv.InvoiceReceivedDateTime BETWEEN
				DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
				AND
				prev.IndexEncounterStartDateTime
		)
			INNER JOIN cdwwork.dim.FeePurposeOfVisit AS purp ON
				finp_inv.FeePurposeOfVisitSID = purp.FeePurposeOfVisitSID
WHERE
	ltrim(rtrim(purp.AustinCode)) IN 
		(
			'43',
			'37',
			'38',
			'77',
			'78'
		)
	OR
	purp.FeePurposeOfVisit LIKE '%HOSPICE%'
	OR
	purp.FeePurposeOfVisit LIKE '%NURSING%'
	OR
	purp.FeePurposeOfVisit LIKE '%PALLIATIVE%'


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v04
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_v04
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Select index encounters with outpatient prior encounters with hpsl related stopcodes
INSERT INTO
	Dflt._pk__EXCLUSION_STEP02_v04
SELECT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM
	Dflt._pk__EXCLUSION_STEP02_v02 AS prev INNER JOIN Src.Outpat_Workload AS owl ON
	(
		owl.VisitSID = prev.PriorEncounterSID
	)
		INNER JOIN CDWWork.Dim.StopCode AS stopcode1 ON
		(
			owl.PrimaryStopCodeSID = stopcode1.StopCodeSID
		)
			INNER JOIN CDWWork.Dim.StopCode AS stopcode2 ON
			(
				owl.SecondaryStopCodeSID = stopcode1.StopCodeSID
			)			
WHERE
	prev.PriorEncounterType LIKE 'Outpatient'
	AND
	ISNULL(stopcode1.StopCode, 0) IN
	(
		351
		,353
	)
	OR
	ISNULL(stopcode2.StopCode, 0) IN
	(
		351
		,353
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v05
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_v05
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Select index encounters with ED prior encounters with hpsl related dispo codes
INSERT INTO Dflt._pk__EXCLUSION_STEP02_v05
SELECT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM
	Dflt._pk__EXCLUSION_STEP02_v02 AS prev INNER JOIN Src.EDIS_EDISLog AS edis ON
	(
		prev.PriorEncounterSID = edis.VisitSID
	)
		INNER JOIN CDWWork.Dim.EDISTrackingCode AS etc ON
		(
			edis.DispositionEDISTrackingCodeSID = etc.EDISTrackingCodeSID
		)
WHERE
	prev.PriorEncounterType LIKE 'ED'
	AND
	(
		etc.TrackingCodeName LIKE '%HOSPICE%'
		OR
		etc.TrackingCodeName LIKE '%PALLIATIVE%'
		OR
		etc.TrackingCodeName LIKE '%NURSING%'
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v06') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v06
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_v06
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Select index encounters with inpatient prior encounters with hpsl related dispo codes
INSERT INTO Dflt._pk__EXCLUSION_STEP02_v06
SELECT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM
	Dflt._pk__EXCLUSION_STEP02_v02 AS prev INNER JOIN Src.Inpat_Inpatient AS inp ON
	(
		inp.InpatientSID = prev.PriorEncounterSID
	)
		INNER JOIN CDWWork.Dim.PlaceOfDisposition AS pod ON 
		(
			inp.PlaceOfDispositionSID = pod.PlaceOfDispositionSID
		)
WHERE
	inp.PlaceOfDispositionSID != -1 
	AND 
	(
		pod.PlaceOfDisposition LIKE '%HOSPICE%'
		OR
		pod.PlaceOfDisposition LIKE '%NURSING%'
		OR
		pod.PlaceOfDisposition LIKE '%PALLIATIVE%'
	)
	AND
	prev.PriorEncounterType LIKE 'Inpatient'


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v07') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v07
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_v07
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get index enocunters of patients with prior inpatient encounters with certain PTF codes
INSERT INTO Dflt._pk__EXCLUSION_STEP02_v07
SELECT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM
	Dflt._pk__EXCLUSION_STEP02_v02 AS prev INNER JOIN Src.Inpat_Inpatient AS inp ON
	(
		inp.InpatientSID = prev.PriorEncounterSID
	)
		INNER JOIN CDWWork.Dim.Specialty AS s ON
		(
			inp.DischargeFromSpecialtySID = s.SpecialtySID
			AND
			inp.Sta3n = s.Sta3n
		)					
WHERE 
	ltrim(rtrim(s.PTFCode)) IN
	(
		'96'
		,'1F'
	)
	OR
	s.Specialty LIKE '%HOSPICE%'
	OR
	s.Specialty LIKE '%PALLIATIVE%'
	OR
	s.MedicalService LIKE '%HOSPICE%'
	OR
	s.MedicalService LIKE '%PALLIATIVE%'
	OR
	s.BedSectionName LIKE '%HOSPICE%'
	OR
	s.BedSectionName LIKE '%PALLIATIVE%'


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v08') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v08
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_v08
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get index enocunters of patients with prior inpatient encounters with certain ward codes
INSERT INTO Dflt._pk__EXCLUSION_STEP02_v08
SELECT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM
	Dflt._pk__EXCLUSION_STEP02_v02 AS prev INNER JOIN Src.Inpat_Inpatient535Transaction AS inp535t ON
	(
		inp535t.InpatientSID = prev.PriorEncounterSID
	)
		INNER JOIN CDWWork.Dim.WardLocation AS wloc ON
		(
			inp535t.LosingWardLocationSID = wloc.WardLocationSID
		)		
WHERE
	wloc.WardLocationName LIKE '%HOSPICE%'
	OR
	wloc.WardLocationName LIKE '%PALLIATIVE%'
	OR
	wloc.Specialty LIKE '%HOSPICE%'
	OR
	wloc.Specialty LIKE '%PALLIATIVE%'
	OR
	wloc.MedicalService LIKE '%HOSPICE%'
	OR
	wloc.MedicalService LIKE '%PALLIATIVE%'
	

GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v09') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v09
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_v09
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Compile all index encounters with a prior encounter that was hpsl related in the last year
INSERT INTO Dflt._pk__EXCLUSION_STEP02_v09
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk__EXCLUSION_STEP02_v03 AS prev

INSERT INTO Dflt._pk__EXCLUSION_STEP02_v09
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk__EXCLUSION_STEP02_v04 AS prev

INSERT INTO Dflt._pk__EXCLUSION_STEP02_v09
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk__EXCLUSION_STEP02_v05 AS prev

INSERT INTO Dflt._pk__EXCLUSION_STEP02_v09
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk__EXCLUSION_STEP02_v06 AS prev

INSERT INTO Dflt._pk__EXCLUSION_STEP02_v09
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk__EXCLUSION_STEP02_v07 AS prev

INSERT INTO Dflt._pk__EXCLUSION_STEP02_v09
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk__EXCLUSION_STEP02_v08 AS prev


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_vFIN
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP02_vFIN
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
)


-- Get patient records that don't have return encounters with external cause codes to exclude
INSERT INTO Dflt._pk__EXCLUSION_STEP02_vFIN
SELECT DISTINCT 
	prev.*
FROM Dflt._pk__EXCLUSION_STEP01_vFIN AS prev
WHERE
	prev.r_ID NOT IN
	(
		SELECT t.IndexEncounterSID 
		FROM Dflt._pk__EXCLUSION_STEP02_v09 AS t
	)


GO


-- STEP 03
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v01
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP03_v01
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get all unique index encounters and patients
INSERT INTO Dflt._pk__EXCLUSION_STEP03_v01
SELECT DISTINCT
	prev.p_SSN
	,prev.r_ID
	,prev.r_StartDateTime
	,prev.r_EndDateTime
FROM Dflt._pk__EXCLUSION_STEP02_vFIN AS prev


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v02
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP03_v02
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
	,PriorEncounterType VARCHAR(50)
)


-- Get all prior enconuters for each index encounter
INSERT INTO Dflt._pk__EXCLUSION_STEP03_v02
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,inp.InpatientSID
	,inp.AdmitDateTime
	,inp.DischargeDateTime
	,'Inpatient'
FROM
	Src.Inpat_Inpatient AS inp INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		inp.PatientSID = sp.PatientSID
	)
		INNER JOIN Dflt._pk__EXCLUSION_STEP03_v01 AS prev ON
		(
			prev.PatientSSN = sp.PatientSSN
			AND
			inp.AdmitDateTime BETWEEN
				DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
				AND
				prev.IndexEncounterStartDateTime
		)
WHERE
	inp.InpatientSID != -1

INSERT INTO Dflt._pk__EXCLUSION_STEP03_v02
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,edl.VisitSID
	,edl.PatientArrivalDateTime
	,edl.DispositionDateTime
	,'ED'
FROM
	Src.EDIS_EDISLog AS edl INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		edl.PatientSID = sp.PatientSID
	)
		INNER JOIN Dflt._pk__EXCLUSION_STEP03_v01 AS prev ON
		(
			prev.PatientSSN = sp.PatientSSN
			AND
			edl.PatientArrivalDateTime BETWEEN
				DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
				AND
				prev.IndexEncounterStartDateTime
		)
WHERE
	edl.VisitSID != -1


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v03
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP03_v03
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
)


-- Get ED Visits that were followed by an inpatient admission
INSERT INTO Dflt._pk__EXCLUSION_STEP03_v03
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.PriorEncounterSID
	,prev.PriorEncounterStartDateTime
	,prev.PriorEncounterEndDateTime
FROM Dflt._pk__EXCLUSION_STEP03_v02 AS prev
WHERE 
	prev.PriorEncounterType LIKE 'ED'
	AND
	0 < 
	(
		SELECT COUNT(t.PriorEncounterSID)
		FROM Dflt._pk__EXCLUSION_STEP03_v02 AS t
		WHERE
			t.PriorEncounterType LIKE 'Inpatient'
			AND
			t.PatientSSN = prev.PatientSSN
			AND
			t.IndexEncounterSID = prev.IndexEncounterSID
			AND
			t.PriorEncounterStartDateTime BETWEEN
				prev.PriorEncounterEndDateTime
				AND
				DATEADD(HOUR, 24, prev.PriorEncounterEndDateTime)
	)


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v04
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP03_v04
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
	,PriorEncounterType VARCHAR(50)
)


-- Get all records except for ED records that were followd by inpatient
INSERT INTO Dflt._pk__EXCLUSION_STEP03_v04
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.PriorEncounterSID
	,prev.PriorEncounterStartDateTime
	,prev.PriorEncounterEndDateTime
	,prev.PriorEncounterType
FROM Dflt._pk__EXCLUSION_STEP03_v02 AS prev
WHERE
	prev.PriorEncounterSID NOT IN
	(
		SELECT t.PriorEncounterSID 
		FROM Dflt._pk__EXCLUSION_STEP03_v03 AS t
	)


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v05
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP03_v05
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,NumerOfPriorEncountersInPeriod INT
)


-- Get number of prior encountes for each patient/index encounter
INSERT INTO Dflt._pk__EXCLUSION_STEP03_v05
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,COUNT(prev.PriorEncounterSID)
FROM Dflt._pk__EXCLUSION_STEP03_v04 AS prev
GROUP BY
	prev.PatientSSN
	,prev.IndexEncounterSID


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_vFIN
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP03_vFIN
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
)


-- Get patient records that don't have return encounters with external cause codes to exclude
INSERT INTO Dflt._pk__EXCLUSION_STEP03_vFIN
SELECT DISTINCT 
	prev.*
FROM Dflt._pk__EXCLUSION_STEP02_vFIN AS prev
WHERE
	3 > 
	(
		SELECT DISTINCT t.NumerOfPriorEncountersInPeriod
		FROM Dflt._pk__EXCLUSION_STEP03_v05 AS t
		WHERE t.IndexEncounterSID = prev.r_ID 
	)


GO


-- STEP 04
-- ************************************************************************************************


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_v01
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP04_v01
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get all unique index encounters
INSERT INTO Dflt._pk__EXCLUSION_STEP04_v01
SELECT DISTINCT
	prev.p_SSN
	,prev.r_ID
	,prev.r_StartDateTime
	,prev.r_EndDateTime
FROM Dflt._pk__EXCLUSION_STEP03_vFIN AS prev


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_v02
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP04_v02
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
	,PriorEncounterType VARCHAR(50)
)


-- Get all prior enconuters for each index encounter
INSERT INTO Dflt._pk__EXCLUSION_STEP04_v02
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,inp.InpatientSID
	,inp.AdmitDateTime
	,inp.DischargeDateTime
	,'Inpatient'
FROM
	Src.Inpat_Inpatient AS inp INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		inp.PatientSID = sp.PatientSID
	)
		INNER JOIN Dflt._pk__EXCLUSION_STEP04_v01 AS prev ON
		(
			prev.PatientSSN = sp.PatientSSN
			AND
			inp.AdmitDateTime BETWEEN
				DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
				AND
				prev.IndexEncounterStartDateTime
		)
WHERE
	inp.InpatientSID != -1

INSERT INTO Dflt._pk__EXCLUSION_STEP04_v02
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,owl.VisitSID
	,owl.VisitDateTime
	,owl.COProcessCompleteDateTime
	,'Outpatient'
FROM
	Src.Outpat_Workload AS owl INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		owl.PatientSID = sp.PatientSID
	)
		INNER JOIN Dflt._pk__EXCLUSION_STEP04_v01 AS prev ON
		(
			prev.PatientSSN = sp.PatientSSN
			AND
			owl.VisitDateTime BETWEEN
				DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
				AND
				prev.IndexEncounterStartDateTime
		)
WHERE
	owl.VisitSID != -1


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_v03
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP04_v03
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
	,PriorEncounterType VARCHAR(50)
	,ICD10CM_Code_Stripped VARCHAR(50)
)


-- Get conditions for prior encounters
INSERT INTO Dflt._pk__EXCLUSION_STEP04_v03
SELECT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.PriorEncounterSID
	,prev.PriorEncounterStartDateTime
	,prev.PriorEncounterEndDateTime
	,prev.PriorEncounterType
	,REPLACE(icd10.ICD10Code, '.', '')
FROM
	Dflt._pk__EXCLUSION_STEP04_v02 AS prev INNER JOIN Src.Inpat_InpatientDiagnosis AS inpd ON
	(
		prev.PriorEncounterSID = inpd.InpatientSID
	)
		INNER JOIN CDWWork.Dim.ICD10 AS icd10 ON
		(
			inpd.ICD10SID = icd10.ICD10SID
		)
WHERE
	inpd.InpatientDiagnosisSID != -1
	AND
	prev.PriorEncounterType = 'Inpatient'

INSERT INTO Dflt._pk__EXCLUSION_STEP04_v03
SELECT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.PriorEncounterSID
	,prev.PriorEncounterStartDateTime
	,prev.PriorEncounterEndDateTime
	,prev.PriorEncounterType
	,REPLACE(icd10.ICD10Code, '.', '')
FROM
	Dflt._pk__EXCLUSION_STEP04_v02 AS prev INNER JOIN Src.Outpat_WorkloadVDiagnosis AS owld ON
	(
		prev.PriorEncounterSID = owld.VisitSID
	)
		INNER JOIN CDWWork.Dim.ICD10 AS icd10 ON
		(
			owld.ICD10SID = icd10.ICD10SID
		)
WHERE
	owld.VDiagnosisSID != -1
	AND
	prev.PriorEncounterType = 'Outpatient'


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_v04
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP04_v04
(
	PatientSSN VARCHAR(50)
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get all index encounters to be exlcuded
INSERT INTO Dflt._pk__EXCLUSION_STEP04_v04
SELECT DISTINCT
	prev.PatientSSN
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM
	Dflt._pk__EXCLUSION_STEP04_v03 AS prev
WHERE
	prev.ICD10CM_Code_Stripped IN
	(
		SELECT t.[ICD-10-CM Code]
		FROM Dflt._pk_UTIL_EncounterTypeICD_T4_TerminaIllness_T4_TerminalIllness AS t
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_vFIN
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP04_vFIN
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
)


-- Get patient records that don't have return encounters with external cause codes to exclude
INSERT INTO Dflt._pk__EXCLUSION_STEP04_vFIN
SELECT 
	prev.*
FROM Dflt._pk__EXCLUSION_STEP03_vFIN AS prev
WHERE
	prev.r_ID NOT IN
	(
		SELECT t.IndexEncounterSID
		FROM Dflt._pk__EXCLUSION_STEP04_v04 AS t
	)


GO


-- STEP 05
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP05_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP05_v01
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP05_v01
(
	ReturnEncounterSID BIGINT
)


-- Get return encounters that were for a planned condition/procedure
INSERT INTO Dflt._pk__EXCLUSION_STEP05_v01
SELECT DISTINCT prev.r_ID
FROM
	Dflt._pk__EXCLUSION_STEP04_vFIN AS prev INNER JOIN Src.Inpat_InpatientDiagnosis AS inpd ON 
	(
		prev.r_ID = inpd.InpatientSID
	)
		INNER JOIN CDWWork.Dim.ICD10 AS icd10 ON
		(
			inpd.ICD10SID = icd10.ICD10SID
		)
WHERE
	REPLACE(icd10.ICD10Code, '.', '') IN 
		(
			SELECT t.ICD10CMCode
			FROM Dflt._pk__SETUP_PlannedHospitalization_ICD10CMCodes AS t
		)

INSERT INTO Dflt._pk__EXCLUSION_STEP05_v01
SELECT DISTINCT prev.r_ID
FROM
	Dflt._pk__EXCLUSION_STEP04_vFIN AS prev INNER JOIN Src.Inpat_InpatientICDProcedure AS inpip ON 
	(
		prev.r_ID = inpip.InpatientSID
	)
		INNER JOIN CDWWork.Dim.ICD10Procedure AS icd10p ON
		(
			inpip.ICD10ProcedureSID = icd10p.ICD10ProcedureSID
		)
WHERE
	REPLACE(icd10p.ICD10ProcedureCode, '.', '') IN 
		(
			SELECT t.ICD10PCSCode
			FROM Dflt._pk__SETUP_PlannedHospitalization_ICD10PCSCodes AS t
		)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP05_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP05_vFIN
	END

CREATE TABLE Dflt._pk__EXCLUSION_STEP05_vFIN
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
)


-- Select dyads that don't have planned return encounters
INSERT INTO Dflt._pk__EXCLUSION_STEP05_vFIN
SELECT DISTINCT
	prev.*
FROM Dflt._pk__EXCLUSION_STEP04_vFIN AS prev
WHERE
	prev.r_ID NOT IN
	(
		SELECT t.ReturnEncounterSID
		FROM Dflt._pk__EXCLUSION_STEP05_v01 AS t
	)


GO


-- EXCLUSION CONCLUSION
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk__EXCLUSION_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_CONCLUSION
	END

CREATE TABLE Dflt._pk__EXCLUSION_CONCLUSION
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
)


-- Select dyads that don't have planned return encounters
INSERT INTO Dflt._pk__EXCLUSION_CONCLUSION
(
	p_SSN
	,t1_Type
	,t1_ID
	,t1_StartDateTime
	,t1_EndDateTime
	,t2_Type
	,t2_ID
	,t2_StartDateTime
	,t2_EndDateTime
	,r_Type
	,r_ID
	,r_StartDateTime
	,r_EndDateTime
	,r_WardEscFrom
	,r_WardEscTo
)
SELECT DISTINCT
	prev.p_SSN
	,prev.t1_Type
	,prev.t1_ID
	,prev.t1_StartDateTime
	,prev.t1_EndDateTime
	,prev.t2_Type
	,prev.t2_ID
	,prev.t2_StartDateTime
	,prev.t2_EndDateTime
	,prev.r_Type
	,prev.r_ID
	,prev.r_StartDateTime
	,prev.r_EndDateTime
	,prev.r_WardEscFrom
	,prev.r_WardEscTo
FROM Dflt._pk__EXCLUSION_STEP05_vFIN AS prev


GO



-- ================================================================================================
-- ================================================================================================
-- RESULTS
-- ================================================================================================
-- ================================================================================================



-- Finalize Results
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk_RESULTS_AHRQML_CareEscalation') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_RESULTS_AHRQML_CareEscalation
	END

CREATE TABLE Dflt._pk_RESULTS_AHRQML_CareEscalation
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,t1_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_CE'
	,t1_ID BIGINT DEFAULT NULL
	,t1_StartDateTime DATETIME2 DEFAULT NULL
	,t1_EndDateTime DATETIME2 DEFAULT NULL
	,t2_Type VARCHAR(50) DEFAULT 'INP_MOVEMENT_FROM_CE_MOVEMENT'
	,t2_ID BIGINT DEFAULT NULL
	,t2_StartDateTime DATETIME2 DEFAULT NULL
	,t2_EndDateTime DATETIME2 DEFAULT NULL
	,r_Type VARCHAR(50) DEFAULT 'INPATIENT_ENCOUNTER'
	,r_ID BIGINT DEFAULT NULL
	,r_StartDateTime DATETIME2 DEFAULT NULL
	,r_EndDateTime DATETIME2 DEFAULT NULL
	,r_WardEscFrom VARCHAR(50) DEFAULT NULL
	,r_WardEscTo VARCHAR(50) DEFAULT NULL
	,r_Sta3n INT DEFAULT -1
	,r_State VARCHAR(50) DEFAULT NULL
	,r_City VARCHAR(50) DEFAULT NULL
)


-- Select dyads that don't have planned return encounters
INSERT INTO Dflt._pk_RESULTS_AHRQML_CareEscalation
(
	p_SSN
	,t1_Type
	,t1_ID
	,t1_StartDateTime
	,t1_EndDateTime
	,t2_Type
	,t2_ID
	,t2_StartDateTime
	,t2_EndDateTime
	,r_Type
	,r_ID
	,r_StartDateTime
	,r_EndDateTime
	,r_WardEscFrom
	,r_WardEscTo
	,r_Sta3n
	,r_State
	,r_City
)
SELECT DISTINCT
	prev.p_SSN
	,prev.t1_Type
	,prev.t1_ID
	,prev.t1_StartDateTime
	,prev.t1_EndDateTime
	,prev.t2_Type
	,prev.t2_ID
	,prev.t2_StartDateTime
	,prev.t2_EndDateTime
	,prev.r_Type
	,prev.r_ID
	,prev.r_StartDateTime
	,prev.r_EndDateTime
	,prev.r_WardEscFrom
	,prev.r_WardEscTo
	,s3.Sta3n
	,ste.[State]
	,s3.City
FROM
	Dflt._pk__EXCLUSION_CONCLUSION AS prev INNER JOIN Src.Inpat_Inpatient AS inp ON
	(
		prev.r_ID = inp.InpatientSID
	)
		INNER JOIN CDWWork.Dim.Sta3n AS s3 ON
		(
			inp.Sta3n = s3.Sta3n
		)
			INNER JOIN CDWWork.Dim.[State] AS ste ON
			(
				ste.StateSID = s3.StateSID
			)


GO


SELECT * FROM Dflt._pk__INCLUSION_STEP01_vFIN
SELECT * FROM Dflt._pk__INCLUSION_STEP02_vFIN
SELECT * FROM Dflt._pk__INCLUSION_CONCLUSION
SELECT * FROM Dflt._pk__EXCLUSION_STEP01_vFIN
SELECT * FROM Dflt._pk__EXCLUSION_STEP02_vFIN
SELECT * FROM Dflt._pk__EXCLUSION_STEP03_vFIN
SELECT * FROM Dflt._pk__EXCLUSION_STEP04_vFIN
SELECT * FROM Dflt._pk__EXCLUSION_STEP05_vFIN
SELECT * FROM Dflt._pk__EXCLUSION_CONCLUSION
SELECT * FROM Dflt._pk_RESULTS_AHRQML_CareEscalation



-- ================================================================================================
-- ================================================================================================
-- CLEAN UP
-- ================================================================================================
-- ================================================================================================



-- Delete Tables
-- ************************************************************************************************


-- Set Up
IF (OBJECT_ID('Dflt._pk__SETUP_ParameterTable') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_ParameterTable
	END

IF (OBJECT_ID('Dflt._pk__SETUP_SearchObject') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_SearchObject
	END

IF (OBJECT_ID('Dflt._pk__SETUP_WardSpecialtiesTable') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_WardSpecialtiesTable
	END

IF (OBJECT_ID('Dflt._pk__SETUP_PlannedHospitalization_ICD10CMCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_PlannedHospitalization_ICD10CMCodes
	END

IF (OBJECT_ID('Dflt._pk__SETUP_PlannedHospitalization_ICD10PCSCodes') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__SETUP_PlannedHospitalization_ICD10PCSCodes
	END


-- Inclusion
IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP01_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP01_v01
	END

IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP01_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP01_v02
	END

IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP01_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP01_v03
	END

IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP01_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP01_vFIN
	END

IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP02_v00') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP02_v00
	END

IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP02_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP02_v01
	END

IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP02_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP02_v02
	END

IF (OBJECT_ID('Dflt._pk__INCLUSION_STEP02_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_STEP02_vFIN
	END

IF (OBJECT_ID('Dflt._pk__INCLUSION_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__INCLUSION_CONCLUSION
	END


-- Exclusion
IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP01_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP01_v01
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP01_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP01_v02
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP01_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP01_vFIN
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v01
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v02
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v03
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v04
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v05
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v06') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v06
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v07') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v07
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v08') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v08
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_v09') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_v09
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP02_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP02_vFIN
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v01
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v02
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v03
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v04
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_v05
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP03_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP03_vFIN
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_v01
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_v02
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_v03
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_v04
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP04_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP04_vFIN
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP05_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP05_v01
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_STEP05_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_STEP05_vFIN
	END

IF (OBJECT_ID('Dflt._pk__EXCLUSION_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk__EXCLUSION_CONCLUSION
	END

	
GO