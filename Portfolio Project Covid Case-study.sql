

select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4 


select *
from PortfolioProject..CovidVaccinations
order by 3,4 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

/*looking at total cases vs total deaths*/

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
order by 1,2

/* shows likelihood of dying if you contract covid in country*/

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%Australia%'
order by 1,2


/*looking at total cases vs population*/
--show what percentage of population got covid

select location, date, total_cases, population, (total_deaths/population)*100 as PercentPopulationInfaction
from PortfolioProject.dbo.CovidDeaths
where location like '%Australia%'
order by 1,2



/* looking at countries with higest infection rate compared to population */

select location, population, Max(total_cases) as HighestIfaction, Max((total_cases/population))*100 as PercentPopulationInfaction
from PortfolioProject.dbo.CovidDeaths
group by location, population
order by PercentPopulationInfaction desc


--showing countries with highest death count per population

select location,Max(total_deaths) as TotalDeaths
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc


--showing the data by breaking down into continent

select continent,Max(total_deaths) as TotalDeaths
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc


-- Global numbers

select  Sum(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
order by 1,2 desc



--Join 2 tables 

select *
from PortfolioProject.dbo.CovidDeaths

select *
from PortfolioProject..CovidVaccinations




select * 
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date 



/* showing countries with the Highest new_vaccinations*/


select dea.continent, dea.location, dea.date, (cast(vac.new_vaccinations13 as int )) as TotalVaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
group by dea.continent, dea.location, dea.date, vac.new_vaccinations13
order by 2,3




/*looking at Total Population vs Vaccination*/


select dea.continent, dea.location, dea.date, vac.new_vaccinations13, SUM(convert(int,vac.new_vaccinations13 )) over (partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


/*Joint 2 tables*/

select *
from PortfolioProject..CovidVaccinations

select * 
from PortfolioProject..CovidDeaths



select * 
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location is not null
order by 2,3

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations13
, SUM(convert(int, vac.new_vaccinations13)) over (Partition by dea.location order by dea.location, dea.date )
as RollingVaccination
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


/* USE CTE */

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations13, RollingVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations13
, SUM(convert(int, vac.new_vaccinations13)) over (Partition by dea.location order by dea.location, dea.date )
as RollingVaccination
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
--order by 2,3



select *, (RollingVaccination/Population)*100
from PopvsVac



/* USE TEMP Table */

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccination numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations13
, SUM(convert(int, vac.new_vaccinations13)) over (Partition by dea.location order by dea.location, dea.date )
as RollingVaccination
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *,(RollingVaccination/population)*100
from #PercentPopulationVaccinated



/* Create view to store data for later visualizations*/

create view PercentagePopulationVaccinated 
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations13
, SUM(convert(int, vac.new_vaccinations13)) 
	over (Partition by dea.location order by dea.location, dea.date )
as RollingVaccination
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



select *
from PercentagePopulationVaccinated