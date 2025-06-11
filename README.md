# Streaming Service Database Queries
*This project was completed as part of the [CareerFoundry Data Analytics Programme](https://careerfoundry.com/en/courses/become-a-data-analyst/).*

## Overview
A legacy movie rental company is planning to re-enter the market with a new online streaming service. This project supports the launch strategy by using SQL to query a relational database containing inventory, customer, and payment data. The analysis addresses a series of ad hoc business questions posed by management, helping to identify revenue-driving films, high-value markets, and regional sales trends to inform content strategy and customer targeting.
<br><br>

## Tools
- **Word** - Documentation
- **Excel** - Output
- **PostgreSQL** - Relational Database
- **Excel** - Output
- **Tableau** - Visualisation
- **PowerPoint** - Presentation
<br><br>

## Process
- **Understanding** - ERD Creation | Data Dictionary Documentation
- **Data Preparation** - Profiling | Integrity Checks | Quality Checks | Cleaning | Integration
- **Analysis** - Business Rule Validation | Ad Hoc Querying
- **Communication** - Visualisation | Presentation
<br><br>

## Data
This analysis uses a modified version of the DVD Rental dataset originally provided as a sample database for learning and testing SQL with PostgreSQL. The dataset was adapted and provided by CareerFoundry as part of their Data Analytics Programme.

- [**Dataset**](http://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip) – Film, inventory, customer, payment, and rental records
<br><br>

## Links
- [**Entity Relationship Diagram**](deliverables/erd_dbvisualiser.png)
- [**Data Dictionary**](deliverables/data_dictionary.pdf)
- [**Interactive Tableau Dashboard**](https://public.tableau.com/views/StreamingService_17486375379040/Dashboard1?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- [**Presentation**](deliverables/presentation.pdf)
<br><br>

## Key Insights
### 1. Revenue Contribution by Title
There is a wide disparity in total revenue earned. The top five highest-grossing films each brought in over ¤200, while the lowest performers generated less than ¤8.

<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/bar_top_films.png"" ><br>
    <em>The top five titles earned between ¤204.72 and ¤231.73, led by “Telegraph Voyage”, “Wife Turn”, and “Zorro Ark” as the strongest revenue drivers in the catalogue..</em>
</td>
</tr>
</table>
<br>

<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/bar_bottom_films.png" ><br>
    <em>Seven films shared the bottom five revenue positions, each earning between ¤5.94 and ¤7.93 over the period. “Texas Watch” and “Oklahoma Jumanji” recorded the lowest earnings at ¤5.94.</em>
</td>
</tr>
</table>
<br>

### 2. Actual Rental Duration
Regardles of selected rental term, actual rental durations ranged from same-day returns to a maximum of 10 days, with an average duration of 5 days.
| Rental Duration (Days) | Number of Transactions | Minimum Actual Duration | Maximum Actual Duration | Average Actual Duration |
|:----------------------:|:----------------------:|:-----------------------:|:-----------------------:|:-----------------------:|
| 3 | 3,366 | 0 | 10 | 5 |
| 4 | 3,213 | 0 | 10 | 5 |
| 5 | 3,132 | 0 | 10 | 5 |
| 6 | 3,352 | 0 | 10 | 5 |
| 7 | 2,798 | 0 | 10 | 5 |
| All | 15,861 | 0 | 10 | 5 |
<br>

### 3. Revenue and Customer Distribution by Country
Customer activity is concentrated in a small number of countries, with India, China, and the United States leading in both the number of customers and total revenue. These three markets alone account for 149 of the 599 global customers and a quarter of overall revenue. 
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/map_revenue_customers.png" ><br>
    <em>India (¤6,628; 60), China (¤5,799; 53), and the United States (¤4,110; 36) accounted for the highest revenue and number of customers globally.</em>
</td>
</tr>
</table>
<br>

| # | Country | Customer Count | Total Revenue |
|:-:|:-------:|:--------------:|:-------------:|
| 1 | India | 60 | 6,628.28 |
| 2 | China | 53 | 5,798.74 |
| 3 | United States | 36 | 4,110.32 |
| 4 | Japan | 31 | 3,470.75 |
| 5 | Mexico | 30 | 3,307.04 |
| 6 | Brazil | 28 | 3,200.52 |
| 7 | Russian Federation | 28 | 3,045.87 |
| 8 | Philippines | 20 | 2,381.32 |
| 9 | Turkey | 15 | 1,662.12 |
| 10 | Indonesia | 14 | 1,510.33 |
<br>

### 4. Customer Lifetime Value by Country
Réunion, Vatican City, and Nauru had the highest average CLVs, each exceeding ¤140.
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/map_avg_clv_customers.png" ><br>
    <em>Countries with larger customer bases showed less variation in average CLV, while those with only one or two customers recorded the highest CLVs.</em>
</td>
</tr>
</table>
<br>

| # | Country | Customer Count | Total Revenue | Avg Lifetime Value |
|:-:|:-------:|:--------------:|:-------------:|:------------------:|
| 1 | Réunion | 1 | 216.54 | 216.54 |
| 2 | Vatican City | 1 | 152.66 | 152.66 |
| 3 | Nauru | 1 | 148.69 | 148.69 |
| 4 | Sweden | 1 | 144.66 | 144.66 |
| 5 | Hong Kong | 1 | 142.70 | 142.70 |
| 6 | Thailand | 3 | 419.04 | 139.68 |
| 7 | Belarus | 2 | 277.34 | 138.67 |
| 8 | Greenland | 1 | 137.66 | 137.66 |
| 9 | Turkmenistan | 1 | 136.73 | 136.73 |
| 10 | Chad | 1 | 135.68 | 135.68 |
<br>

### 5. Regional Sales Performance and Customer Numbers
Sales figures vary considerably across geographic regions, with the Asia-Pacific market emerging as the clear leader. This region accounted for the highest number of customers (235) and the greatest total revenue (¤26,468), more than double that of any other region.
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/bar_regional_performance.png" ><br>
    <em>...</em>
</td>
</tr>
</table>
<br>

## Takeaways
### Successes
The project successfully used SQL to query a relational database and extract relevant information in response to specific business questions.

### Challenges
The hypothetical nature of the dataset made it difficult to interpret patterns and anomalies. Without real-world context or business input, it was challenging to judge whether observations reflected meaningful or artificial behaviour which highlights the importance of stakeholder interaction when making analytical assumptions.

### Way Forward
For future projects, using more realistic datasets that better simulate real-world conditions would strengthen the reliability of insights and reduce ambiguity during analysis.
