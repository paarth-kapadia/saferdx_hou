--Here is the refined trigger that we came up with. 
--We hope that this is clear and works well. 
--Please send us what you get for FY07 quarter 1 first 
--so that we can cross check it with what you sent earlier. 
--Then we can get the entire FY07 once its working well—
--please let me know if you have questions. 
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--Trigger 1: A primary care visit (scheduled or unscheduled) 
--followed by an unplanned hospitalization that occurred from 
--24 hrs after PC visit to 2 weeks after the PC visit.  Hence, 
--planned hospitalizations are to be excluded. 

--Planned hospitalizations are defined as: 
--Hospitalizations that are not accompanied by a clinic visit or ER visit 
--within previous 24 hours. Hospitalizations that are accompanied by stop 
--codes for the following same day appointments:  Ambulatory Care Scheduled Admit; 
--Day surgery and Pre-op clinic  
 

--A primary care visit is defined as:
--
--Patient care visit involving clinician such as physician, PA and NP.  
--It does not include visits to PharmD, nurses, dieticians or other 
--types of group visits 
 
--
--Data Collection Time Period
--Fiscal Year 2007 (after confirmation) 
--
--Location Houston Clinics 
use dwwork
go
drop table #tmp1
go
select a.*
into #tmp1
from openc a
join dimloc b on a.locien = b.locien and a.site = b.site
join dimptdemo c  on a.ptvid = c.ptvid and a.site = c.site
where a.dssid = 323
and a.site = 580
and opdate between '10/01/06' and '10/01/07'
and b.division = 'houston'
and( creditdssid in (185,186,188)
or creditdssid is null)
and [status] = 'checked out'
and vet = 'y'
and testpat is null
go
--(26116 row(s) affected)
alter table #tmp1 add Plus24 datetime, Plus14 datetime
go
update #tmp1
set Plus24 = dateadd(hh, 24, opdate),
Plus14 = dateadd(dd, 14, opdate)
go
--(26116 row(s) affected)
drop table #tmp2
go
select a.*
into #tmp2
from ptf a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
join ptfmove c on a.ptfien = c.ptfien and a.site = c.site
where a.admdate between plus24 and plus14
and feebasis = 'n'
and specialty not in
(20,21,22,25,26,27,28,29,32,33,35,37,38,39,40,71,
76,77,79,80,81,83,84,85,86,87,88,89,92,94,95,96)
and a.admdate = c.admdate
go
--(346 row(s) affected)
alter table #tmp2 add Minus24 datetime
go
update #tmp2 set Minus24 = dateadd (hh,-24, admdate)
go
drop table #tmp3
go
select distinct a.site, a.ptvid, a.ptfien, a.minus24, a.admdate
into #tmp3
from #tmp2 a
join openc b on a.ptvid = b.ptvid and a.site = b.site
where opdate between Minus24 and admdate
and dssid not in 
(102,103,105,107,108,109,115,116,147,149,150,151,180,202,424,545,602,999)
go
--(282 row(s) affected)

--Ambulatory Care Scheduled Admit; 
--Day surgery and Pre-op clinic  
--alter table #tmp3 add admday datetime
--go
--update #tmp3
--set admday = cast (cast(admdate as varchar(12)) as datetime)
--go
--delete pre-op same day
delete a
from #tmp3 a
join openc b on a.ptvid = b.ptvid and a.site = b.site
where opdate between Minus24 and admdate
and  locname like '%pre%'
and locname like '%op%'
go
--(0 row(s) affected)
--delete day surgery
delete a
from #tmp3 a
join openc b on a.ptvid = b.ptvid and a.site = b.site
join dimloc c on b.locien = c.locien and b.site = c.site
where (c.dssid in (416, 905, 429) or 
creditdssid in (416, 905, 429))
and b.site = 580
and opdate between Minus24 and admdate
go
--(32 row(s) affected)
--Ambulatory Care Scheduled Admit
delete a
from #tmp3 a
join openc b on a.ptvid = b.ptvid and a.site = b.site
where opdate between Minus24 and admdate
and locname like 'amb care sched%'
go
--(4 row(s) affected)
drop table #tmp4
go
select distinct a.site, a.ptvid, Minus24, locname, locien, dssid, opdate, admdate
into #tmp4
from #tmp3 a
join openc b on a.ptvid = b.ptvid and a.site = b.site
where opdate between Minus24 and admdate
and [status] = 'checked out'
order by 1,2, 5
go
delete from #tmp4
where dssid in (102,103,105,107,108,109,115,116,147,149,150,151,180,202,424,602,999)
go
drop table #tmp5
go
select [site], ptvid, admdate, max(opdate) opdate
into #tmp5
from #tmp4
group by [site], ptvid, admdate
go
--(260 row(s) affected)
drop table #tmp6
go
select a.*
into #tmp6
from #tmp4 a
join #tmp5 b on a.ptvid = b.ptvid and a.site = b.site
where a.opdate = b.opdate
go
drop table #tmp7
go
select [site], ptvid, admdate, max(locien) locien
into #tmp7
from #tmp6
group by [site], ptvid, admdate
go
drop table #tmp8
go
select a.*
into #tmp8
from #tmp6 a
join #tmp7 b on a.ptvid = b.ptvid and a.site = b.site
where a.admdate = b.admdate and a.locien = b.locien
go
--(260 row(s) affected)
drop table #tmp9
go
select a.site, a.ptvid, max(a.opdate) opdate
into #tmp9
from #tmp1 a
join #tmp8 b on a.ptvid = b.ptvid and a.site = b.site
where admdate between Plus24 and Plus14
and a.opdate < b.opdate
group by a.site, a.ptvid
go
--(249 row(s) affected)
drop table #tmp10
go
select a.site, a.ptvid, b.locname PCClinic, b.opdate PCDate, a.locname Clinic24, a.opdate Date24, admdate
into #tmp10
from #tmp8 a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
join #tmp9 c on b.ptvid = c.ptvid and b.site = c.site
where b.opdate = c.opdate
go

