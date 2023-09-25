
-- * Select all the data * --
--SELECT * 
--FROM Portfolio_project1.dbo.CovidDeaths
--ORDER BY 3,4

--SELECT * 
--FROM Portfolio_project1.dbo.CovidVaccinations
--ORDER BY 3,4

-- * Select the data that we require from it * -- 
--SELECT location, date, total_cases, total_deaths, new_cases, population 
--FROM Portfolio_project1..CovidDeaths
--ORDER BY 1,2

-- ** total_cases vs total_deaths : Death Percentage in India -- **
--SELECT
--    location,
--    date,
--    CAST(total_cases AS INT) AS total_cases,
--    CAST(total_deaths AS INT) AS total_deaths,
--    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
--FROM
--    Portfolio_project1.dbo.CovidDeaths
--WHERE
--	location LIKE '%India%'
--ORDER BY
--    1, 2;

-- **** total_cases vs population : percentage of people got covid in India? **** --
--SELECT 
--	location, 
--	date,
--	CAST (total_cases AS INT) AS total_cases,
--	CAST (population AS INT) AS population, 
--	(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS InfectionPercentage
--FROM Portfolio_project1..CovidDeaths
--WHERE location like '%India%'
--ORDER BY 1,2

--SELECT * 
--FROM Portfolio_project1..CovidDeaths
--WHERE (location = 'India' AND date = '2020-02-07');

-- **** What country has highest infection rates in terms of total_cases/population? **** --

--SELECT 
--	location,
--	CAST (population AS BIGINT) AS population,
--	MAX(CAST (total_cases AS BIGINT)) AS HighestInfectionCount, 
--	MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100) AS PercentagePopulationInfected
--FROM Portfolio_project1..CovidDeaths
--GROUP BY location, population
--ORDER BY PercentagePopulationInfected DESC;

-- ** Which country has the highest death count per population ** --

-- **** Break down by countries: **** --

--SELECT 
--	location,
--	MAX(CAST (total_deaths AS INT)) AS total_death_count
--FROM Portfolio_project1..CovidDeaths
--Where continent is not null
--GROUP BY location
--ORDER BY total_death_count desc;


-- **** Break down by continents: **** --

--SELECT 
--	continent,
--	MAX(CAST (total_deaths AS INT)) AS total_deaths
--FROM Portfolio_project1..CovidDeaths
--WHERE continent is not null
--GROUP BY continent
--ORDER BY total_deaths desc


-- ** Number of deaths with respect to number of new cases ** --


--SELECT 
--    date, 
--    SUM(CAST(new_cases AS INT)) AS total_cases,
--    SUM(CAST(new_deaths AS INT)) AS total_deaths,
--    (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(CAST(new_cases AS INT))* 100.0, 0)) AS DeathPercentage
--FROM Portfolio_project1..CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1, 2;


-- ** Death Percentage for each continent wrt to the total cases ** --
--SELECT 
--	continent,
--    MAX(CAST(total_cases AS INT)) AS total_cases,
--    MAX(CAST(total_deaths AS INT)) AS total_deaths,
--    (MAX(CAST(total_cases AS INT)) / NULLIF(MAX(CAST(total_deaths AS INT))* 100.0, 0)) AS DeathPercentage
--FROM Portfolio_project1..CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY 1 ;

-- * DO NOT EXECUTE ( DONT UNCOMMENT IF UNNEESSARY) * --
--SELECT * 
--FROM Portfolio_project1..CovidDeaths

--SELECT * 
--FROM Portfolio_project1..CovidVaccinations
-- * ------------------------------------------------------

--SELECT * 
--FROM Portfolio_project1..CovidVaccinations


-- Check positive test cases each continent wise wrt total_tests --****

--SELECT
--    date,
--    continent,
--    SUM(CAST(new_cases AS INT)) AS total_cases
--FROM
--    Portfolio_project1..CovidDeaths
--WHERE
--    continent IS NOT NULL
--GROUP BY
--    date, continent
--ORDER BY
--    date, continent;

--*** Skill used: Using Joins 
-- location & date wise, cummulative number of vaccinations ***--

--Select 
--	dea.continent, 
--	dea.location,
--	dea.date,
--	dea.population,
--	vac.new_vaccinations,
--	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumOfVaccinations
--from Portfolio_project1..CovidDeaths dea
--join Portfolio_project1..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3;

-- Same thing : Using CTE or "Common Table Expression"  ( also calculated the vaccination percentage for each location day-wise)

--with PopvsVac(continent, location, date, population, new_vaccinations, RollingNumOfVaccinations)
--as
--(
--Select 
--	dea.continent, 
--	dea.location,
--	dea.date,
--	dea.population,
--	vac.new_vaccinations,
--	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumOfVaccinations
--from Portfolio_project1..CovidDeaths dea
--join Portfolio_project1..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
----order by 2, 3
--)
--Select *, (RollingNumOfVaccinations/population)*100 as vaccination_percentage
--from PopvsVac


-- ** Same thing : Using Temp table 

--Drop table if exists #PercentagePopulationVaccinated
--Create Table #PercentagePopulationVaccinated
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric, 
--new_vaccinations numeric,
--RollingNumOfVaccinations numeric
--)

--Insert into #PercentagePopulationVaccinated
--Select 
--	dea.continent, 
--	dea.location,
--	dea.date,
--	dea.population,
--	vac.new_vaccinations,
--	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumOfVaccinations
--from Portfolio_project1..CovidDeaths dea
--join Portfolio_project1..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
----order by 2, 3

--Select *, (RollingNumOfVaccinations/population)*100 as vaccination_percentage
--from #PercentagePopulationVaccinated

-- ** Creating views to store data for later visualizations ** --

Create view PercentPopulationVaccinated as 
Select 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumOfVaccinations
from Portfolio_project1..CovidDeaths dea
join Portfolio_project1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated