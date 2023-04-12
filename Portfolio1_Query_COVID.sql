select * 
from CovidDeaths
where continent is not null
Order by 3,4

--select * 
--from CovidVaccinations
--Order by 3,4


--Select Data that we are going to be using.
Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
Order By 1, 2


--Looking at Total Cases vs Total Deaths
--- Shows the probability of dying if you contract Covid per Country

Select location, date, total_cases, total_deaths, (total_deaths/(total_cases))*100 as DeathsPercentage
from CovidDeaths
where location like '%chile%'
Order By 1, 2


--Looking at the TotalCases vs Population
---Shows percentage of the population that got Covid

Select location, date, total_cases, population, (total_cases/(population))*100 as Infection_Rate
from CovidDeaths
where location like '%chile%'
Order By 1, 2

--Looking at the Total Cases vs Population per Country
---Shows which countries had the highest infection rate compared to their population

Select location, population, MAX(total_cases) as HighestInfectionCount,(MAX(total_cases)/(population))*100 as Infection_Rate
from CovidDeaths
where continent is not null
group by location, population
Order By 4 DESC

--Looking at the Total Deaths vs Population per Country
---Shows which countries had the highest death count compared to their population

Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths
where continent is not null
group by location, population
Order By Total_Death_Count DESC

-- LET'S BREAK IT DOWN BY CONTINENT--

--Shows continents with the highest death count per continent

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths
where continent is not null
group by continent
Order By Total_Death_Count DESC

-- GLOBAL NUMBERS

--by date
Select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as GlobalPercentage
from CovidDeaths
where continent is not null
--group by date
Order By 1,2

--total
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as GlobalPercentage
from CovidDeaths
where continent is not null
Order By 1


--total population vs vaccination

select death.continent, death.location, death.population, death.date, vaccs.new_vaccinations
, SUM(cast (vaccs.new_vaccinations as int)) OVER (PARTITION BY death.location order by death.location, death.date) as TotalVaccinations_ToDate
from CovidDeaths death
	join CovidVaccinations vaccs
	on death.location = vaccs.location
	and death.date = vaccs.date
where death.continent is not null 
order by 2,3

-- Using CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalVaccinations_ToDate)
as
(
select death.continent, death.location, death.date, death.population, vaccs.new_vaccinations
, SUM(convert (int, vaccs.new_vaccinations)) OVER (PARTITION BY death.location order by death.location, death.date) as TotalVaccinations_ToDate
from CovidDeaths death
	join CovidVaccinations vaccs
	on death.location = vaccs.location
	and death.date = vaccs.date
where death.continent is not null 
)

select *, (TotalVaccinations_ToDate/Population) * 100
from PopvsVac

--Using a TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinations_ToDate numeric
)


INSERT INTO #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vaccs.new_vaccinations
, SUM(convert (int, vaccs.new_vaccinations)) OVER (PARTITION BY death.location order by death.location, death.date) as TotalVaccinations_ToDate
from CovidDeaths death
	join CovidVaccinations vaccs
	on death.location = vaccs.location
	and death.date = vaccs.date
where death.continent is not null 


select *, (TotalVaccinations_ToDate/Population) * 100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as 
select death.continent, death.location, death.date, death.population, vaccs.new_vaccinations
, SUM(convert (int, vaccs.new_vaccinations)) OVER (PARTITION BY death.location order by death.location, death.date) as TotalVaccinations_ToDate
from CovidDeaths death
	join CovidVaccinations vaccs
	on death.location = vaccs.location
	and death.date = vaccs.date
where death.continent is not null 

