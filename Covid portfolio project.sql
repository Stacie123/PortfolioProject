select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4;


--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4;

--selecting the data that i will be using

select Location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2;


--looking at the total_cases vs total_deaths

select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2;

--looking at the total_cases vs population
---it shows the percentage population that had covid in Nigeria
select Location, date, population,total_cases, (total_cases/population)*100
as Percentage_infected_population
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2;

---countries with the highest covid rate compared to population
select Location,  population,MAX(total_cases) as Highest_infecteion_count, 
MAX((total_cases/population))*100 as Percentage_infected_population
from PortfolioProject..CovidDeaths
group by Location, population
order by Percentage_infected_population desc;

-- determining the coutries with the highest death count per population
--- the cast was used to change the datatype of total deaths in other to obtain
--- or when changing the datatype of particular column
--- a clear and more organized answer 
select Location,  MAX(Cast(Total_deaths as int)) as Total_deaths_count 
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by Total_deaths_count desc;

--- determining continent with the highest death count per population
select continent,  MAX(Cast(Total_deaths as int)) as Total_deaths_count 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_deaths_count desc;

---calculate the global number of covid
select date, SUM(new_cases) as total_cases, SUM(cast(total_deaths as int)) as total_deaths,
SUM(cast(total_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

---- joining the two tables together; coviddeath and covidvaccination
--- using allis to diff between them for easy readability
----- dea is for coviddeath and vac is for covid vaccination
select*
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date;

---looking at the total population vs vaccination
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

---- partition by means separating data into diff group
---- over, in sql means how to looks at rows around the current row
---- convert means to use the datatype of a particular column

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--- using CTE ( common table expression: it is a way to create a temporary table
--- within an SQL Query ie giving a name to a part of your sql query result so that 
--- it can be easily referred to later.

with PopvsVac (continent, location, date, population,new_vaccinations,  Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
)
select*, (Rollingpeoplevaccinated/population) as PopulationVacperecntage
from PopvsVac

---TEMP TABLE

DROP Table if exists #percentagepopulationvaccinated

create table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentpopulationvaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not  null
order by 1,2

select*, (Rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--- creating view to store data for visualization

create view Percentpopulationvaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not  null


select *
from Percentpopulationvaccinated





























