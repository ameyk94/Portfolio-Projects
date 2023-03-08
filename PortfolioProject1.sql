SELECT *
From [Portfolio Project]..CovidDeaths$
order by 3,4

--SELECT *
--From [Portfolio Project]..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths$
order by 1,2

-- Looking at the total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
Where location like '%Canada%'
order by 1,2 

-- Looking at total cases vs population
-- Shows what % of population has contracted COVID
Select Location, date, total_cases, population,(total_cases/population)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
Where location like '%Canada%'
order by 1,2 

-- Looking at total cases vs population
-- Shows what % of population has contracted COVID
Select Location, date, total_cases, population,(total_cases/population)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
Where location like '%India%'
order by 1,2

-- Looking at total cases vs population
-- Shows what % of population has contracted COVID
Select Location, date, total_cases, population,(total_cases/population)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
Where location like '%states%'
order by 1,2 

-- Looking at countries with highest infection rate compared to population
Select Location,population,max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Breaking down numbers by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
--Where location like '%Canada%'
where continent is not null
--Group By date
order by 1,2 



--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations,	RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentVacc
From PopvsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as percentVacc
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated