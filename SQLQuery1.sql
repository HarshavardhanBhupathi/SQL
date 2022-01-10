


select * from Sqlproj..['covid-death-data$']
	



select location,date ,total_cases, total_deaths,total_cases_per_million,population 
from Sqlproj..['covid-death-data$']
order by 1,2

-- Death rate?
select location,date ,total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_rate
from Sqlproj..['covid-death-data$']
where location= 'India'
order by 1,2

select location,date ,total_cases, population,(total_cases/population)*100 as covid_infected_rate
from Sqlproj..['covid-death-data$']
where location= 'India'
order by 1,2

select location,population, Max(total_cases)as Highest_infect_count,Max(total_cases/population)*100 as covid_infected_rate
from Sqlproj..['covid-death-data$']
group by location,population
order by  covid_infected_rate

select continent,avg(total_cases_per_million) as avgtcpm, max(cast(total_deaths as int)) as Total_death_count
from Sqlproj..['covid-death-data$']
where continent is not null
group by continent
order by Total_death_count desc

select * 
from Sqlproj..['covid-vacc-data$']

select d.location, d.population,vc.people_fully_vaccinated, max(vc.people_fully_vaccinated/d.population)*100  as fully_vacc_rate
from Sqlproj..['covid-death-data$'] d
join Sqlproj..['covid-vacc-data$'] vc
on d.location=vc.location
where d.continent is not null
group by d.location, d.population,vc.people_fully_vaccinated
order by fully_vacc_rate

-- CTE 

;With pv (location, population,people_fully_vaccinated,fully_vacc_rate) 
as
(
select d.location, d.population,vc.people_fully_vaccinated, max(vc.people_fully_vaccinated/d.population)*100  as fully_vacc_rate
from Sqlproj..['covid-death-data$'] d
join Sqlproj..['covid-vacc-data$'] vc
on d.location=vc.location
where d.continent is not null
group by d.location, d.population,vc.people_fully_vaccinated
)

select location,fully_vacc_rate
from pv

;With pc (continent,location, population,date,new_vaccinations,people_vacc) 
as
(
select d.continent,d.location, d.population,d.date,vc.new_vaccinations,
sum(convert(bigint,vc.new_vaccinations)) over (partition by d.location order by d.location,d.date) as people_vacc
from Sqlproj..['covid-death-data$'] d
join Sqlproj..['covid-vacc-data$'] vc
on d.location=vc.location
and d.date=vc.date
where d.continent is not null


)
select *,(people_vacc/population)*100 as popvaccpercent

from pc

--  View for storing data for future visualisations

go
Create View popvaccpercent1 
as select d.continent,d.location, d.population,d.date,vc.new_vaccinations,
sum(convert(bigint,vc.new_vaccinations)) over (partition by d.location order by d.location,d.date) as people_vacc
from Sqlproj..['covid-death-data$'] d
join Sqlproj..['covid-vacc-data$'] vc
on d.location=vc.location
and d.date=vc.date
where d.continent is not null
go

--Temp table
create table popvaccpercent
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
peoplevacc numeric
)
insert into popvaccpercent
select d.continent,d.location,d.date,d.population,vc.new_vaccinations,
sum(convert(bigint,vc.new_vaccinations)) over( partition by d.location order by d.location,d.date) as peoplevacc
from Sqlproj..['covid-death-data$'] d
join Sqlproj..['covid-vacc-data$'] vc
on d.location=vc.location
and d.date=vc.date

select *,(peoplevacc/population)*100
from popvaccpercent






