use CovidProject
-------------------------
Select *
From CovidProject.dbo.CovidDataCount
order by location,date

Select *
From CovidProject.dbo.CovidVaccinatedCount
order by location,date
-------------------------

Select location, date, population, total_cases, new_cases, total_cases, new_deaths 
from CovidProject.dbo.CovidDataCount
Order by 1,2

---------Change Data_type From Nvarchar to Float----------------
Alter Table CovidProject.dbo.CovidDataCount
Alter Column Total_cases Float

Alter Table CovidProject.dbo.CovidDataCount
Alter Column Total_deaths Float

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Looking at Total Cases vs Total Deaths * Show Likelihood of dying if you contract covid In your country

Select location, date ,total_cases  , total_deaths , (Cast (CovidCount.total_deaths as float) / Cast(CovidCount.total_cases as Float))*100 As DeathPercentage
From CovidProject.dbo.CovidDataCount as CovidCount
where Location = 'Philippines' and  Total_cases is not null
order by location,date



-- Looking at Total Cases vs Population * Show What Percentage of Population Got Covid

Select Location,Date,  population , total_cases  ,(Cast(total_cases as Float) / population)*100 as AffectedByCovid
From CovidProject.dbo.CovidDataCount 
where Location = 'Philippines' and  Total_cases is not null
order by 1,2



-- Looking at Countries with highest infection rate compared to Population

Select Location,Population, MAX(total_Cases) as HighestInfectionRate, MAX(Total_cases / population )*100 as InfectionRatePerCountry
From CovidProject.dbo.CovidDataCount
Group by location,population
Order by InfectionRatePerCountry desc



-- Showing countries with highest Death count per population

Select Location,Population, MAX(total_deaths) as HighestDeathRate, MAX(total_deaths/ population )*100 as DeathRatePerCountry
From CovidProject.dbo.CovidDataCount
Group by location,population
Order by DeathRatePerCountry desc



-- Lets break things down by continent

Select Location,Population, MAX(total_deaths) as HighestDeathRate, MAX(total_deaths/ population )*100 as DeathRatePerContinent
From CovidProject.dbo.CovidDataCount
where continent is null
Group by location,population
Order by DeathRatePerContinent desc



-- Looking at total Population vs Vaccionations Per Country

Select CovidCount.location,CovidCount.Date,CovidCount.population,VacCount.Total_vaccinations,
Case when total_vaccinations = '0' then null else (  VacCount.Total_vaccinations / CovidCount.population )*100 End As PercentageOfVaccinated
From CovidProject.dbo.CovidDataCount As CovidCount
Inner Join CovidProject.dbo.CovidVaccinatedCount As VacCount
ON CovidCount.location = VacCount.location and CovidCount.date = VacCount.date
where  total_vaccinations is not null 
Order BY location



-- Find the top 10 countries with the highest number of total cases as of January 1, 2023.

Select location,MAX(total_cases) As HighestCases
From CovidProject.dbo.CovidDataCount
Where Date <= '2023-01-01'
Group by location
Order By HighestCases desc
Offset 9 Rows fetch next 10 rows only

/*Checking*/
Select Location,Date,population,total_cases
From CovidProject..CovidDataCount
where location = 'china'
order by total_cases desc



-- Calculate the percentage increase in total cases from January 1, 2020 to january 1, 2023 for each country.

Select location,Date,new_cases,total_cases, (new_cases / total_cases)*100 As PercentageIncreaseInTotalCases
From CovidProject.dbo.CovidDataCount 
where Date >= '2020-01-01 ' and Date <= '2023-01-01' and total_cases is not null 
order By location,date



-- Create a report that shows the total number of cases, total number of deaths, and the death rate (number of deaths per 100 cases) for each continent as of May 1, 2023.

Select location,MAX(total_cases) As TotalNumberOfCases,MAX(total_deaths) As TotalNumberOfDeaths , (MAX(total_deaths)  /MAX(total_cases))*100 As DeathRate
From CovidProject.dbo.CovidDataCount
Where  date >= 2021-01-01    and continent is null 
Group by location
Order By DeathRate Desc



-- Calculate the average number of new cases per day for each country in the first quarter of 2021.

 Select Location,Date,avg(new_cases/30)  As AvgNumberOfNewCasesPerDay
 From CovidProject..CovidDataCount
where Date >= '2021-01-01 ' and Date <= '2021-04-30' and new_cases is not null 
 Group by location,date
 Order by 1,2

 /*Checking*/
 Select Location,date,new_cases
 From CovidProject..CovidDataCount
 where Date >= '2021-01-01 ' and Date <= '2021-04-30' and new_cases is not null 
 Order by 1,2



-- Identify the country with the highest number of new deaths reported in a single day and the date on which it occurred.

SELECT Location, date, new_deaths
FROM CovidProject.dbo.CovidDataCount
WHERE new_deaths = (SELECT MAX(new_deaths) FROM CovidProject.dbo.CovidDataCount)



-- Calculate the mortality rate (number of deaths per 100,000 population) for each country as of January 1, 2023.

