drop schema if exists enceladus cascade;
create schema enceladus;

set search_path='enceladus';

create table flybys(
  id serial not null primary key,
  name text not null,
  date date
);

insert into flybys(name, date)
values ('E-0', '2005-02-17'),('E-1', '2005-03-09'),('E-2', '2005-07-14'),
('E-3', '2008-03-12'),('E-4', '2008-08-11'),('E-5', '2008-10-09'),('E-6', '2008-10-31'),
('E-7', '2009-11-02'),('E-8', '2009-11-21'),('E-9', '2010-04-28'),('E-10', '2010-05-18'),
('E-11', '2010-08-13'),('E-12', '2010-11-30'),('E-13', '2010-12-21'),('E-14', '2011-10-01'),
('E-15', '2011-10-19'),('E-16', '2011-11-06'),('E-17', '2012-03-27'),('E-18', '2012-04-14'),
('E-19', '2012-05-02'),('E-20', '2015-10-14'),('E-21', '2015-10-28'),('E-22', '2015-12-19');

create table inms(
  id serial primary key,
  created_at timestamp not null,
  date date not null generated always as (created_at::date) stored,
  year int not null generated always as (date_part('year', created_at)) stored,
  flyby_id int references flybys(id),
  altitude numeric(9,2) not null check(altitude > 0),
  source text not null check(source in('osi','csn','osnb','esm')),
  mass numeric(6,3) not null check(mass >=0.125 and mass < 256),
  high_sensitivity_count int not null check(high_sensitivity_count >= 0),
  low_sensitivity_count int not null check(low_sensitivity_count >= 0),
  imported_at timestamptz not null default now()
);

insert into inms(
  flyby_id,
  created_at, 
  altitude, 
  source, 
  mass, 
  high_sensitivity_count,
  low_sensitivity_count
)
select
  (select id from flbys where flybs.date = sclk::date),
  sclk::timestamp,
  alt_t::numeric(9,2),
  source,
  mass_per_charge::numeric(6,3),
  c1counts::int,
  c2counts::int
from csvs.inms
where target='ENCELADUS' and sclk is not null;

update inms set flyby_id = flybys.id from flybys where flybys.date = inms.date;

-- add the chemistry lookup
create table chemistry(
  id serial primary key,
  name text not null,
  formula text not null,
  molecular_weight int not null,
  peak int not null
);

copy chemistry(name, formula,molecular_weight, peak) 
from '[absolute path to]/cassini/csvs/chem_data.csv'
with delimiter ',' header csv;
