-- Lung, BY AJCC, EXCLUDE SMALL CELL

SELECT count(*) as n, Stagegroupingajcc 
FROM [ORD_Singh_202001030D].[Src].[Oncology_Oncology_Primary_165_5]
		where (SitegpX like 'lung%' or ICDOSite like 'lung%' or PrimarysiteX like 'lung%')
		and not HistologyIcdo3X like 'small%' and not HistologyIcdo3X  like 'carcinoid%' and not HistologyIcdo3X  like 'neuro%'	
		group by Stagegroupingajcc
	order by n desc

/*
n	Stagegroupingajcc
21749	I
12729	IV
10144	III
8877	NULL
5852	II
2645	Unk/Uns
258	NA
212	0
*/

-- EARLY

SELECT count(*) 
FROM [ORD_Singh_202001030D].[Src].[Oncology_Oncology_Primary_165_5]
		where (SitegpX like 'lung%' or ICDOSite like 'lung%' or PrimarysiteX like 'lung%')
		and not HistologyIcdo3X like 'small%' and not HistologyIcdo3X  like 'carcinoid%' and not HistologyIcdo3X  like 'neuro%'	
		and (Stagegroupingajcc = 'I' or Stagegroupingajcc = 'II' or Stagegroupingajcc = '0')
--27813

--LATE

SELECT count(*) 
FROM [ORD_Singh_202001030D].[Src].[Oncology_Oncology_Primary_165_5]
		where (SitegpX like 'lung%' or ICDOSite like 'lung%' or PrimarysiteX like 'lung%')
		and not HistologyIcdo3X like 'small%' and not HistologyIcdo3X  like 'carcinoid%' and not HistologyIcdo3X  like 'neuro%'	
		and (Stagegroupingajcc = 'III' or Stagegroupingajcc = 'IV')
--22873




-------- COLON --------

select count(*) as n, [StageGroupingajcc] 
  FROM [ORD_Singh_202001030D].[Src].[Oncology_Oncology_Primary_165_5]
  where (SitegpX like 'colo%' or ICDOSite like 'colo%' or PrimarysiteX like 'colo%')
  and not (Histologyicdo3X like '%carcinoid%' or 
  Histologyicdo3X like '%neuro%' or 
  Histologyicdo3X like '%adenoma%' or 
  Histologyicdo3X like '%lymph%' or 
  Histologyicdo3X like 'gastrointestinal strom%' or
  Histologyicdo3X like '%sarcoma%')
group by StageGroupingajcc
order by n desc

/*
n	StageGroupingajcc
6781	II
6699	I
5897	III
2790	IV
2469	NULL
1999	Unk/Uns
1738	0
28	NA
*/