Select Location,population,MAX(((total_deaths)/population)*100000) Over (Partition by Population) as MortalityRateBy_100000
From CovidProject.dbo.CovidDataCount
where date = '2023-01-01'
Order by location



-- Create a report that shows the total number of cases, total number of deaths, and the recovery rate (number of recovered cases per 100 cases) for each continent as of January 1, 2023.

Select Location,total_cases,total_deaths
From CovidProject.dbo.CovidDataCount
where date = '2023-01-01'
Order by location
/* NO DATA FOR RECOVERY RATE*/



-- Find the top 5 Continent with the highest number of cases per Country (cases per 100,000 population) as of january 1, 2023.

Select location,total_cases
From CovidProject.dbo.CovidDataCount
where continent is  null and date = '2023-01-01'
order by total_cases desc
Offset 2 Rows fetch next 5 rows only



-- Find the top 5 Continent with the 5 highest number of cases per Country (cases per 100,000 population) as of january 1, 2023.

	WITH CTE_CasesPerCountry AS (
    SELECT
        continent,
        location,
        population,
        total_cases,
        (total_cases/population)*100000 AS CasesPerCountry
    FROM
        CovidProject.dbo.CovidDataCount
    WHERE
        date = '2023-01-01'
        AND continent IS NOT NULL
), ranked_cases AS (
    SELECT
        continent,
        location,
        CasesPerCountry,
        ROW_NUMBER() OVER (PARTITION BY continent ORDER BY CasesPerCountry DESC) AS rank
    FROM
        CTE_CasesPerCountry
)
SELECT
    continent,
    location,
   CasesPerCountry
FROM
    ranked_cases
WHERE
    rank <= 5
ORDER BY
    continent,
    CasesPerCountry DESC;



-- Calculate the percentage of the population that has been fully vaccinated in each country as of January 1, 2023.

Select location,population,total_vaccinations, (total_vaccinations/ population)*100 as PercentageOfVaccinated
From CovidProject.dbo.CovidVaccinatedCount
where Date = '2023-01-01' and total_vaccinations is not null 
Order By PercentageOfVaccinated desc



-- Identify the country with the highest number of cases in a single day and the date on which it occurred.

SELECT Location, date, new_cases
FROM CovidProject.dbo.CovidDataCount
WHERE new_cases = (SELECT MAX(new_cases) FROM CovidProject.dbo.CovidDataCount)



-- Calculate the growth rate (percentage increase in cases) of each country in the month of January 2022, compared to January 2023. 

With CTE_CasesOnJan2022 As (
Select location,MAX(total_cases) As CasesOnJan2022
From CovidProject.dbo.CovidDataCount
where date >= '2022-01-01' and date <= '2022-01-31'
Group by location

) , CTE_CasesOnJan2023  As (
Select location,MAX(total_cases) As CasesOnJan2023
From CovidProject.dbo.CovidDataCount
where date >= '2023-01-01' and date <= '2023-01-31'
Group by location

)

Select cases2022.location,Cases2022.CasesOnJan2022,Cases2023.CasesOnJan2023,(Cases2022.CasesOnJan2022/Cases2023.CasesOnJan2023)*100 as PercentageIncreaseIncases
From CTE_CasesOnJan2022 as Cases2022
Join CTE_CasesOnJan2023 as Cases2023
On Cases2022.location = Cases2023.location
order by PercentageIncreaseIncases desc



-- Identify the top 5 countries with the highest number of active cases (total cases minus total deaths) as of january  1, 2022.

select Location,(total_cases) - (total_deaths) As ActiveCases
From CovidProject.dbo.CovidDataCount
where date = '2022-01-01'
order by  ActiveCases desc
Offset 8 Rows fetch next 5 rows only



-- Create a report that shows the total number of cases and deaths, as well as the case fatality rate, for each region of the world (e.g. East Asia, Europe, South America, etc.) as of January 1, 2023.

Select location,MAX(total_cases) As TotalNumberOfCases , MAX(total_deaths) As TotalNumberOfDeaths , ( MAX(total_deaths) / MAX (total_cases))*100 As FatalityRate
From CovidProject.dbo.CovidDataCount as CovidCount
where continent is null and date = '2023-01-01'
Group by location
Order by location



-- Calculate the percentage of the population that has received at least one dose of a Covid-19 vaccine in each country, based on data from January 1, 2020 to May 1, 2023.

Select Location,MAX(population) As Population ,MAX(total_vaccinations) As VaccinatedWithOneDose, (MAX(total_vaccinations) / MAX(population)) *100 As Vaccinated
From CovidProject.dbo.CovidVaccinatedCount
where total_vaccinations is not null
Group by location
order by location



-- Calculate the percentage of tests that have come back positive for each country, based on data from January 1, 2020 to May 1, 2023.

Select CovidCount.location ,MAX(total_tests) as Total_Test,MAX(total_cases) as Total_Cases ,(MAX(total_cases) / MAX(total_tests))*100 as PositiveInTheTest
From CovidProject.dbo.CovidDataCount as CovidCount
Join CovidProject.dbo.CovidVaccinatedCount as VacCount
ON CovidCount.location = VacCount.location
Group By CovidCount.location
Order By location