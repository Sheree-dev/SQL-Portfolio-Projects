/*

SQL Exploratory Data Analysis

*/


--Select data that will be used
Select * From PortfolioProject..CovidDeaths
order by 3,4

--------------------------------------------------------------------------------------------------------------------------

--Death Percentage of a country

Select location, date, total_cases, total_deaths, 
(total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2



--Show what percentage of population has covid
--Total case per population

Select location, date, total_cases, total_deaths, 
(total_cases/population) * 100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2



--Countries with highest infection rate
--Highest infection count per country/population

Select location, population, 
MAX(total_cases) as HighestInfectionCount, 
MAX(total_cases/population) * 100 as PopulationInfectionPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
order by 1,2 desc


--------------------------------------------------------------------------------------------------------------------------


--Countries with highest death count per population
--Select location, 
--MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
--Where continent is not null
--Group By location
--Order By TotalDeathCount desc

--Countries with highest death count per population
--Breakdown by Continent
Select continent, 
MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc


Select location, 
MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group By location
Order By TotalDeathCount desc



--Continent with highest death count per population
--Calculations for global numbers
Select location, date, total_cases,
total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


Select date, 
SUM(new_cases),
SUM(cast(new_deaths as int))
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order by 1,2


--Global Death Percentage
Select date, 
SUM(new_cases) as TotalCases,
SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order by 1,2

--Remove date and group by statement to get one total
Select 
SUM(new_cases) as TotalCases,
SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--------------------------------------------------------------------------------------------------------------------------

Select *
From PortfolioProject..CovidVaccinations



--Join Tables
--Join CovidDeaths and CovidVaccinations tables

Select *
From PortfolioProject..CovidVaccinations as DEA
Join PortfolioProject..CovidDeaths as VAC
On DEA.location = VAC.location
And DEA.date = VAC.date



--Total Population vs Vaccinations
Select DEA.continent, DEA.location,
DEA.date, VAC.population, VAC.new_vaccinations
From PortfolioProject..CovidVaccinations as DEA
Join PortfolioProject..CovidDeaths as VAC
On DEA.location = VAC.location
And DEA.date = VAC.date
Order By 1,2,3

--Rolling Count
--Using Partion By(Breaking up)
--And Windows Function
--So that count restarts with each location

--Calculate Sum of new vaccinations by location
Select DEA.continent, DEA.location,
DEA.date, VAC.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int))
OVER (PARTITION BY DEA.location
ORDER BY DEA.location, DEA.date) as RollingCountForVaccinated
From PortfolioProject..CovidVaccinations as DEA
Join PortfolioProject..CovidDeaths as VAC
On DEA.location = VAC.location
And DEA.date = VAC.date
--Where dea.continent is not null
Order By 1,2,3

--------------------------------------------------------------------------------------------------------------------------


--Common Table Expressions(CTE's)
--CTE
With PopVsVac(
Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
As
(Select DEA.continent, DEA.location, DEA.date,
 VAC.population, VAC.new_vaccinations,
--SUM(convert( int, VAC.new_vaccinations))
SUM(cast(VAC.new_vaccinations as int))
OVER (PARTITION BY DEA.location
ORDER BY DEA.location, DEA.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as DEA
Join PortfolioProject..CovidDeaths as VAC
On DEA.location = VAC.location
And DEA.date = VAC.date
--Where dea.continent is not null
--Order By 1,2,3
)
Select * From PopVsVac


--------------------------------------------------------------------------------------------------------------------------

--Temp Tables
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select DEA.continent, DEA.location, DEA.date,
 VAC.population, VAC.new_vaccinations,
--SUM(convert( int, VAC.new_vaccinations))
SUM(cast(VAC.new_vaccinations as int))
OVER (PARTITION BY DEA.location
ORDER BY DEA.location, DEA.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as DEA
Join PortfolioProject..CovidDeaths as VAC
On DEA.location = VAC.location
And DEA.date = VAC.date
--Where dea.continent is not null
--Order By 1,2,3

Select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

--------------------------------------------------------------------------------------------------------------------------

--Views
--Create views to store data for later visualization


Create View PercentPopulationVaccinated as
Select DEA.continent, DEA.location, DEA.date,
 VAC.population, VAC.new_vaccinations,
--SUM(convert( int, VAC.new_vaccinations))
SUM(cast(VAC.new_vaccinations as int))
OVER (PARTITION BY DEA.location
ORDER BY DEA.location, DEA.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as DEA
Join PortfolioProject..CovidDeaths as VAC
On DEA.location = VAC.location
And DEA.date = VAC.date
Where dea.continent is not null

Select * from PercentPopulationVaccinated