drop table dwperm.dbo.cf_EHRTrig1Qtr1
go
select distinct ptname, ptssn, PCClinic, PCDate, Clinic24, Date24, AdmDate
into dwperm.dbo.cf_EHRTrig1Qtr1
from #tmp10 a
join z.dbo.dimptid b on a.ptvid = b.ptvid and a.site = b.site
go
--(260 row(s) affected)
drop table #tmp
go
select ptname, ptssn, PCClinic, PCDate, Clinic24, Date24, AdmDate, a.ptvid
into #tmp
from #tmp10 a
join z.dbo.dimptid b on a.ptvid = b.ptvid and a.site = b.site
go
delete from #tmp
where clinic24 = 'CARDIOLOGY INVASIVE PROC (EC)'
go
--(15 row(s) affected)
delete from #tmp
where pcclinic = clinic24
and pcdate = date24
go
--(5 row(s) affected)
select *
from #tmp
go


------•	ICD9 Codes present at the time of index visit
drop table #tmp1
go
select a.ptvid, PCClinic, PCDate, icd9
into #tmp1
from opdx a
join #tmp b on a.ptvid = b.ptvid
where opdate = pcdate
and PCClinic = locname
go
--(2318 row(s) affected)
select *
from #tmp1
go
--Patient demographics: Race, gender, age, income, zip code.  
drop table #tmp1
go
select a.ptvid, max(completedate) completedate
into #tmp1
from means a
join #tmp b on a.ptvid = b.ptvid
group by a.ptvid
go
--(738 row(s) affected)
drop table #tmp2
go
select distinct a.ptvid, income, a.completedate
into #tmp2 
from means a
join #tmp1 b on a.ptvid = b.ptvid 
where a.completedate = b.completedate
go
--(708 row(s) affected)

select distinct a.ptvid, race,gender, age, income, zip
from dimptdemo a
join #tmp b on a.ptvid = b.ptvid
left outer join #tmp2 c on a.ptvid = c.ptvid
go
--•	Vital signs
--o	Systolic blood pressure
--o	Diastolic blood pressure
--o	Temperature
--o	Respiratory rate
--o	Heart rate
select a.ptvid, vitaldate, [type], numresult [value], systolic, diastolic
from vitals a
join #tmp b on a.ptvid = b.ptvid
where cast (cast(pcdate as varchar(12)) as datetime) =
          cast (cast(vitaldate as varchar(12)) as datetime)
