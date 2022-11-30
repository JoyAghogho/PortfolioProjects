Select *
from ProjectPortfolio..CovidDeaths
where location = 'Canada'
order by 3,4

--Select *
--from ProjectPortfolio..CovidVaccinations
--order by 3,4


--Total Cases vs Total Deaths - Likelhood of dying if you encounter covid in yout country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from ProjectPortfolio..CovidDeaths
WHERE Location like 'Nigeria'
order by 1,2 


---Total Cases vs Population

Select Location, Date, Total_cases, Population, (total_cases/population)*100 as InfectionPercentage
from ProjectPortfolio..CovidDeaths
--where Location like 'Nigeria'
order by 4 desc


--Countries with Highest Infection Rate vs Population

Select Location, Population, MAX(Total_cases) as HighestInfectionCount, (MAX(Total_cases)/cast(population as bigint))*100 as InfectedPopulationPercent
from ProjectPortfolio..CovidDeaths
--where Location like 'Nigeria'
group by Location, Population
order by HighestInfectionCount desc

---Countries with Highest Deathcount per Population

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
--where Location like 'Canada'
where continent <> ''and continent is not null
group by Location
order by TotalDeathCount desc

-----Continents with Highest Deathcount per Population - INCORRECT AS IT DOES NOT PROPERLY CAPTURE NORTH AMERICA

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
--where Location like 'Nigeria'
where continent <> ''and continent is not null
group by continent
order by TotalDeathCount desc

-----Continents with Highest Deathcount per Population - CORRECT DATA

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where location not like '%income%'and (continent = '' or continent is null)
group by location
order by TotalDeathCount desc

-----DeathPercentage across the World

Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
--WHERE Location like 'Nigeria'
where continent is not null and continent <> '' and location not like '%income%'
--group by date
order by 2 desc

--Total Population vs Incremental Daily Vaccinations per Country  (Joining Vacination and Deaths & Rolling/ Incremental Count)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as IncrementalVaccinations
from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> '' and dea.location not like '%income%'
order by 2, 3

--Total Population vs Incremental Daily Vaccinations per Country vs PeopleVaccinatedPercent 
--Impossible to calculate the percentage based on IncrementalVaccinations without creating a temp table
--Use a common table expression (CTE) which is a temporary named result set created from a SQL statement (No of columns in CTE must be same as column # in select statement)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, IncrementalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as IncrementalVaccinations
from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> '' and dea.location not like '%income%'
--order by 2, 3
)
Select *, (IncrementalVaccinations/Population)*100 as PeopleVaccinatedPercent from PopvsVac


---CREATE YOUR QUERY WHERE THE TOTAL VACCINATION % IS SEEN PER COUNTRY USE MAX FUNCTION--

--Temp table

Drop Table if exists #PercentPopulationVaccinated --this removes the table if you want to adjust the query and rerun it. Eliminates the need for manually deleting tables
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
IncrementalVaccinations numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as IncrementalVaccinations
from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> '' and dea.location not like '%income%'
--order by 2, 3

Select *, (IncrementalVaccinations/Population)*100 as PeopleVaccinatedPercent from #PercentPopulationVaccinated


--CREATING VIEWS FOR VISUALIZATIONS

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as IncrementalVaccinations
from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> '' and dea.location not like '%income%'
--order by 2, 3

Select * from PercentPopulationVaccinated
