use houdw
go
--trigger2
drop table #tmp1
go
select distinct a.site, a.ptvid, a.locname , 
          a.dssid, creditdssid,opdate
into #tmp1
from openc a
join dimptdemo b on a.ptvid = b.ptvid and a.site = b.site
join dimloc c on a.locien = c.locien and a.site = c.site 
where opdate between '10/01/06' and '10/01/07'
and a.dssid = 323
and a.status = 'checked out'
and vet = 'y'
and testpat is null
and a.division = 'houston'
and (creditdssid is null or
creditdssid in (185,186,188))
go
--(106085 row(s) affected)
--2nd visit within 14 days
drop table #tmp2
go
select a.*, 
         b.locname locname2,b.dssid dssid2,
         b.creditdssid creditdssid2,b.opdate opdate2
into #tmp2
from #tmp1 a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
where b.opdate between dateadd (s, 1, a.opdate) and
          dateadd(dd, 14, a.opdate)
go
--(17015 row(s) affected)
--2nd visit within 14 days er or acute care
drop table #tmp3
go
select a.*, b.locname locname2, b.dssid dssid2, 
         c.creditdssid creditdssid2, b.opdate opdate2
into #tmp3
from #tmp1 a
join openc b on a.ptvid = b.ptvid and a.site = b.site
join dimloc c on b.locien = c.locien and b.site = c.site
where 
b.opdate between dateadd (s, 1, a.opdate) and
          dateadd(dd, 14, a.opdate)
and b.dssid in(130, 131)
go
--(2346 row(s) affected)
insert into #tmp2
select *
from #tmp3
go

--(4186 row(s) affected)
--delete trigger 1 visits
delete a
from #tmp2 a
join trig1visits b on ptvid = ptid 
where locname  = pcclinic and opdate = pcdate
go
--(1066 row(s) affected)

---controls delete trig2 from #tmp1
delete a
from #tmp1 a
join #tmp2 b on a.ptvid = b.ptvid and a.site = b.site
where a.locname = b.locname and a.opdate = b.opdate
go
--delete trig1 from from #tmp1
delete a
from #tmp1 a
join trig1visits b on a.ptvid = b.ptid
go
--get min visit for control
drop table #tmp2
go
with FirstVisit ([site] , ptvid, opdate) as
(select [site], ptvid, min(opdate) opdate
from #tmp1
group by [site], ptvid)
select distinct a.*
into #tmp2
from #tmp1 a
join FirstVisit b on a.ptvid = b.ptvid and a.site = b.site
where a.opdate = b.opdate
go
select ptvid, count (*)
from #tmp2
group by ptvid 
having count(*)>1
go
delete a
from #tmp2 a
join #tmp2 b on a.ptvid = b.ptvid and a.site = b.site
where a.locname < b.locname
go
drop table #tmp1
go
select *
into #tmp1 
from #tmp2
go





--(2806 row(s) affected)
--34 per month
alter table #tmp1 add Mth varchar(30) , VisitID uniqueidentifier 
go
update #tmp1
set Mth = datename (mm, opdate), VisitID = newid()
go
--(90604 row(s) affected)
drop table #tmp3
go
select a.*, Row_Number() over(partition by mth order by visitID) RowNo
into #tmp3
from #tmp1 a
go
drop table #tmp4
go
select *
into #tmp4
from #tmp3
where RowNo <=35
go
select *
from #tmp4
go
drop table #tmp1
go
select *
into #tmp1
from #tmp4
go



drop table #tmp3
go
alter table #tmp2 add Qtr int
go
update #tmp2
set Qtr = datepart (q, opdate)
go
with FirstVisit ([site], ptvid, opdate) as
(select [site], ptvid, min(opdate) opdate
from #tmp2
group by[site], ptvid)
select distinct a.*
into #tmp3
from #tmp2 a
join FirstVisit b on a.ptvid = b.ptvid and a.site = b.site
where a.opdate = b.opdate
go
delete a
from #tmp3 a
join #tmp3 b on a.ptvid = b.ptvid and a.site = b.site
where a.opdate2 >b.opdate2
go
delete a
from #tmp3 a
join #tmp3 b on a.ptvid = b.ptvid and a.site = b.site
where a.locname < b.locname
go
delete a
from #tmp3 a
join #tmp3 b on a.ptvid = b.ptvid and a.site = b.site
where a.locname2 < b.locname2
go
alter table #tmp3 add PTid uniqueidentifier
go
update #tmp3
set PTid = newid()
go
drop table #tmp
go
select top 100 *
into #tmp
from #tmp3
where qtr =1
order by ptid
go
insert into #tmp
select top 100 *
from #tmp3
where qtr =2
order by ptid
go
insert into #tmp
select top 100 *
from #tmp3
where qtr =3
order by ptid
go
insert into #tmp
select top 100 *
from #tmp3
where qtr =4
order by ptid
go




