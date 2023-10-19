SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4;


--Select Data that we are going to be using

Select location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


--Looking at Total Cases vs Total Deaths
-- Shows likelihood dying if you contract covid in your country

Select  location,
		Date, 
		total_cases, 
		total_deaths, 
		ROUND((total_deaths / total_cases)*100,2) AS DeathPercantage
FROM CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT  location,
		Date, 
		population,
		total_cases, 
		ROUND((total_cases /  population)*100,2) AS Percent_Population_Infected
FROM	CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2;



--- Looking at countries with highest infection rate compared to population

SELECT  Location,
		population,
		MAX(total_cases) AS HighestInfectionCount,
		ROUND(MAX((total_cases / population)*100),2) AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
WHERE	continent is not null
GROUP BY Location,
		 population
ORDER BY PercentPopulationInfected DESC;


--Showing countries with highest death count per population

SELECT  Location,
		MAX(CAST(Total_deaths as INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

SELECT  continent,
		MAX(CAST(Total_deaths as INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--GLOBAL NUMBERS

SELECT  SUM(new_cases) AS TotalCases,
		SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
		ROUND(SUM( CAST(new_deaths AS INT)) / SUM(new_cases)*100 ,2) AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null;



-- Looking at total population vs vaccinations

SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		dea.new_vaccinations,
		SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated / population) * 100
FROM	CovidDeaths AS dea
JOIN	CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

--First method: USING CTE

WITH PopVsVac (continent, location, date,population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		dea.new_vaccinations,
		SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated / population) * 100
FROM	CovidDeaths AS dea
JOIN	CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT	*,
		(RollingPeopleVaccinated / population) * 100
FROM	PopVsVac
ORDER BY 2,3;


--Second Method: Using TEMP TABLE

--DROP Table IF EXISTS #PercentPopulationVaccinated

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

SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		dea.new_vaccinations,
		SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated / population) * 100
FROM	CovidDeaths AS dea
JOIN	CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT	*,
		(RollingPeopleVaccinated / population) * 100
FROM	#PercentPopulationVaccinated
ORDER BY 2,3;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS

SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		dea.new_vaccinations,
		SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated / population) * 100
FROM	CovidDeaths AS dea
JOIN	CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT	*
FROM	PercentPopulationVaccinated