and typeabbrev in
('bp','temp','resp','pulse')
go
--•	Lab values
--o	All lab values 30 days prior (including day of index visit)
--o	CBC chemistry
select distinct a.ptvid, tstname, numresult [value], specdate testdate
from chlab a
join #tmp b on a.ptvid = b.ptvid
where specdate between
dateadd (dd,-30,cast (cast(pcdate as varchar(12)) as datetime))
and 
cast (cast(pcdate as varchar(12)) as datetime)
and numresult is not null
go
--•	Comorbidity data
--o	Relevant chronic diseases
--	Diabetes 250
--	Hypertension 401
--	COPD 496,401
--	CAD 414
--	CHF 428 
--	Psychiatric disease (don’t include tobacco) 305.1
--	Cancer – active with in five years
--		mdc				sdc
--		Neoplasms		Benign Neoplasms
--		Neoplasms		Carcinoma In Situ
drop table #tmp1
go
with CoMorbidities (ptvid, icd9, mdc, sdc, dxdate) as
(select ptvid, a.icd9, mdc, sdc, opdate
from opdx a
join dimicd9 b on a.icd9 = b.icd9
where (left (a.icd9,3) in ('250','401','414','496','414','428')
or mdc = 'neoplasms'
or sdc in ('Neurotic Disorders, Personality Disorders, & Other Nonpsychotic Mental Disorders',
				'Psychoses'))
and left (a.icd9, 5) <> '305.1'
and sdc not in ('Benign','NeoplasmsCarcinoma In Situ')
union
select ptvid, a.icd9, mdc, sdc, opdate
from dwhist.dbo.opdx a
join dimicd9 b on a.icd9 = b.icd9
where (left (a.icd9,3) in ('250','401','414','496','414','428')
or mdc = 'neoplasms'
or sdc in ('Neurotic Disorders, Personality Disorders, & Other Nonpsychotic Mental Disorders',
				'Psychoses'))
and left (a.icd9, 5) <> '305.1'
and sdc not in ('Benign','NeoplasmsCarcinoma In Situ')
union
select ptvid, a.icd9, mdc, sdc, disdate
from ptfdx a
join dimicd9 b on a.icd9 = b.icd9
where (left (a.icd9,3) in ('250''401','414','496','414','428')
or mdc = 'neoplasms'
or sdc in ('Neurotic Disorders, Personality Disorders, & Other Nonpsychotic Mental Disorders',
				'Psychoses'))
and left (a.icd9, 5) <> '305.1'
and sdc not in ('Benign','NeoplasmsCarcinoma In Situ'))
select a.*, pcdate
into #tmp1
from CoMorbidities a
join #tmp b on a.ptvid = b.ptvid
where  dxdate <pcdate
go
--(84832 row(s) affected)
delete from #tmp1
where mdc = 'Mental Disorders'
and dxdate < dateadd(dd, -1825, pcdate)
go
--(19042 row(s) affected)
alter table #tmp1 add Dx varchar(4)
go
update #tmp1 set Dx = case
when left (icd9, 3) = '250' then 'DM' 
when left (icd9, 3) = '401' then 'HTN'
when left (icd9,3) = '496' then 'COPD'
when left (icd9, 3) = '414' then 'CAD'
when left (icd9, 3) ='428' then 'CHF'
when mdc = 'Mental Disorders' then 'MH'
when mdc = 'Neoplasms' then 'CA'
end
go
--(75432 row(s) affected)
drop table #tmp2
go
select ptvid, Dx, max(DxDate) DxDate
into #tmp2
from #tmp1 
group by ptvid, DX
go
select distinct a.ptvid, 
(select b.DxDate
from #tmp2 b
where a.ptvid = b.ptvid
and b.Dx = 'DM') DM,
(select c.DxDate
from #tmp2 c
where a.ptvid = c.ptvid
and c.Dx = 'HTN') HTN ,
(select d.DxDate
from #tmp2 d
where a.ptvid = d.ptvid
and d.Dx = 'COPD') COPD,
(select e.DxDate
from #tmp2 e
 where a.ptvid = e.ptvid
and e.dx = 'CAD') CAD,
(select f.DxDate
from #tmp2 f
where a.ptvid = f.ptvid
and f.Dx = 'CHF') CHF,
(select g.DxDate
from #tmp2 g
where a.ptvid = g.ptvid
and g.Dx = 'MH') MH,
(select h.DxDate
from #tmp2 h
where a.ptvid = h.ptvid
and h.Dx = 'CA') CA
from #tmp1 a
---•	Telephone calls to and from patients (evidence)
--o	+ or – 30 days of index visit
select a.ptvid, a.cpt, cptdesc, opdate phonedate
from opcpt a
join #tmp b on a.ptvid = b.ptvid
join dimcpt c on a.cpt = c.cpt
where a.cpt in ('99371','99372','99373')
and opdate between 
dateadd (dd, -30, pcdate) 
and
dateadd (dd, +30, pcdate)
go
--•	Number and type of medicines being prescribed at the time of index visit (excluding things like bandages)
drop table #tmp1
go
select a.ptvid, vadrugclass, vadrugclassname, drugname, filldate
into #tmp1
from rxopfill a
join #tmp b on a.ptvid = b.ptvid
where filldate <=pcdate
and dateadd(dd,daysupply, filldate) >=pcdate
and left (vadrugclass, 1) <>'x'
and left (vadrugclass, 2) <>'op'
and left (vadrugclass, 2) <>'DE'
go
--(61611 row(s) affected)
select *
from #tmp1
go

--•	Number of hospitalizations in the previous 6 months
select a.ptvid, count (distinct ptfien) Admits
from ptf a
join #tmp b on a.ptvid = b.ptvid
where feebasis = 'n'
and [site] = 580
and a.admdate >=dateadd(dd,-180, pcdate)
and a.admdate <pcdate
group by a.ptvid
go












 
















