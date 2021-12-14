set search_path='enceladus';
select flybys.name,
	inms.created_at,
	inms.altitude,
	inms.source,
	chemistry.formula,
	inms.high_sensitivity_count,
	inms.low_sensitivity_count
from flybys
inner join inms on flyby_id = flybys.id
inner join chemistry on chemistry.molecular_weight = inms.mass
limit 100;



set search_path='enceladus';
drop materialized view if exists results_per_flyby;
create materialized view results_per_flyby as
select flybys.name,
	flybys.date,
	inms.source,
	chemistry.name as compound,
	chemistry.formula,
	sum(inms.high_sensitivity_count) as sum_high,
	sum(inms.low_sensitivity_count) as sum_low
from flybys
inner join inms on flyby_id = flybys.id
inner join chemistry on chemistry.molecular_weight = inms.mass
group by flybys.name, flybys.date, inms.source, chemistry.name, chemistry.formula
order by flybys.date;

