-- This section creates an input table to hold the patients for whom the Elixhauser score needs to be calculated
IF (OBJECT_ID('Dflt._pksf_calc_elix__INPUT_patients') IS NOT NULL)
	BEGIN
		DROP TABLE Dflt._pksf_calc_elix__INPUT_patients
	END

CREATE TABLE Dflt._pksf_calc_elix__INPUT_patients
(
	p_SSN VARCHAR(50) DEFAULT NULL	-- Patient SSN or identifier
	,tl_sttpnt DATETIME2 DEFAULT NULL	-- The admission date of the hospitalization for which you want to calculate the index (it will only calculate the score for comorbidities in the record prior to this date)
	,tl_lookbp_months INT DEFAULT 0	-- The lookback period in months for how far the algorithm should go back to find the comorbidites with which to calculate the score
)

-- This section creates an outut table that contains the score for each patient in the input table as well as the categories of comorbidities they had (per the Elixhauser classification)
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