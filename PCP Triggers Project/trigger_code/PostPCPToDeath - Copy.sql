-- ================================================================================================
-- ================================================================================================
-- PARAMETERS + SET-UP
-- ================================================================================================
-- ================================================================================================



-- CONFIG
-- ************************************************************************************************


-- Set Database
USE ORD_Singh_201210017D


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
SET @SearchPeriodLength_Months = 12
SET @PostEDAdmitToHospitalLinkingPeriodLength_Hours = 24
SET @EDToEDLookforwardPeriodStartDelta_Days = 1
SET @EDToEDLookforwardPeriodLength_Days = 14
SET @EDToInpatientLookforwardPeriodStartDelta_Days = 1
SET @EDToInpatientLookforwardPeriodLength_Days = 10
SET @EDToPCPLookforwardPeriodStartDelta_Days = 0
SET @EDToPCPLookforwardPeriodLength_Days = 30
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
	owl.PatientSID
	,owl.VisitSID
	,owl.VisitDateTime
	,owl.COProcessCompleteDateTime
FROM
	Src.Outpat_Workload AS owl INNER JOIN CDWWork.Dim.StopCode AS stopcode1 ON
	(
		owl.PrimaryStopCodeSID = stopcode1.StopCodeSID
	)
		INNER JOIN CDWWork.Dim.StopCode AS stopcode2 ON
		(
			owl.PrimaryStopCodeSID = stopcode2.StopCodeSID
		)
WHERE 
	owl.VisitDateTime BETWEEN
		@STEP01_v01_SearchStart
		AND
		@STEP01_v01_SearchEnd
	AND
	owl.Sta3n = @STEP01_v01_Sta3n
	AND
	owl.VisitSID != -1
	AND
	(
		(
			--PCP Stop Codes
			stopcode1.StopCode IN
			(
				--156		-- Home-Based Primary Care - Psychologist
				--,157	-- Home-Based Primary Care - Psychiatrist
				--,170	-- Hospital-Based Home Care???????????????????????????????????????????????????????????????????????????????????????????????????????????????????
				--,171	-- Home-Based Primary Care - RN or LPN
				--,172	-- Hospital-Based Home Care (extender)???????????????????????????????????????????????????????????????????????????????????????????????????????????????????
				--,173	-- Home-Based Primary Care - Social Worker
				--,174	-- Home-Based Primary Care - Therapist
				--,175	-- Home-Based Primary Care - Dietician
				--,176	-- Home-Based Primary Care - Clinical Pharmacist
				--,177	-- Home-Based Primary Care - Other
				--,178	-- Home-Based Primary Care - Telephone
				301	-- General Internal Medicine
				,322	-- Women's Clinic/Comprehensive Woman's Primary Clinic
				,323	-- Primary Care Medicine
				--,338	-- Telephone Primary Care !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!EXCLUDE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
				--,157	-- Home-Based Primary Care - Psychiatrist
				--,170	-- Hospital-Based Home Care???????????????????????????????????????????????????????????????????????????????????????????????????????????????????
				--,171	-- Home-Based Primary Care - RN or LPN
				--,172	-- Hospital-Based Home Care (extender)???????????????????????????????????????????????????????????????????????????????????????????????????????????????????
				--,173	-- Home-Based Primary Care - Social Worker
				--,174	-- Home-Based Primary Care - Therapist
				--,175	-- Home-Based Primary Care - Dietician
				--,176	-- Home-Based Primary Care - Clinical Pharmacist
				--,177	-- Home-Based Primary Care - Other
				--,178	-- Home-Based Primary Care - Telephone
				301	-- General Internal Medicine
				,322	-- Women's Clinic/Comprehensive Woman's Primary Clinic
				,323	-- Primary Care Medicine
				--,338	-- Telephone Primary Care !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!EXCLUDE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
	,DeathDateTime DATETIME2
)


-- Compile all Index Encounter - Return Encounter dyads into one table
INSERT INTO Dflt._pk_INCLUSION_STEP02_vFIN
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,sp.DeathDateTime
FROM
	Dflt._pk_INCLUSION_STEP01_vFIN AS prev INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		prev.PatientSID = sp.PatientSID
	)
WHERE
	sp.DeathDateTime IS NOT NULL
	AND
	sp.DeathDateTime BETWEEN
		prev.IndexEncounterStartDateTime
		AND
		DATEADD(DAY, (SELECT params.EDToPCPLookforwardPeriodLength_Days FROM Dflt._pk_SETUP_ParameterTable AS params), prev.IndexEncounterStartDateTime)


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
	,DeathDateTime DATETIME2
)


