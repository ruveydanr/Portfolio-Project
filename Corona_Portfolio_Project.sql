-- PORTFOLIO PROJECT--
SELECT
*
FROM covid_deaths
order by location, `date`;

SELECT
*
FROM covid_vaccinations
order by location, `date`;

-- Selecting data that is going to be used
SELECT
	location, `date`, total_cases, new_cases,total_deaths,population
FROM covid_deaths
WHERE continent IS NOT NULL
order by 1,2;

-- Looking at total cases versus total deaths
SELECT
    location, 
    SUM(total_cases) AS Sum_Total_Case,
    SUM(total_deaths) AS Sum_Total_Deaths,
    (SUM(total_deaths) / SUM(total_cases)) * 100 AS DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location;

-- Looking at total case versus population --
-- Shows what percentage of population got Covid--
SELECT
	location,
    `date`,
    total_cases,
    total_deaths,
    population,
    (total_cases/population)* 100 AS CasePercentage
FROM covid_deaths
WHERE continent IS NOT NULL;

-- Which country is got the most infected--
SELECT
	location,
    population,
    MAX(total_cases) AS MAX_total_case,
    MAX((total_cases) / (population))*100 AS CasePercentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY CasePercentage DESC ;

-- Showing countries with highest death count per population --
SELECT
	location,
    MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MAX(total_deaths) DESC;

-- Showing continents with highest death count(WHEN WE TAKE THE VALUE OF CONTINENT NORTH AMERICA VALUE IS INCOMPLETE NOT ADDED CANADA SO I FOUND THE SOLUTION THAT WAY)
SELECT
	location,
    MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global Numbers --
SELECT
	`date`,
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_deaths,
    (SUM(new_deaths) / SUM(new_cases))* 100 AS CaseDeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY `date`
ORDER BY `date`;

SELECT
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_deaths,
    (SUM(new_deaths) / SUM(new_cases))* 100 AS CaseDeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY `date`;

-- Looking at total population versus total vaccinations
SELECT 
	d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS  Vaccination_by_location
FROM covid_deaths d
JOIN covid_vaccinations v
	ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

-- WITH CTEs to analyze population vs vaccination
WITH PopVsVac(continent,location,date,population,new_vaccinations,Vaccination_by_location) AS
(
SELECT 
	d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS  Vaccination_by_location
FROM covid_deaths d
JOIN covid_vaccinations v
	ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *,ROUND((Vaccination_by_location / population) *100, 2) AS VacvsPop_per
FROM PopVsVac;


-- TEMP TABLE
CREATE TEMPORARY TABLE  PercentPopulationVaccinated
(
	Continent nvarchar(255),
    Location nvarchar(255),
    `date` date,
    Population bigint,
    new_vaccinations bigint,
    Vaccination_by_location bigint
);
INSERT INTO PercentPopulationVaccinated (
    Continent,
    Location,
    `date`,
    Population,
    new_vaccinations,
    Vaccination_by_location
)
SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Vaccination_by_location
FROM covid_deaths d
JOIN covid_vaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT 
	*, ROUND((Vaccination_by_location / population)*100, 2) AS VacvsPop
 FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualizations 
CREATE VIEW  PercentPopulationVaccinated AS 
SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Vaccination_by_location
FROM covid_deaths d
JOIN covid_vaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL;




