SELECT * 
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--SELECT * 
--FROM [dbo].[CovidVaccinations$]
--ORDER BY 3,4



--Select Data that we are going to be using

Select location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2



--Looking at Total Cases vs Total Deaths
-- Shows likelihood dying if you contract covid in your country

Select location, Date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercantage
FROM CovidDeaths$
WHERE location like '%turkey%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select  location,
		Date, 
		population,
		total_cases, 
		(total_cases /  population)*100 AS Percent_Population_Infected
FROM	CovidDeaths$
WHERE location like '%turkey%'
ORDER BY 1,2


--- Looking at countries with highest infection rate compared to population

Select  Location,
		population,
		MAX(total_cases) AS Highest_Infection_count,
		MAX((total_cases / population)*100) AS Percent_Population_Infected
FROM CovidDeaths$
--WHERE location like '%turkey%'
GROUP BY Location,
		 population
ORDER BY Percent_Population_Infected DESC;