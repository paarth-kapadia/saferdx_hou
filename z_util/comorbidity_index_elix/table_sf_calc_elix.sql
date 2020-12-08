-- Create tables
IF (OBJECT_ID('Dflt._pksf_calc_elix__INPUT_patients') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pksf_calc_elix__INPUT_patients
	END

CREATE TABLE Dflt._pksf_calc_elix__INPUT_patients
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,tl_sttpnt DATETIME2 DEFAULT NULL
	,tl_lookbp_months INT DEFAULT 0
)

-- Create tables
IF (OBJECT_ID('Dflt._pksf_calc_elix__OUTPUT_scores') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pksf_calc_elix__OUTPUT_scores
	END

CREATE TABLE Dflt._pksf_calc_elix__OUTPUT_scores
(
	p_SSN VARCHAR(50) DEFAULT NULL
	,tl_sttpnt DATETIME2 DEFAULT NULL
	,CHF INT NOT NULL DEFAULT 0
	,CA INT NOT NULL DEFAULT 0
	,VD INT NOT NULL DEFAULT 0
	,PCD INT NOT NULL DEFAULT 0
	,PVD INT NOT NULL DEFAULT 0
	,HT INT NOT NULL DEFAULT 0
	,HTcomp INT NOT NULL DEFAULT 0
	,Paralysis INT NOT NULL DEFAULT 0
	,Neuro INT NOT NULL DEFAULT 0
	,CPD INT NOT NULL DEFAULT 0
	,DM INT NOT NULL DEFAULT 0
	,DMcomp INT NOT NULL DEFAULT 0
	,Thyroid INT NOT NULL DEFAULT 0
	,RF INT NOT NULL DEFAULT 0
	,LD INT NOT NULL DEFAULT 0
	,PUD INT NOT NULL DEFAULT 0
	,AIDS INT NOT NULL DEFAULT 0
	,Lymph INT NOT NULL DEFAULT 0
	,MC INT NOT NULL DEFAULT 0
	,Tumor INT NOT NULL DEFAULT 0
	,RA INT NOT NULL DEFAULT 0
	,Coag INT NOT NULL DEFAULT 0
	,Obese INT NOT NULL DEFAULT 0
	,WtLoss INT NOT NULL DEFAULT 0
	,FED INT NOT NULL DEFAULT 0
	,BLAnemia INT NOT NULL DEFAULT 0
	,DAnemia INT NOT NULL DEFAULT 0
	,Alcohol INT NOT NULL DEFAULT 0
	,Drug INT NOT NULL DEFAULT 0
	,Psychoses INT NOT NULL DEFAULT 0
	,Depression INT NOT NULL DEFAULT 0
	,Total_Score INT NOT NULL DEFAULT -1
)