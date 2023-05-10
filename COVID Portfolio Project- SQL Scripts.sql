use PortfolioProject

Select *
From [dbo].['Covid deaths$']
Where continent is not null
order by 3,4

Select *
From [dbo].['Covid vaccination$']
order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From [dbo].['Covid deaths$']
order by 1,2

--Looking at the total cases vs total deaths

Select location, date, total_cases, cast(total_deaths as int) as TotalDeath, (cast(total_deaths as int)/total_cases)*100 as DeathPercentage
From [dbo].['Covid deaths$']
order by 1,2

--Used alternate code since you cannot divide a string...
select 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)))*100 as [DeathPercentage]
From [dbo].['Covid deaths$']
Where location like '%states%'
order by 1,2

--Looking at the total cases vs population
--Shows percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [dbo].['Covid deaths$']
Where location like '%states%'
order by 1,2

 --looking at countries with highest infection rate compared to population
 Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [dbo].['Covid deaths$']
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc




--Showing the countries with the highest death count per population..

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].['Covid deaths$']
Where continent is not null
group by location
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY LOCATION
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].['Covid deaths$']
Where continent is null
group by location
order by TotalDeathCount desc


--Other query for continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].['Covid deaths$']
Where continent is not null
group by continent
order by TotalDeathCount desc

--Showing the continent with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].['Covid deaths$']
Where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From ['Covid deaths$']
Where continent is not null
--Group by date
Order by 1,2

--Now using covid vaccination table
--Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated
From [dbo].['Covid deaths$']  dea Join
[dbo].['Covid vaccination$'] vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
( Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From [dbo].['Covid deaths$']  dea Join
[dbo].['Covid vaccination$'] vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From [dbo].['Covid deaths$']  dea Join
[dbo].['Covid vaccination$'] vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating views to store data for later data visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From [dbo].['Covid deaths$']  dea Join
[dbo].['Covid vaccination$'] vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

 
 Create View AffectedGlobally as 
 Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) 
 as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From ['Covid deaths$']
Where continent is not null
--Group by date
--Order by 1,2

 Select *
 From PercentPopulationVaccinated