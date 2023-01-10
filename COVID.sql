    select date,[location],population,total_cases,total_deaths,max(total_deaths/total_cases)*100 Death_Presentage from [CovidDeaths-2]
    where [location] like '%states%' 

    -- looking at Total cases Vs Tolal Population 
    -- show the presentage of the population got Covid
    select date, [location], population, total_cases,(total_cases/population)*100 precentPopulationInfected from [CovidDeaths-2]
    where [location] like '%states%'
    ORDER by 2,3



    -- loooking at Countries with the highest infection Rate compared to Population
    select [location],population,max(total_cases) HighestInfectionCount,max(total_cases/population)*100 precentPopulationInfected from [CovidDeaths-2]
    GROUP by location,population
    ORDER by precentPopulationInfected DESC

    -- showing Countries with the Highest Death Count per Population 
    select [location],population,max(total_deaths) HighestDeathCount,round(max(total_deaths/population)*100, 2) precentPopulationDeath from [CovidDeaths-2]
    where continent is not NULL
    GROUP by location,population
    ORDER by max(total_deaths) DESC 

    -- LET'S BREAK THINGS DOWN BY CONTIENENT
    select continent,max(total_deaths) HighestDeathCount,round(max(total_deaths/population)*100, 2) precentPopulationDeath from [CovidDeaths-2]
    where continent is not NULL
    GROUP by continent
    ORDER by max(total_deaths) DESC 
    --Alert Some Date 
    ALTER TABLE [CovidDeaths-2]
    ALTER COLUMN new_cases FLOAT

    ALTER TABLE [CovidDeaths-2]
    ALTER COLUMN new_deaths FLOAT
    
    --GLOBAL NUMBERS
    select SUM(new_cases) Total_cases,sum(new_deaths) Total_deaths,round((sum(new_deaths)/sum(new_cases))*100,2)  Deathprecentage from [CovidDeaths-2]
    where continent is not NULL
    ORDER by 1,2
    -- USE CTE 
    -- JOIN TWO TABLES
    ;with t1(continent,date,location,population,new_vaccinations,RollingPeopleVaccinated)
    AS
    (-- Looking at Tolat Population VS Vaccination
    SELECT Death.continent,Death.[location], Death.[date],Death.population, Vaccination.new_vaccinations,
    SUM(Vaccination.new_vaccinations)OVER (Partition by Death.location ORDER BY Death.date, Death.location)/population RollingPeopleVaccinated
    FROM [CovidDeaths-2] Death 
    JOIN CovidVaccinations Vaccination 
    ON Death.[date] = Vaccination.[date]
    AND Death.[location] = Vaccination.[location] 
    where Death.continent is Not NULL 
    --ORDER by 2,3
    )SELECT * ,(RollingPeopleVaccinated/population)*100 from t1



    -- TEMP TABLE 
    DROP TABLE IF EXISTS #PrecentPopulationVaccinated
    CREATE TABLE #PrecentPopulationVaccinated
    (
        continent NVARCHAR(255),
        location NVARCHAR(255),
        DATE DATETIME,
        population NUMERIC,
        new_Vaccination NUMERIC,
        RollingPeopleVaccinated NUMERIC
    )
    INSERT INTO #PrecentPopulationVaccinated
    SELECT Death.continent,Death.[location], Death.[date],Death.population, Vaccination.new_vaccinations,
    SUM(Vaccination.new_vaccinations)OVER (Partition by Death.location ORDER BY Death.date, Death.location)/population RollingPeopleVaccinated
    FROM [CovidDeaths-2] Death 
    JOIN CovidVaccinations Vaccination 
    ON Death.[date] = Vaccination.[date]
    AND Death.[location] = Vaccination.[location] 
    --where Death.continent is Not NULL 
    --ORDER by 2,3

    SELECT * ,(RollingPeopleVaccinated/population)*100 from #PrecentPopulationVaccinated
    
    -- Creating view to store data for visulizations
    CREATE VIEW PrecentPopulationVaccinated as
    SELECT Death.continent,Death.[location], Death.[date],Death.population, Vaccination.new_vaccinations,
    SUM(Vaccination.new_vaccinations)OVER (Partition by Death.location ORDER BY Death.date, Death.location)/population RollingPeopleVaccinated
    FROM [CovidDeaths-2] Death 
    JOIN CovidVaccinations Vaccination 
    ON Death.[date] = Vaccination.[date]
    AND Death.[location] = Vaccination.[location] 
    where Death.continent is Not NULL 
    --ORDER by 2,3 

    SELECT * from PrecentPopulationVaccinated