drop table houdw.dbo.Trigger2
go

select ptname, ptssn, locname Clinic1, dssid dssid1, creditdssid creditdssid1, opdate opdate,
                               locname2 Clinic2, dssid2, creditdssid2, opdate2
into houdw.dbo.Trigger2
from #tmp2 a
join houz.dbo.dimptid b on a.ptvid = b.ptvid
go
drop table Trigger2control
go
select ptname, ptssn, locname clinic, dssid, creditdssid, opdate
into Trigger2control
from #tmp4 a
join houz.dbo.dimptid b on a.ptvid = b.ptvid
go
----------------------------------
-----------------------------------
--Patient demographics: Race, gender, age, income, zip code.  
drop table #demo
go
select a.site, a.ptvid, race, gender, age, zip
into #demo
from #tmp a
join dimptdemo b on a.ptvid = b.ptvid and a.site = b.site
go
alter table #demo add income money
go
update a
set a.income = b.income
from #demo a
join means b on a.ptvid = b.ptvid and a.site = b.site
where testdate between '10/01/06' and '10/01/07'
go
drop table #demo1
go
select a.site, a.ptvid, race, gender, age, zip
into #demo1
from #tmp1 a
join dimptdemo b on a.ptvid = b.ptvid and a.site = b.site
go
alter table #demo1 add income money
go
update a
set a.income = b.income
from #demo1 a
join means b on a.ptvid = b.ptvid and a.site = b.site
where testdate between '10/01/06' and '10/01/07'
go
-------
-------
drop table #vital
go
select a.site, a.ptvid, [type], numresult, systolic, diastolic, vitaldate
into #vital
from vitals a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
where cast (cast(opdate as varchar(16)) as datetime) =
          cast (cast(vitaldate as varchar(16)) as datetime)
and [type] in ('blood pressure','TEMPERATURE','RESPIRATION','PULSE')
go
drop table #vital1
go
select a.site, a.ptvid, [type], numresult, systolic, diastolic, vitaldate
into #vital1
from vitals a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
where cast (cast(opdate as varchar(16)) as datetime) =
          cast (cast(vitaldate as varchar(16)) as datetime)
and [type] in ('blood pressure','TEMPERATURE','RESPIRATION','PULSE')
go
-----
-----
--Lab values
--All lab values 30 days prior (including day of index visit)
--CBC chemistry
drop table #lab
go
select a.site, a.ptvid, SpecDate, Result, NumResult, TstName
into #lab
from chlab a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
where SpecDate between dateadd(dd, -30, opdate) and opdate
go
drop table #lab1
go
select a.site, a.ptvid, SpecDate, Result, NumResult, TstName
into #lab1
from chlab a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
where SpecDate between dateadd(dd, -30, opdate) and opdate
go
----------------------
------------------------
--Comorbidity data:  diagnosis up to 1 year prior to the index visit
--Relevant chronic diseases
--Diabetes
--Hypertension
--COPD
--CAD
--CHF
--Psychiatric disease (don’t include tobacco)
--Cancer – active with in five years
drop table #comorb
go
select a.site, a.ptvid, icd9, a.opdate
into #comorb
from opdx a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
where left(icd9, 3) in ('250','401','414','428','490', '491', '492', '494', '496')
and a.opdate between dateadd(dd, -365.25, b.opdate) and b.opdate
go
drop table #mh
go
select a.site, a.ptvid ,a. icd9, a.opdate
into #mh
from opdx a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
join dimicd9 c on a.icd9 = c.icd9
where sdc <>'Mental Retardation'
and mdc = 'Mental Disorders'
and a.icd9 not in 
('305.1','305.10','305.11','305.12','305.13')
and a.opdate between dateadd(dd, -365.25, b.opdate) and b.opdate
go
--(3032 row(s) affected)
insert into #comorb
select *
from #mh
go
drop table #ca
go
select  a.site, a.ptvid ,a. icd9, a.opdate
into #ca
from opdx a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
join dimicd9 c on a.icd9 = c.icd9
where sdc <> 'Benign Neoplasms'
and mdc = 'neoplasms'
and a.opdate between dateadd(dd, -365.25*5, b.opdate) and b.opdate
union
select  a.site, a.ptvid ,a. icd9, a.opdate
from houhist.dbo.opdx a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
join dimicd9 c on a.icd9 = c.icd9
where sdc <> 'Benign Neoplasms'
and mdc = 'neoplasms'
and a.opdate between dateadd(dd, -365.25*5, b.opdate) and b.opdate
go
insert into #comorb
select *
from #ca
go

