Select * 
From PortfolioProjects..[covid-19 death]
where continent is not null
order by 3,4

--Select * 
--From PortfolioProjects..[covid-19 vaccinations]
--order by 3,4

Select Location, date, total_cases, new_cases,total_deaths, population_density 
From PortfolioProjects..[covid-19 death]
order by 1,2 

--looking at total_cases vs total deaths

EXEC sp_help 'dbo.covid-19 death'

ALTER table [dbo].[covid-19 death]
ALTER column total_cases float
GO 

ALTER table [dbo].[covid-19 death]
ALTER column total_deaths float
GO 
--shows liklihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..[covid-19 death]
Where location like '%egypt%'
and continent is not null
order by 1,2 

-- Looking at total_cases vs population
-- shows what precentage of population got covid 


Select Location, date, total_cases, population_density,(total_cases/population_density)*100 as PercentPopulationInfective
From PortfolioProjects..[covid-19 death]
--Where location like '%egypt%'
order by 1,2


--looking at countries with highest infection rate compared to population 


Select Location, population_density, MAX (total_cases) AS HighestInfectionCount , MAX((total_cases/population_density))*100 as PercentPopulationInfective
From PortfolioProjects..[covid-19 death]
group by Location, population_density
order by PercentPopulationInfective desc


--showing countries with the highest death count per population 

Select Location, MAX (cast(total_deaths as int)) AS TotalDeathCount 
From PortfolioProjects..[covid-19 death]
where continent is not null
group by Location
order by TotalDeathCount desc


--let's break things down by continent 

--showing continents with the highest death count per population 


Select location, MAX (cast(total_deaths as int)) AS TotalDeathCount 
From PortfolioProjects..[covid-19 death]
where continent is null
group by location
order by TotalDeathCount desc


--Global Numbers 

set ansi_warnings off 
SET ARITHABORT OFF

Select SUM(new_cases) as total_cases , SUM (new_deaths) as total_deaths , SUM (new_deaths)/SUM (new_cases)*100 as DeathPercentage
From PortfolioProjects..[covid-19 death]
where continent is not null
--GROUP BY date
order by 1,2



select * 
from [PortfolioProjects]..[covid-19 vaccinations]


-- looking at total population vs vaccinations

Select * 
From PortfolioProjects..[covid-19 death] dea
join PortfolioProjects..[covid-19 vaccinations] vac
   on dea.location = vac.location
   and dea.date = vac.date


set ansi_warnings off 
SET ARITHABORT OFF
Select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations
, SUM (CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProjects..[covid-19 death] dea
join PortfolioProjects..[covid-19 vaccinations] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE 
set ansi_warnings off 
SET ARITHABORT OFF
with PopvsVac (continent, location, date, population_density, new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations
, SUM (CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProjects..[covid-19 death] dea
join PortfolioProjects..[covid-19 vaccinations] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/ population_density)*100
from PopvsVac 


-- Temp Table 

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations
, SUM (CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProjects..[covid-19 death] dea
join PortfolioProjects..[covid-19 vaccinations] vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select * , (RollingPeopleVaccinated/ population)*100
from #PercentPopulationVaccinated 


-- creating view to store data for later visualization 

USE [PortfolioProjects]
GO

create view PercentPopulationVaccinated11 as 
Select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations
, SUM (CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProjects..[covid-19 death] dea
join PortfolioProjects..[covid-19 vaccinations] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select * 
from PercentPopulationVaccinated11