-- Select Earliest return visits for each index visit
INSERT INTO Dflt._pk_INCLUSION_CONCLUSION
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_INCLUSION_STEP02_vFIN AS prev


GO




-- ================================================================================================
-- ================================================================================================
-- EXCLUSION
-- ================================================================================================
-- ================================================================================================



-- STEP 04
-- ************************************************************************************************


-- Create tables
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_v01
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP04_v01
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Get all unique index encounters
INSERT INTO Dflt._pk_EXCLUSION_STEP04_v01
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_INCLUSION_CONCLUSION AS prev


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_v02
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP04_v02
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
	,PriorEncounterType VARCHAR(50)
)


-- Get all prior enconuters for each index encounter
INSERT INTO Dflt._pk_EXCLUSION_STEP04_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,inp.InpatientSID
	,inp.AdmitDateTime
	,inp.DischargeDateTime
	,'Inpatient'
FROM
	Dflt._pk_EXCLUSION_STEP04_v01 AS prev INNER JOIN Src.Inpat_Inpatient AS inp ON
	(
		prev.PatientSID = inp.PatientSID
		AND
		inp.AdmitDateTime BETWEEN
			DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
			AND
			prev.IndexEncounterStartDateTime
	)
WHERE
	inp.InpatientSID != -1

INSERT INTO Dflt._pk_EXCLUSION_STEP04_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,owl.VisitSID
	,owl.VisitDateTime
	,owl.COProcessCompleteDateTime
	,'Outpatient'
