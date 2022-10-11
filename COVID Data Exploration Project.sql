select * 
from PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4 

select *
from PortfolioProject..CovidVaccinations 
order by 3,4

-- Select data to be used

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Comparing total cases against total deaths
-- This shows us the likelihood of dying if you get Covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at the total cases against the population

select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking up which countries have highest infection rate compared to population

select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Showing countries with the highest death count

select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Let us check the same with respect to continent
-- Showing continents with the highest death count per population


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
-- in general

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Global number per day

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations

-- Using CTE
 
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, (d.date), d.population, v.new_vaccinations, 
sum(convert(bigint,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingCountOfPeopleVac
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location= v.location
and d.date= v.date
where d.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
from PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingCountOfPeopleVac
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location= v.location
and d.date= v.date

select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated

-- Creating a View to store data for later visualiztions
Drop view PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingCountOfPeopleVac
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location= v.location
and d.date= v.date
where d.continent is not null

select * from PercentPopulationVaccinated

--

Create view HighestDeathCount as
select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location

select * from HighestDeathCount
















