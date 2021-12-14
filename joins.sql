drop table if exists assignments cascade;
drop table if exists people cascade;
drop table if exists jobs cascade;


create table people(
  id serial primary key,
  name text not null
);

create table jobs(
  id serial primary key,
  name text not null
);

create table assignments(
  people_id int not null references people(id),
  job_id int not null references jobs(id),
  primary key(people_id, job_id)
);

insert into people(name)
values('Darth Vader'),('Apple Dumpling'),('Duke Leto'),('Totoro');

insert into jobs(name)
values('Control the Galaxy'),('Bake Apple Pies'),
      ('Rule Arrakis'),('Play shakuhatchi in tree');

insert into assignments(people_id, job_id)
values
	(1,1),(1,2),
	(2,2),(2,4),
	(4,4),(4,1);

--exclusive inner join
select * from people
inner join assignments on people_id = people.id
inner join jobs on jobs.id = assignments.job_id;

--all data from people
select * from people
left outer join assignments on people_id = people.id
left outer join jobs on jobs.id = assignments.job_id;

--all data from jobs
select * from people
right outer join assignments on people_id = people.id
right outer join jobs on jobs.id = assignments.job_id;

--all data from jobs and people
select * from people
full outer join assignments on people_id = people.id
full outer join jobs on jobs.id = assignments.job_id;

drop table if exists people cascade;
drop table if exists friends cascade;

create table people(
  id serial primary key,
  name text not null
);

create table friends(
  people_id int not null,
  friend_id int not null references people(id),
  primary key (people_id, friend_id)
);

insert into people(name)
values
	('Darth Vader'),
	('Apple Dumpling'),
	('Duke Leto'),
	('Totoro');
insert into friends(people_id, friend_id)
values
	(1,3),(1,4), -- Vader/Leto, Vader/Totoro
	(2,4),(3,4); -- Apple Dumpling/Totoro, Duke Leto/Totoro

--bidirectional relationship
select people.name, friendos.name from people
inner join friends on people.id = friends.people_id
left outer join people as friendos on friends.friend_id = friendos.id;