FROM
	Dflt._pk_EXCLUSION_STEP04_v01 AS prev INNER JOIN Src.Outpat_Workload AS owl ON
	(
		prev.PatientSID = owl.PatientSID
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
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_v03
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP04_v03
(
	PatientSID BIGINT
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
INSERT INTO Dflt._pk_EXCLUSION_STEP04_v03
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.PriorEncounterSID
	,prev.PriorEncounterStartDateTime
	,prev.PriorEncounterEndDateTime
	,prev.PriorEncounterType
	,REPLACE(icd10.ICD10Code, '.', '')
FROM
	Dflt._pk_EXCLUSION_STEP04_v02 AS prev INNER JOIN Src.Inpat_InpatientDiagnosis AS inpd ON
	(
		prev.PriorEncounterSID = inpd.InpatientSID
		AND
		prev.PatientSID = inpd.PatientSID
	)
		INNER JOIN CDWWork.Dim.ICD10 AS icd10 ON
		(
			inpd.ICD10SID = icd10.ICD10SID
		)
WHERE
	inpd.InpatientDiagnosisSID != -1
	AND
	prev.PriorEncounterType = 'Inpatient'

INSERT INTO Dflt._pk_EXCLUSION_STEP04_v03
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.PriorEncounterSID
	,prev.PriorEncounterStartDateTime
	,prev.PriorEncounterEndDateTime
	,prev.PriorEncounterType
	,REPLACE(icd10.ICD10Code, '.', '')
FROM
	Dflt._pk_EXCLUSION_STEP04_v02 AS prev INNER JOIN Src.Outpat_WorkloadVDiagnosis AS owld ON
	(
		prev.PriorEncounterSID = owld.VisitSID
		AND
		prev.PatientSID = owld.PatientSID
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
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_v04
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP04_v04
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get all index encounters to be exlcuded
INSERT INTO Dflt._pk_EXCLUSION_STEP04_v04
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM
	Dflt._pk_EXCLUSION_STEP04_v03 AS prev
WHERE
	prev.ICD10CM_Code_Stripped IN
	(
		SELECT t.[ICD-10-CM Code]
		FROM Dflt._pk_UTIL_EncounterTypeICD_T4_TerminaIllness_T4_TerminalIllness AS t
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_vFIN
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP04_vFIN
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Get patient records that don't have return encounters with external cause codes to exclude
INSERT INTO Dflt._pk_EXCLUSION_STEP04_vFIN
SELECT 
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_INCLUSION_CONCLUSION AS prev
WHERE
	prev.IndexEncounterSID NOT IN
	(
		SELECT t.IndexEncounterSID
		FROM Dflt._pk_EXCLUSION_STEP04_v04 AS t
	)


GO



-- STEP 05
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v01
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP05_v01
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Get all unique index encounters and patients
INSERT INTO Dflt._pk_EXCLUSION_STEP05_v01
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP04_vFIN AS prev


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v02
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP05_v02
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
	,PriorEncounterType VARCHAR(50)
)


-- Get all prior enconuters for each index encounter
INSERT INTO Dflt._pk_EXCLUSION_STEP05_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,inp.InpatientSID
	,inp.AdmitDateTime
	,inp.DischargeDateTime
	,'Inpatient'
FROM
	Dflt._pk_EXCLUSION_STEP05_v01 AS prev INNER JOIN Src.Inpat_Inpatient AS inp ON
	(
		prev.PatientSID = inp.PatientSID
		AND
		inp.AdmitDateTime BETWEEN
			DATEADD(YEAR, -1, prev.IndexEncounterStartDateTime)
			AND
			prev.IndexEncounterStartDateTime
	)
WHERE
	inp.InpatientSID != -1

INSERT INTO Dflt._pk_EXCLUSION_STEP05_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,edl.VisitSID
	,edl.PatientArrivalDateTime
	,edl.DispositionDateTime
	,'ED'
FROM
	Dflt._pk_EXCLUSION_STEP05_v01 AS prev INNER JOIN Src.EDIS_EDISLog AS edl ON
	(
		prev.PatientSID = edl.PatientSID
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
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v03
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP05_v03
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
)


-- Get ED Visits that were followed by an inpatient admission
INSERT INTO Dflt._pk_EXCLUSION_STEP05_v03
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.PriorEncounterSID
	,prev.PriorEncounterStartDateTime
	,prev.PriorEncounterEndDateTime
FROM Dflt._pk_EXCLUSION_STEP05_v02 AS prev
WHERE 
	prev.PriorEncounterType LIKE 'ED'
	AND
	0 < 
	(
		SELECT COUNT(t.PriorEncounterSID)
		FROM Dflt._pk_EXCLUSION_STEP05_v02 AS t
		WHERE
			t.PriorEncounterType LIKE 'Inpatient'
			AND
			t.PatientSID = prev.PatientSID
			AND
			t.IndexEncounterSID = prev.IndexEncounterSID
			AND
			t.PriorEncounterStartDateTime BETWEEN
				prev.PriorEncounterEndDateTime
				AND
				DATEADD(HOUR, (SELECT params.PostEDAdmitToHospitalLinkingPeriodLength_Hours FROM Dflt._pk_SETUP_ParameterTable AS params), prev.PriorEncounterEndDateTime)
	)


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v04
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP05_v04
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
	,PriorEncounterType VARCHAR(50)
)


-- Get all records except for ED records that were followd by inpatient
INSERT INTO Dflt._pk_EXCLUSION_STEP05_v04
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.PriorEncounterSID
	,prev.PriorEncounterStartDateTime
	,prev.PriorEncounterEndDateTime
	,prev.PriorEncounterType
FROM Dflt._pk_EXCLUSION_STEP05_v02 AS prev
WHERE
	prev.PriorEncounterSID NOT IN
	(
		SELECT t.PriorEncounterSID 
		FROM Dflt._pk_EXCLUSION_STEP05_v03 AS t
	)


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v05
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP05_v05
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,NumerOfPriorEncountersInPeriod INT
)


-- Get number of prior encountes for each patient/index encounter
INSERT INTO Dflt._pk_EXCLUSION_STEP05_v05
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,COUNT(prev.PriorEncounterSID)
FROM Dflt._pk_EXCLUSION_STEP05_v04 AS prev
GROUP BY
	prev.PatientSID
	,prev.IndexEncounterSID


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_vFIN
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP05_vFIN
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Get patient records that don't have return encounters with external cause codes to exclude
INSERT INTO Dflt._pk_EXCLUSION_STEP05_vFIN
SELECT DISTINCT 
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP04_vFIN AS prev
WHERE
	3 > 
	(
		SELECT DISTINCT t.NumerOfPriorEncountersInPeriod
		FROM Dflt._pk_EXCLUSION_STEP05_v05 AS t
		WHERE t.IndexEncounterSID = prev.IndexEncounterSID 
	)


GO




-- STEP 06
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v01
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_v01
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Get all unique index encounters and patients
INSERT INTO Dflt._pk_EXCLUSION_STEP06_v01
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP05_vFIN AS prev


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v02
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_v02
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,PriorEncounterSID BIGINT
	,PriorEncounterStartDateTime DATETIME2
	,PriorEncounterEndDateTime DATETIME2
	,PriorEncounterType VARCHAR(50)
	,DeathDateTime DATETIME2
)


-- Get all prior enconuters for each index encounter
INSERT INTO Dflt._pk_EXCLUSION_STEP06_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,inp.InpatientSID
	,inp.AdmitDateTime
	,inp.DischargeDateTime
	,'Inpatient'
	,prev.DeathDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_v01 AS prev INNER JOIN Src.Inpat_Inpatient AS inp ON
	(
		prev.PatientSID = inp.PatientSID
		AND
		inp.AdmitDateTime BETWEEN
			DATEADD(YEAR, -1, prev.DeathDateTime)
			AND
			prev.DeathDateTime
	)
