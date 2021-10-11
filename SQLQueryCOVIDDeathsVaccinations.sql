Select *
From PortfolioProject..CovidDeaths$
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

-- Select Data to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location = 'United States'
Order by 1,2

-- Total Cases vs Population
-- Shows what % of population got COVID

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
-- Where location = 'United States'
Order by 1,2

-- Countries with highest infection rate compared to population rate

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
-- Where location = 'United States'
Group by Location, Population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location = 'United States'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- By Continent wrong way to accommodate drill down

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location = 'United States'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- By Continent correct way

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location = 'United States'
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Global Numbers - total

Select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
-- Where location = 'United States'
Where continent is not null
--Group by date
Order by 1,2

-- Global Numbers - date

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
-- Where location = 'United States'
Where continent is not null
Group by date
Order by 1,2

-- Total Pop vs Vac

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) As RunningTotal
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



-- CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RunningTotal)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) As RunningTotal
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RunningTotal/Population)*100 as PercentVacByPop
From PopVsVac

-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RunningTotal numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) As RunningTotal
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RunningTotal/Population)*100 as PercentVacByPop
From #PercentPopulationVaccinated

-- View of Highest Death Count per Population

Create View HighestDeathCountPerPop as
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location = 'United States'
Where continent is not null
Group by Location
--Order by TotalDeathCount desc
