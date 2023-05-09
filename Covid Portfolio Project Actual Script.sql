SELECT *
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Show likelihood of dying if you contract covid in your country
SELECT  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE location = 'Indonesia' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs populations
-- Show what percentage of Population got Covid
SELECT location, date, population, total_cases, (total_cases/population)* 100 AS PercentagePopulationInfected
FROM MyPortfolio..CovidDeaths
WHERE location = 'Indonesia' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compare to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectedCount, 
							 MAX ((total_cases/population))* 100 AS PercentagePopulationInfected
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


-- Showing Countries with Hightest Death Count per Population
SELECT Location, MAX (CAST(total_deaths AS INT)) AS TotalDeathCount
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX (CAST(total_deaths AS INT)) AS TotalDeathCount
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  TotalDeathCount DESC

-- Showing The Continent with The Highest Death count Per Population
SELECT continent, MAX (CAST(total_deaths AS INT)) AS TotalDeathCount
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
SUM (new_deaths) / Nullif (SUM (new_cases),0) *100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1,2



SELECT*
FROM CovidVaccinations
WHERE continent is not null
order by 1,2

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths dea
JOIN MyPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE
WITH PopVsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths dea
JOIN MyPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT*, (RollingPeopleVaccinated/Population) * 100
FROM PopVsVac


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
Continent NVARCHAR (255),
Location NVARCHAR (255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths dea
JOIN MyPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT*, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

-- Creating View to Store Data for later Visualizations
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths dea
JOIN MyPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*
FROM PercentPopulationVaccinated