WHERE
	inp.InpatientSID != -1

INSERT INTO Dflt._pk_EXCLUSION_STEP06_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,edl.VisitSID
	,edl.PatientArrivalDateTime
	,edl.DispositionDateTime
	,'ED'
	,prev.DeathDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_v01 AS prev INNER JOIN Src.EDIS_EDISLog AS edl ON
	(
		prev.PatientSID = edl.PatientSID
		AND
		edl.PatientArrivalDateTime BETWEEN
			DATEADD(YEAR, -1, prev.DeathDateTime)
			AND
			prev.DeathDateTime
	)
WHERE
	edl.VisitSID != -1

INSERT INTO Dflt._pk_EXCLUSION_STEP06_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,owl.VisitSID
	,owl.VisitDateTime
	,owl.COProcessCompleteDateTime
	,'Outpatient'
	,prev.DeathDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_v01 AS prev INNER JOIN Src.Outpat_Workload AS owl ON
	(
		prev.PatientSID = owl.PatientSID
		AND
		owl.VisitDateTime BETWEEN
			DATEADD(YEAR, -1, prev.DeathDateTime)
			AND
			prev.DeathDateTime
	)
WHERE
	owl.VisitSID != -1
	AND
	owl.VisitSID NOT IN
	(
		SELECT t.PriorEncounterSID
		FROM Dflt._pk_EXCLUSION_STEP06_v02 AS t
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v03
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_v03
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Get index encounters that had a fee invoice one year before them
INSERT INTO Dflt._pk_EXCLUSION_STEP06_v03
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_v01 AS prev INNER JOIN Src.Fee_FeeInpatInvoice AS finp_inv ON
	(
		finp_inv.PatientSID = prev.PatientSID
		AND
		finp_inv.InvoiceReceivedDateTime BETWEEN
			DATEADD(YEAR, -1, prev.DeathDateTime)
			AND
			prev.DeathDateTime
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
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v04
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_v04
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Select index encounters with outpatient prior encounters with hpsl related stopcodes
INSERT INTO
	Dflt._pk_EXCLUSION_STEP06_v04
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_v02 AS prev INNER JOIN Src.Outpat_Workload AS owl ON
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
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v05
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_v05
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Select index encounters with ED prior encounters with hpsl related dispo codes
INSERT INTO Dflt._pk_EXCLUSION_STEP06_v05
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_v02 AS prev INNER JOIN Src.EDIS_EDISLog AS edis ON
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
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v06') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v06
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_v06
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Select index encounters with inpatient prior encounters with hpsl related dispo codes
INSERT INTO Dflt._pk_EXCLUSION_STEP06_v06
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_v02 AS prev INNER JOIN Src.Inpat_Inpatient AS inp ON
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
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v07') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v07
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_v07
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Get index enocunters of patients with prior inpatient encounters with certain PTF codes
INSERT INTO Dflt._pk_EXCLUSION_STEP06_v07
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_v02 AS prev INNER JOIN Src.Inpat_Inpatient AS inp ON
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
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v08') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v08
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_v08
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Get index enocunters of patients with prior inpatient encounters with certain ward codes
INSERT INTO Dflt._pk_EXCLUSION_STEP06_v08
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_v02 AS prev INNER JOIN Src.Inpat_Inpatient535Transaction AS inp535t ON
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
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v09') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v09
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_v09
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Compile all index encounters with a prior encounter that was hpsl related in the last year
INSERT INTO Dflt._pk_EXCLUSION_STEP06_v09
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP06_v03 AS prev

INSERT INTO Dflt._pk_EXCLUSION_STEP06_v09
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP06_v04 AS prev

INSERT INTO Dflt._pk_EXCLUSION_STEP06_v09
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP06_v05 AS prev

INSERT INTO Dflt._pk_EXCLUSION_STEP06_v09
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP06_v06 AS prev

INSERT INTO Dflt._pk_EXCLUSION_STEP06_v09
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP06_v07 AS prev

INSERT INTO Dflt._pk_EXCLUSION_STEP06_v09
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP06_v08 AS prev


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_vFIN
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP06_vFIN
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,DeathDateTime DATETIME2
)


-- Get patient records that don't have return encounters with external cause codes to exclude
INSERT INTO Dflt._pk_EXCLUSION_STEP06_vFIN
SELECT DISTINCT 
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,prev.DeathDateTime
FROM Dflt._pk_EXCLUSION_STEP05_vFIN AS prev
WHERE
	prev.IndexEncounterSID NOT IN
	(
		SELECT t.IndexEncounterSID 
		FROM Dflt._pk_EXCLUSION_STEP06_v09 AS t
	)


GO




-- STEP 07
-- ************************************************************************************************


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP07_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP07_v01
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP07_v01
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get all unique index encounters and patients
INSERT INTO Dflt._pk_EXCLUSION_STEP07_v01
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk_EXCLUSION_STEP06_vFIN AS prev


GO


-- Create tables
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP07_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP07_v02
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP07_v02
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
	,AgeAtEncounter INT
)


