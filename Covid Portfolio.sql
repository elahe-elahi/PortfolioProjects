select *
from PortfolioProject..Death
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccination
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Death
order by 1,2

--Looking at total cases vs total death

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Percantage_deaths
from PortfolioProject..Death
order by 1,2


--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, CAST(total_deaths AS decimal)/ CAST(total_cases AS decimal)*100 AS Percntage_Deaths
from PortfolioProject..Death
where location like '%states%'
order by 1,2

--Looking at total cases vs population
--shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 AS PercntPopulationInfected
from PortfolioProject..Death
where location like '%states%'
order by 1,2

--Looking at countries with highst infection rate compared to population

select location, population, MAX (total_cases) as HighestInfectionCount, Max(total_cases/population)*100 AS PercntPopulationInfected
from PortfolioProject..Death
--where location like '%states%'
Group by location, population
order by PercntPopulationInfected desc


--showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null
Group by location, population
order by TotalDeathCount desc


--Let's break things down by continent
--showing the continent with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Death
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers
select date, sum(new_cases) as total_newcases, sum(new_deaths) as total_newdeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..Death
--where location like '%states%'
where continent is not null and new_cases<>0
Group by date
order by 1,2


select sum(new_cases) as total_newcases, sum(new_deaths) as total_newdeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..Death
--where location like '%states%'
where continent is not null and new_cases<>0
--Group by date
order by 1,2



select*
from PortfolioProject..Death dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date


--Looking at Total population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccination
--(RollingPeopleVaccination/population)*100
from PortfolioProject..Death dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Ues CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccination
--(RollingPeopleVaccination/population)*100
from PortfolioProject..Death dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccination/population)*100
from PopvsVac


--Temp Table

drop table if exists #PercentPopulationVaccination
create table #PercentPopulationVaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)

insert into #PercentPopulationVaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccination
--(RollingPeopleVaccination/population)*100
from PortfolioProject..Death dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccination/population)*100
from #PercentPopulationVaccination


--Creating View to store data for later visualization

Create View PercentPopulationVaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccination
--(RollingPeopleVaccination/population)*100
from PortfolioProject..Death dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccination
