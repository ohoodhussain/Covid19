select*
from CovidDeath
order by 3,4

--select*
--from CovidVaccination
--order by 3,4
--selecting the data we want to explore 
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeath

--with this line , i keep getting Operand data type varchar is invalid for divide operator.
--select location, total_cases, total_deaths, (total_deaths )/(total_cases )*100 as deatheper
--from CovidDeath
--where location like '%saudi%'
--order by 1,2


--this the only solution that worke for me 
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 
as DeathPercentage

From CovidDeath
where location like '%saudi%'
order by 1,2


--shows Persentge of population got covid in your country
 Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 
 as precentPopulationInfected

From CovidDeath
where location like '%saudi%'
order by 1,2
 

-- Error Operand data type varchar is invalid for divide operator.

-- Select Location, date, total_cases, population, (total_cases / population)*100 as DeathPercentage

--From CovidDeath
--where location like '%saudi%'
--order by 1,2

--look at the highst infected rate in terms of population

 Select Location, population, max(total_cases)as HighstInfectionCount, max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 
 as hightInfectedRate

From CovidDeath
--where location like '%saudi%'
group by Location, population
order by hightInfectedRate desc


--look at the highst death rate in terms of population
 Select Location, population, max(total_deaths)as HighstDeathCount, max(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))*100 
 as precenPopulationDeath

From CovidDeath
--where location like '%saudi%'
group by Location, population
order by precenPopulationDeath desc

--Countris with high death count
 Select Location,MAX(cast(total_deaths as int)) as toatlDeath
From CovidDeath
--where location like '%saudi%'
where continent is not null
group by Location
order by toatlDeath desc

--breack thing downe by continet 
select continent,MAX(cast(total_deaths as int)) as toatlDeath
From CovidDeath
--where location like '%saudi%'
where continent is not null
group by continent
order by toatlDeath desc

--global number
select date, SUM(cast(new_cases as int)) as TotalCases, sum(cast(total_deaths as int)) as totalDeath,sum(cast(total_deaths as int))/ sum(NULLIF(convert (float,new_cases),0))*100 as deatPrec
from CovidDeath
where continent is not null
group by date
order by 1,2


--looking at population vs vacsenation 

select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated 
from CovidDeath dea
join CovidVaccination vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--create CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated 
from CovidDeath dea
join CovidVaccination vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)

select*, (RollingPeoplevaccinated/population)*100 as PrecPopRolling
from PopvsVac

----creating view for later visual

create view DeathPercentage 
as
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100
as DeathPercentage

From CovidDeath
where location like '%saudi%'
 
create view precentPopulationInfected
as
Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 
 as precentPopulationInfected

From CovidDeath
where location like '%saudi%'
--order by 1,2
 

 create view hightInfectedRate
 as
 Select Location, population, max(total_cases)as HighstInfectionCount, max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 
 as hightInfectedRate

From CovidDeath
--where location like '%saudi%'
group by Location, population
--order by hightInfectedRate desc

create view precenPopulationDeath
as
 Select Location, population, max(total_deaths)as HighstDeathCount, max(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))*100 
 as precenPopulationDeath

From CovidDeath
--where location like '%saudi%'
group by Location, population
--order by precenPopulationDeath desc


create view toatlDeath as
 Select Location,MAX(cast(total_deaths as int)) as toatlDeath
From CovidDeath
--where location like '%saudi%'
where continent is not null
group by Location
--order by toatlDeath desc

create view PercePeoplevaccinated
as
WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated 
from CovidDeath dea
join CovidVaccination vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select*, (RollingPeoplevaccinated/population)*100 as PrecPopRolling
from PopvsVac