-------------------------------
-------------------------------
drop table #comorb1
go
select a.site, a.ptvid, icd9, a.opdate
into #comorb1
from opdx a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
where left(icd9, 3) in ('250','401','414','428','490', '491', '492', '494', '496')
and a.opdate between dateadd(dd, -365.25, b.opdate) and b.opdate
go
drop table #mh1
go
select a.site, a.ptvid ,a. icd9, a.opdate
into #mh1
from opdx a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
join dimicd9 c on a.icd9 = c.icd9
where sdc <>'Mental Retardation'
and mdc = 'Mental Disorders'
and a.icd9 not in 
('305.1','305.10','305.11','305.12','305.13')
and a.opdate between dateadd(dd, -365.25, b.opdate) and b.opdate
go
--(3032 row(s) affected)
insert into #comorb1
select *
from #mh1
go
drop table #ca1
go
select  a.site, a.ptvid ,a. icd9, a.opdate
into #ca1
from opdx a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
join dimicd9 c on a.icd9 = c.icd9
where sdc <> 'Benign Neoplasms'
and mdc = 'neoplasms'
and a.opdate between dateadd(dd, -365.25*5, b.opdate) and b.opdate
union
select  a.site, a.ptvid ,a. icd9, a.opdate
from houhist.dbo.opdx a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
join dimicd9 c on a.icd9 = c.icd9
where sdc <> 'Benign Neoplasms'
and mdc = 'neoplasms'
and a.opdate between dateadd(dd, -365.25*5, b.opdate) and b.opdate
go
insert into #comorb1
select *
from #ca1
go
--Telephone calls to and from patients (evidence—such as an telephone clinic encounter note)
--+ or – 30 days of index visit
--How many telephone calls occurred before and after the index visit.
--Total number of telephone calls that occurred
drop table #tel
go
select distinct amiscode dssid
into #tel
from dimamis
where amisname like '%telephone%'
go
--(31 row(s) affected)
drop table #tele
go
select a.site, a.ptvid, a.locname Clinic, a.dssid, c.creditdssid, a.opdate
into #tele
from openc a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
join dimloc c on a.locien = c.locien and a.site = c.site
where a.opdate between dateadd(dd, -30, b.opdate) and dateadd(dd, 30, b.opdate)
and 
(a.dssid in
(select dssid from #tel) 
or 
c.creditdssid in 
(select dssid from #tel))
go
--(392 row(s) affected)
drop table #tele1
go
select a.site, a.ptvid, a.locname Clinic, a.dssid, c.creditdssid, a.opdate
into #tele1
from openc a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
join dimloc c on a.locien = c.locien and a.site = c.site
where a.opdate between dateadd(dd, -30, b.opdate) and dateadd(dd, 30, b.opdate)
and 
(a.dssid in
(select dssid from #tel) 
or 
c.creditdssid in 
(select dssid from #tel))
go
--(202 row(s) affected)

--Number and type of medicines being prescribed at the time of index visit (excluding things like bandages)
drop table #rx
go
select a.site, a.ptvid, drugname, filldate
into #rx
from rxopfill a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
where dateadd(dd, daysupply, filldate) >=opdate
and filldate <opdate
go
--(3063 row(s) affected)
drop table #rx1
go
select a.site, a.ptvid, drugname, filldate
into #rx1
from rxopfill a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
where dateadd(dd, daysupply, filldate) >=opdate
and filldate <opdate
go
--Number of hospitalizations in the previous 6 months
drop table #admit
go
select a.site, a.ptvid, admdate
into #admit
from ptf a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
where feebasis = 'n'
and admdate between dateadd(dd, -180, opdate) and opdate
go
--(96 row(s) affected)
drop table #admit1
go
select a.site, a.ptvid, admdate
into #admit1
from ptf a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
where feebasis = 'n'
and admdate between dateadd(dd, -180, opdate) and opdate
go
--(28 row(s) affected)
use tempdb
go
drop table houdw.dbo.trigger2
go
select PtName, PtSSN, LocName, DSSid, CreditDSSid, OpDate, 
                                  LocName2, DSSid2, CreditDSSid2, OpDate2
into houdw.dbo.trigger2
from houz.dbo.dimptid a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
go
--(400 row(s) affected)
drop table houdw.dbo.control2
go
select PtName, PtSSN, LocName, DSSid, CreditDSSid, OpDate

into houdw.dbo.control2
from houz.dbo.dimptid a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
go
--(420 row(s) affected)
drop table houdw.dbo.trig2demo
go
select a.PtName, a.PtSSN, race, gender, age, zip, income
into houdw.dbo.trig2demo
from houz.dbo.dimptid a
join #demo b on a.ptvid = b.ptvid and a.site = b.site
go
--(400 row(s) affected)
drop table houdw.dbo.control2demo
go
select a.PtName, a.PtSSN, race, gender, age, zip, income
into houdw.dbo.control2demo
from houz.dbo.dimptid a
join #demo1 b on a.ptvid = b.ptvid and a.site = b.site
go
--(420 row(s) affected)
drop table houdw.dbo.trig2vital
go
select PtName, PtSSN, [type], numresult, systolic, diastolic, vitaldate
into houdw.dbo.trig2vital
from houz.dbo.dimptid a
join #vital b on a.ptvid = b.ptvid and a.site = b.site
go
drop table houdw.dbo.control2vital
go
select PtName, PtSSN, [type], numresult, systolic, diastolic, vitaldate
into houdw.dbo.control2vital
from houz.dbo.dimptid a
join #vital1 b on a.ptvid = b.ptvid and a.site = b.site
go
--lab
drop table houdw.dbo.trig2lab
go
select PtName, PtSSN, SpecDate, Result, NumResult, TstName
into houdw.dbo.trig2lab
from houz.dbo.dimptid a
join #lab b on a.ptvid = b.ptvid and a.site = b.site
go
drop table houdw.dbo.control2lab
go
select PtName, PtSSN, SpecDate, Result, NumResult, TstName
into houdw.dbo.control2lab
from houz.dbo.dimptid a
join #lab1 b on a.ptvid = b.ptvid and a.site = b.site
go
----comorbidity
drop table houdw.dbo.trig2comorb
go
select PtName, PtSSN, ICD9, opdate
into houdw.dbo.trig2comorb
from houz.dbo.dimptid a
join #comorb b on a.ptvid = b.ptvid and a.site = b.site
go
drop table houdw.dbo.control2comorb
go
select PtName, PtSSN, ICD9, opdate
into houdw.dbo.control2comorb
from houz.dbo.dimptid a
join #comorb1 b on a.ptvid = b.ptvid and a.site = b.site
go
--telephone
drop table houdw.dbo.trig2tele
go
select PtName, PtSSN, Clinic, dssid, creditdssid, opdate
into houdw.dbo.trig2tele
from houz.dbo.dimptid a
join #tele b on a.ptvid = b.ptvid and a.site = b.site
go
drop table houdw.dbo.control2tele
go
select PtName, PtSSN, Clinic, dssid, creditdssid, opdate
into houdw.dbo.control2tele
from houz.dbo.dimptid a
join #tele1 b on a.ptvid = b.ptvid and a.site = b.site
go
--admits
drop table houdw.dbo.trig2admit
go
select PtName, PtSSN, admdate
into houdw.dbo.trig2admit
from houz.dbo.dimptid a
join #admit b on a.ptvid = b.ptvid and a.site = b.site
go
drop table houdw.dbo.control2admit
go
select PtName, PtSSN, admdate
into houdw.dbo.control2admit
from houz.dbo.dimptid a
join #admit1 b on a.ptvid = b.ptvid and a.site = b.site
go
--rx
drop table houdw.dbo.trig2trx
go
select PtName, PtSSN, drugname, filldate
into houdw.dbo.trig2rx
from houz.dbo.dimptid a
join #rx b on a.ptvid = b.ptvid and a.site = b.site
go
drop table houdw.dbo.control2rx
go
select PtName, PtSSN, drugname, filldate
into houdw.dbo.control2rx
from houz.dbo.dimptid a
join #rx1 b on a.ptvid = b.ptvid and a.site = b.site
go
---
---
use houdw
go
create view vAllDx as
select [site], ptvid, icd9, opdate dxdate
from opdx
union 
select [site], ptvid, icd9, opdate
from houhist.dbo.opdx
union
select [site], ptvid, icd9, disdate
from ptfdx
go
drop table #alldx
go
select a.site, a.ptvid, icd9, min(dxdate) dxdate
into #alldx
from vAllDx a
join #tmp b on a.ptvid = b.ptvid and a.site = b.site
where dxdate <opdate
group by a.site, a.ptvid, icd9
go
--(18100 row(s) affected)
drop table #alldx1
go
select a.site, a.ptvid, icd9, min(dxdate) dxdate
into #alldx1
from vAllDx a
join #tmp1 b on a.ptvid = b.ptvid and a.site = b.site
where dxdate <opdate
group by a.site, a.ptvid, icd9
go
--(12234 row(s) affected)

use tempdb
go
drop table houdw.dbo.trig2alldx
go
select PtName, PtSSN, icd9, dxdate
into houdw.dbo.trig2alldx
from houz.dbo.dimptid a
join #alldx b on a.ptvid = b.ptvid and a.site = b.site
go
drop table houdw.dbo.control2alldx
go
select PtName, PtSSN, icd9, dxdate
into houdw.dbo.control2alldx
from houz.dbo.dimptid a
join #alldx1 b on a.ptvid = b.ptvid and a.site = b.site
go








 



















