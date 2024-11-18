
--Select Data that we are going to be using

SELECT * FROM CovidDeaths

SELECT  location,date, total_cases, new_cases, total_deaths,population
FROM CovidDeaths
ORDER BY 1,2 


---Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country 

SELECT  
	location,
	date,
	total_deaths,
	total_cases,
	(total_deaths/total_cases)*100 AS PercentDeath
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2



-- Looking at total cases vs population
--shows what percentage of population got covid

SELECT  
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE  location LIKE 'Iran' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking a countries with Highest Infection Rate Compared to population

SELECT  
	location,
	population,
	MAX(total_cases)  AS HigestInfectionRate,
	MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY population DESC

-- Showing Countries With Highest Death Count Per Population
SELECT  
	location,
	MAX(CAST(total_deaths AS INT))  AS TotalDeathCount	
FROM CovidDeaths
WHERE continent IS NOT  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET's BREAK THINGS DOWN BY CONTINENT

-- showing the contintents with the highest death count per population

SELECT  
	continent,
	MAX(CAST(total_deaths AS INT))  AS TotalDeathCount	
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
SELECT  
	
	SUM(new_cases) AS Total_Cases ,
	SUM(CAST(new_deaths as int)) AS Total_Death,
	SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking At Total Population vs vaccination
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
 join CovidVaccinations vac 
		ON dea.location= vac.location
		AND dea.date= vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

---USE CTE
WITH PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM CovidDeaths dea
 full join CovidVaccinations vac 
		ON dea.location= vac.location
		AND dea.date= vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac



---TEMP TABLE
 
 DROP TABLE IF  EXISTS #PercentPopulationVaccinated
 CREATE TABLE  #PercentPopulationVaccinated
 (
 continent nvarchar (255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

 INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
 join CovidVaccinations vac 
		ON dea.location= vac.location
		AND dea.date= vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

 SELECT *,(RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated




 -- Creating View to store date for later visualizations
 Create view PercentPopulationVaccinated AS
 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
 join CovidVaccinations vac 
		ON dea.location= vac.location
		AND dea.date= vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated