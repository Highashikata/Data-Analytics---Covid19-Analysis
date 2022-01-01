/* Displaying all of our Data to check if it was successfully uploaded  */

-- DATA Exploration - EDA

SELECT *
FROM [Covid19-Analysis]..['Covid19_Deaths']
ORDER BY 3, 5

SELECT *
FROM [Covid19-Analysis]..Covid19_Vaccinations

/* Selecting the data that we are going to be working with */
SELECT continent, location, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as dead_perecentage
FROM [Covid19-Analysis]..['Covid19_Deaths']
ORDER BY location


/* Looking for the same data but for multiple locations */

-- I will begin with my country <3 MOROCCO

SELECT continent, location, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as dead_percentage
FROM [Covid19-Analysis]..['Covid19_Deaths']
WHERE location = 'Morocco'

-- Now we are gonna see about the country of my residence
SELECT location, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as dead_percentage
FROM [Covid19-Analysis]..['Covid19_Deaths']
WHERE location like '%fr%'

-- We are gonna see, about United States of America
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 as percent_of_contamination, (total_deaths/total_cases)*100 as dead_percentage
FROM [Covid19-Analysis]..['Covid19_Deaths']
WHERE location like '%united s%'
ORDER BY percent_of_contamination DESC

-- Displaying the Data of Countries with the highest infection rate
SELECT continent, location, population, MAX(total_cases) AS HightestContaminationCount, MAX((total_cases/population))*100 AS Percentage_of_Infection
FROM [Covid19-Analysis]..['Covid19_Deaths']
GROUP BY location, population, continent
ORDER BY Percentage_of_Infection DESC

-- Displaying Countries Based on the Death Count
SELECT continent, location, MAX(total_deaths) as DeathCasesCount
FROM [Covid19-Analysis]..['Covid19_Deaths']
GROUP BY location, continent
ORDER BY DeathCasesCount DESC



-- Showing Countries with the highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM [Covid19-Analysis]..['Covid19_Deaths']
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Showing the Countries where the continent is defined
SELECT iso_code, location, total_deaths, continent
FROM [Covid19-Analysis]..['Covid19_Deaths']
WHERE continent is NOT null
GROUP BY iso_code, location, total_deaths, continent

-- Showing the countries with the highest death count par population, with a well defined continent
SELECT location, MAX(CAST(total_deaths AS int)) AS HigheDeathCount
FROM [Covid19-Analysis]..['Covid19_Deaths']
WHERE continent is NOT NULL
GROUP BY location
ORDER BY HigheDeathCount DESC


-- Breaking Down using continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS HigheDeathCount
FROM [Covid19-Analysis]..['Covid19_Deaths']
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY HigheDeathCount DESC

-- Showing the Sum of the globe's death
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Covid19-Analysis]..['Covid19_Deaths']
WHERE continent is not null
order by 1, 2


-- Rechecking for the Vaccination Table
SELECT *
FROM [Covid19-Analysis]..Covid19_Vaccinations
ORDER BY new_tests DESC

-- Joining the 2 tables
SELECT *
FROM [Covid19-Analysis]..Covid19_Vaccinations Vaccin
INNER JOIN [Covid19-Analysis]..['Covid19_Deaths'] Death
	ON Vaccin.continent = Death.continent
	AND Death.date = Vaccin.date

-- Showing the percentage of vaccinated people
SELECT Death.continent, Death.location, Death.population, Death.date,Vaccin.new_vaccinations
FROM [Covid19-Analysis]..Covid19_Vaccinations Vaccin
INNER JOIN [Covid19-Analysis]..['Covid19_Deaths'] Death
	ON Vaccin.continent = Death.continent
	AND Death.date = Vaccin.date
WHERE Death.continent is NOT NULL
ORDER BY 2, 3


-- Showing the percentage of vaccinated people using PARTITION BY function 
SELECT Death.continent, Death.location, Death.population, Death.date, SUM(CONVERT(int, Vaccin.new_vaccinations)) AS Total_of_Vaccinations
FROM [Covid19-Analysis]..Covid19_Vaccinations Vaccin
INNER JOIN [Covid19-Analysis]..['Covid19_Deaths'] Death
	ON Vaccin.continent = Death.continent
	AND Death.date = Vaccin.date
WHERE Death.continent is NOT NULL
GROUP BY Death.location, Death.continent, Death.population, Death.date
ORDER BY 2, 3


-- Showing the percentage of vaccinated people using PARTITION BY function 
-- Using CTE Commun Table Expression
With PopulationVSVaccination (continent, location, population, date, RollingPeopleVaccinated)
AS
(
SELECT Death.continent, Death.location, Death.population, Death.date, SUM(CONVERT(int, Vaccin.new_vaccinations)) OVER(PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM [Covid19-Analysis]..Covid19_Vaccinations Vaccin
INNER JOIN [Covid19-Analysis]..['Covid19_Deaths'] Death
	ON Vaccin.continent = Death.continent
	AND Death.date = Vaccin.date
WHERE Death.continent is NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopulationVSVaccination


-- Method 2: Using the Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
 location nvarchar(255),
 population numeric, 
 date datetime,
 RollingPeopleVaccinated numeric
 )


INSERT INTO #PercentPopulationVaccinated

SELECT Death.continent, Death.location, Death.population, Death.date, SUM(CONVERT(int, Vaccin.new_vaccinations)) OVER(PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM [Covid19-Analysis]..Covid19_Vaccinations Vaccin
INNER JOIN [Covid19-Analysis]..['Covid19_Deaths'] Death
	ON Vaccin.continent = Death.continent
	AND Death.date = Vaccin.date
WHERE Death.continent is NOT NULL


SELECT *
FROM #PercentPopulationVaccinated


-- Creating View to store Data for later DataViz

CREATE VIEW PercentPopulationVaccinated AS

SELECT Death.continent, Death.location, Death.population, Death.date, SUM(CONVERT(int, Vaccin.new_vaccinations)) OVER(PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM [Covid19-Analysis]..Covid19_Vaccinations Vaccin
INNER JOIN [Covid19-Analysis]..['Covid19_Deaths'] Death
	ON Vaccin.continent = Death.continent
	AND Death.date = Vaccin.date
WHERE Death.continent is NOT NULL

SELECT * 
FROM PercentPopulationVaccinated
