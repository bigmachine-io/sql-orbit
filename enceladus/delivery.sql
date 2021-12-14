set search_path='enceladus';
copy (select * from enceladus.results_per_flyby) 
to '[absolute path to]/results_per_flyby.csv' header csv;

copy (select
	inms.source,
	chemistry.name as compound,
	chemistry.formula,
	sum(inms.high_sensitivity_count) as sum_high,
	sum(inms.low_sensitivity_count) as sum_low
from flybys
inner join inms on flyby_id = flybys.id
inner join chemistry on chemistry.molecular_weight = inms.mass
group by inms.source, chemistry.name, chemistry.formula)
to '[absolute path to]/overall_results.csv' header csv;