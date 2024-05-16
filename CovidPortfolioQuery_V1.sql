SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
Order by 3,4


--SELECT *
--FROM PortfolioProject1..CovidVaccinations
--Order by 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Look at total cases vs population
SELECT Location, date, total_cases, population, (total_cases / population)*100 AS population_percentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--WHERE Location like 'Canada'
ORDER BY 1,2

--Look at countries with highest infection rates
SELECT Location, population, max(total_cases) as HighestInfectionCount, (max(total_cases) / population)*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE Location like 'Canada'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE Location like 'Canada'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC

-- LETS BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE Location like 'Canada'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing continents with largest death counts

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE Location like 'Canada'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--global numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100
as DeathPercentage
FROM PortfolioProject1..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1, 2


SELECT *
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date

--Looking at total population vs vaccination
SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Looking at total population vs vaccination with a rolling count
SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.Location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
AND vac.new_vaccinations is not null
ORDER BY 2,3

--Use CTE
WITH PopVsVac (continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.Location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
AND vac.new_vaccinations is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated /Population)*100
FROM PopVsVac


--Creating view to store data for later vizualisation
Create View PopVsVac as
SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3