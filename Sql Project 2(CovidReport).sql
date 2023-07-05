
Select * from CovidDeaths
Where continent is not null
order by 3,4


--Select * from CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
Where continent is not null
order by 1,2


--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2), total_cases)) *100 as DeathPercentage
from CovidDeaths
where location like '%states%'
Where continent is not null
order by 1,2


--looking at total cases vs population
select location, date, population, total_cases,  (CONVERT(DECIMAL(18,2), total_cases) / CONVERT(DECIMAL(18,2), population)) *100 as PercentPopulationInfected
from CovidDeaths
where location like '%states%'
Where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, date, Max(total_cases) as HighestInfectionCount,  max((CONVERT(DECIMAL(18,2), total_cases) / CONVERT(DECIMAL(18,2), population)))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%states%'
Where continent is not null
Group by location, population, date
order by PercentPopulationInfected Desc


--Showing countries with Highest Death count per population
select location, Sum(cast(new_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
Where continent is null
and location not in ('world', 'European Union', 'international')
Group by location
order by TotalDeathCount Desc


--LET'S BREAK THINGS DOWN BY CONTINENT
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount Desc



--Showing continent with the highest death count per population
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount Desc


--Global Numbers
Select Sum(new_cases) as Total_cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--Join two Tables, looking as total population vs Vaccinations
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, Sum(Convert(Decimal(18),VAC.new_vaccinations)) over (Partition by DEA.Location) as RollingPeopleVaccinated
from covidDeaths DEA
Join CovidVaccinations VAC
    on  DEA.location = VAC.location
	and DEA.date = VAC.date
	where DEA.continent is not null
	order by 2,3


	--use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
  Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, Sum(Convert(Decimal(18),VAC.new_vaccinations)) over (Partition by DEA.Location) as RollingPeopleVaccinated
from covidDeaths DEA
Join CovidVaccinations VAC
    on  DEA.location = VAC.location
	and DEA.date = VAC.date
	where DEA.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinatedPeople
from PopVsVac



--temp table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
PercentVaccinatedPeople numeric
)
Insert into #PercentPopulationVaccinated
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, Sum(Convert(Decimal(18),VAC.new_vaccinations)) over (Partition by DEA.Location) as RollingPeopleVaccinated
from covidDeaths DEA
Join CovidVaccinations VAC
    on  DEA.location = VAC.location
	and DEA.date = VAC.date
	--where DEA.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinatedPeople
from #PercentPopulationVaccinated



--creating view to store date for later visualizations
create view PercentPopulationVaccinated
as 
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, Sum(Convert(Decimal(18),VAC.new_vaccinations)) over (Partition by DEA.Location) as RollingPeopleVaccinated
from covidDeaths DEA
Join CovidVaccinations VAC
    on  DEA.location = VAC.location
	and DEA.date = VAC.date
	where DEA.continent is not null
	--order by 2,3


Select * from PercentPopulationVaccinated