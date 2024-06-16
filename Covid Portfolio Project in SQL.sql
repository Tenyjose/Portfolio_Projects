select * from PortfolioProject ..CovidDeaths order by 3,4
--select * from PortfolioProject ..CovidVaccinations order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject ..CovidDeaths order by 1

--Total cases Vs Total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage 
from PortfolioProject ..CovidDeaths where location like 'india' order by 1,2

--Total cases Vs Population

select location,date,Population,total_cases,(total_cases/population)*100 as case_percentage 
from PortfolioProject ..CovidDeaths where location like 'india' order by 1,2

--Countries with highest infection rate compared to population

select location,Population,Max(total_cases) as highest_count,max((total_cases/population))*100 as case_percentage 
from PortfolioProject ..CovidDeaths 
--where location like 'india' 
group by location,population
order by case_percentage desc

--countries with highest death count per population

select location,Max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject ..CovidDeaths 
--where location like 'india' 
where continent is not null
group by location
order by highest_death_count desc

--continents death count per population

select continent,Max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject ..CovidDeaths 
--where location like 'india' 
where continent is not null
group by continent
order by highest_death_count desc

-- Global Numbers

select date,Sum(new_cases) as case_per_day,sum(cast(new_deaths as int)) as deaths_per_day
from PortfolioProject ..CovidDeaths
where continent is not null
group by date
order by 1;

select date,Sum(new_cases) as case_per_day,sum(cast(new_deaths as int)) as deaths_per_day,
(sum(cast(new_deaths as int))/Sum(new_cases))*100 as death_percentage
from PortfolioProject ..CovidDeaths
where continent is not null
group by date
order by 1;

select Sum(new_cases) as case_per_day,sum(cast(new_deaths as int)) as deaths_per_day,
(sum(cast(new_deaths as int))/Sum(new_cases))*100 as death_percentage
from PortfolioProject ..CovidDeaths
where continent is not null
--group by date
--order by 1;


--Joining the two tables 

select dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2;

--Total vaccination in locations

select dea.location,dea.date,
sum(cast(vac.new_vaccinations as int)) as total_vaccinations
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.location,dea.date
order by dea.location

--total vaccinations in locations using partition by

select dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollin_people_vaccinated--
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2;

--Using CTE(Commom Table Expressions)

with DeaVsVac (location,date,population,new_vacccinations,rollin_people_vaccinated) as
(
select dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollin_people_vaccinated--
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *,(rollin_people_vaccinated/population)*100 as precntage_vaccinated
from DeaVsVac


-- Creating a view

Create view PercentPopVac as
select dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollin_people_vaccinated--
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from dbo.PercentPopVac
