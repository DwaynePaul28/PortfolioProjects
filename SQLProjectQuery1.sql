Select Location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..[Covid_Deaths$]
order by 1,2


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..[Covid_Deaths$]
where location like '%Grenada%'
order by 1,2

--Looking at total cases vs Population
Select Location, date, total_cases,(total_cases/population)* 100 as Infection
from PortfolioProject..[Covid_Deaths$]
where location like '%Grenada%'
order by 1,2


--Countries with highest Infection Rates
Select Location, Population, MAX (total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as 
PercentPopulationInfected
from PortfolioProject..[Covid_Deaths$]
where location like '%Grenada%'
group by Location, Population
order by PercentPopulationInfected desc



--continents with the highest death count 
Select continent, MAX (cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..[Covid_Deaths$]

where continent is not null --and location like '%states%'
group by continent
order by TotalDeathCount desc



--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100   as DeathPercentage-- total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..[Covid_Deaths$]
where continent is not null
--Group by date
order by 1,2

--Using CTE
With PopvsVac (Continent, Location, Date, Population, 
New_Vaccinations, RollingPeopleVaccinationed) as
(
--Looking a total Global Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..CovidVac vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select * , (RollingPeopleVaccinationed/Population)* 100 as Percentage
from PopvsVac



--Temp Table 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
--RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
--as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..CovidVac vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

Select *--, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to Store Data for later
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..CovidVac vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated