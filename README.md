# 🦠 COVID-19 Data Exploration and Analysis using SQL

 📘 Project Overview
This project explores **global COVID-19 data** to uncover insights about infection rates, death percentages, and vaccination progress across different countries and continents.  
The analysis is performed using **SQL Server**, with a focus on data cleaning, transformation, and aggregation to prepare the dataset for **Power BI** or other visualization tools.

---

 🗂️ Dataset Information
Two main datasets were used:  
1. **`covid-19 death`** — includes data on total cases, total deaths, population density, and continent/country details.  
2. **`covid-19 vaccinations`** — includes vaccination metrics such as new and total vaccinations per day.

Both datasets are joined on **location** and **date** to ensure consistency and accurate comparisons.

---

 🧠 Objectives
- Analyze total cases vs total deaths (mortality rate per country).  
- Compare infection rates relative to population density.  
- Identify countries and continents with the highest infection and death rates.  
- Explore global COVID trends across time.  
- Examine vaccination rollout and calculate the **percentage of population vaccinated**.  

---

 🧩 Key SQL Techniques Used
- Data type conversion using `ALTER TABLE`.  
- Data cleaning with filters to exclude null continents.  
- Use of **aggregate functions** (`SUM`, `MAX`, `CAST`) for country-level summaries.  
- Implementation of **CTEs** (Common Table Expressions) to simplify analysis logic.  
- Creation of **temporary tables** and **views** for reusable insights.  
- Use of **window functions** (`OVER(PARTITION BY...)`) to calculate rolling vaccination totals.

---

 📊 Example Insights
- The **death percentage** per country shows the likelihood of dying after contracting COVID-19.  
- The **infection percentage** shows how much of the population was affected.  
- Rolling vaccination data tracks how quickly each country was vaccinating its people.  

---

 🏗️ Database Structure
Schema: `PortfolioProjects`  
Tables:  
- `covid-19 death`  
- `covid-19 vaccinations`  
Views Created:  
- `PercentPopulationVaccinated11`

---

 ⚙️ Tools & Technologies
- **SQL Server Management Studio (SSMS)**  
- **Power Query / Power BI (optional visualization)**  
- **GitHub** for version control  

---

 📈 Future Improvements
- Build interactive Power BI dashboards using the SQL views.  
- Automate data refresh through Power BI Service.  
- Incorporate additional datasets (e.g., GDP, healthcare capacity) for deeper insights.  

---

 👨‍💻 Author
**Gerges Lucas** — Freelance Data Analyst  
Certified in Google Data Analytics | Skilled in SQL, Power BI, Tableau, Excel
