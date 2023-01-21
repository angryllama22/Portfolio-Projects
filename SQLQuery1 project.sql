--Using Joins, CTE's, Temp Tables, Windows functions, Aggregate functions, converting data types, creating views. 


--From Covid deaths
Select *
From PortfolioProject..['Covid Deaths$']
Where continent is not null 
order by 3,4

--Select*
--From PortfolioProject..['Covid vaccinations$']
--order by 3,4

--Select Data that we are going to be using. 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths$']
order by 1, 2


-- Looking at total cases vs total deaths. 
--Shows the likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
Where location like '%states%'
order by 1, 2

-- Looking at total cases vs population 
--Shows what percentage of population got covid. 
Select Location, date, Population, total_cases,(total_cases/Population) *100 as PopulationInfected
From PortfolioProject..['Covid Deaths$']
Where location like '%states%'
order by 1, 2


-- Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases)as HighestInfectionCount, MAX(total_cases/Population) *100 as PercentPopulationInfected
From PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc

--Showing countries with the highest death count per population
Select Location, MAX (cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Break things down by continent

Select continent, MAX (cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1, 2

Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by date
order by 1, 2

--- from covid vaccinations list. 
Select *
From PortfolioProject..['Covid Deaths$']

order by 3,4




-- Looking at Total Population vs. vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated,  (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid vaccinations$'] vac
	On dea.location= vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated --,  (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid vaccinations$'] vac
	On dea.location= vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
-- make sure you specify data type
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated --,  (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid vaccinations$'] vac
	On dea.location= vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated



-- Create view to store data for later viz

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --,  (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid vaccinations$'] vac
	On dea.location= vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select* 
From PercentPopulationVaccinated