-- Create age filter for index visits
INSERT INTO Dflt._pk_EXCLUSION_STEP07_v02
SELECT DISTINCT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
	,DATEDIFF(YEAR,sp.BirthDateTime, prev.IndexEncounterStartDateTime)
FROM
	Dflt._pk_EXCLUSION_STEP07_v01 AS prev INNER JOIN Src.SPatient_SPatient AS sp ON
	(
		prev.PatientSID = sp.PatientSID
	)


GO


-- Create tables 
IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP07_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP07_vFIN
	END

CREATE TABLE Dflt._pk_EXCLUSION_STEP07_vFIN
(
	PatientSID BIGINT
	,IndexEncounterSID BIGINT
	,IndexEncounterStartDateTime DATETIME2
	,IndexEncounterEndDateTime DATETIME2
)


-- Get patient records that don't have return encounters with external cause codes to exclude
INSERT INTO Dflt._pk_EXCLUSION_STEP07_vFIN
SELECT DISTINCT 
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM
	Dflt._pk_EXCLUSION_STEP06_vFIN AS prev INNER JOIN Dflt._pk_EXCLUSION_STEP07_v02 AS ages ON
	(
		prev.IndexEncounterSID = ages.IndexEncounterSID
	)
WHERE
	ages.AgeAtEncounter >= 18
	AND
	ages.AgeAtEncounter <= 85


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
)


-- Select Earliest return visits for each index visit
INSERT INTO Dflt._pk_EXCLUSION_CONCLUSION
SELECT
	prev.PatientSID
	,prev.IndexEncounterSID
	,prev.IndexEncounterStartDateTime
	,prev.IndexEncounterEndDateTime
FROM Dflt._pk_EXCLUSION_STEP07_vFIN AS prev


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
				INNER JOIN Src.SPatient_SPatient AS sp on
				(
					sp.PatientSID = prev.PatientSID
				)


GO




-- ================================================================================================
-- ================================================================================================
-- DISPLAY + CLEAN UP
-- ================================================================================================
-- ================================================================================================



-- DISPLAY RESULTS
-- ************************************************************************************************


-- Print
SELECT COUNT(PatientSID) FROM Dflt._pk_INCLUSION_STEP01_vFIN
SELECT COUNT(PatientSID) FROM Dflt._pk_INCLUSION_STEP02_vFIN
SELECT COUNT(PatientSID) FROM Dflt._pk_EXCLUSION_STEP04_vFIN
SELECT COUNT(PatientSID) FROM Dflt._pk_EXCLUSION_STEP05_vFIN
SELECT COUNT(PatientSID) FROM Dflt._pk_EXCLUSION_STEP06_vFIN
SELECT COUNT(PatientSID) FROM Dflt._pk_EXCLUSION_STEP07_vFIN
SELECT COUNT(DISTINCT PatientSSN) FROM Dflt._pk_RESULTS_CONCLUSION



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

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP01_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP01_vFIN
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP02_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP02_vFIN
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP03_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP03_v01
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP03_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP03_vFIN
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_v01
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_v02
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_v03
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_v04
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP04_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP04_vFIN
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v01
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v02
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v03
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v04
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_v05
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP05_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP05_vFIN
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v01
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v02
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v03') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v03
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v04') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v04
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v05') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v05
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v06') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v06
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v07') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v07
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v08') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v08
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_v09') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_v09
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP06_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP06_vFIN
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP07_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP07_v01
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP07_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP07_v02
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP07_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP07_vFIN
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP08_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP08_v01
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP08_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP08_v02
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP08_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP08_vFIN
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP09_v01') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP09_v01
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP09_v02') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP09_v02
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_STEP09_vFIN') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_STEP09_vFIN
	END

IF (OBJECT_ID('Dflt._pk_EXCLUSION_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_EXCLUSION_CONCLUSION
	END


-- Results
IF (OBJECT_ID('Dflt._pk_RESULTS_CONCLUSION') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pk_RESULTS_CONCLUSION
	END

	
GO