# Streaming Service Database Queries
*This project was completed as part of the [CareerFoundry Data Analytics Programme](https://careerfoundry.com/en/courses/become-a-data-analyst/).*

## Overview
A legacy movie rental company is planning to re-enter the market with a new online streaming service. This project supports the launch strategy by using SQL to query a relational database containing inventory, customer, and payment data. The analysis addresses a series of ad hoc business questions posed by management, helping to identify revenue-driving films, high-value markets, and regional sales trends to inform content strategy and customer targeting.
<br><br>

## Tools
- **Word** - Documentation
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
### 1. Customer Base, Catalogue, and Revenue Generated
The business served 599 customers across 597 cities in 108 countries.
| Customer Base | Count |
|:--- |:---:|
| Customers | 599 |
| Countries | 108 |
| Cities | 597 |

The catalogue included 958 English-language titles, all released in 2006, spanning 16 categories and five ratings.
| Catalogue | Count |
|:---|:---:|
| Titles in Inventory | 958 |
| Categories | 16 |
| Ratings | 5 |
| Langaugues | 1 (English) |
| Release Year | 1 (2006) |

Total revenue amounted to ¤66,888, consisting of ¤60,785 in payments received and ¤6,103 in accrued charges from rentals that were returned but not paid for yet.
| Revenue | Amount (¤) |
|:---|:---:|
| Paid | 60 784,91 |
| Accrued | 6 103,48 |
| Total Revenue | 66 888,39 |

### 2. Revenue Contribution by Title
The distribution of revenue was highly uneven with the top five highest-grossing titles each earning over ¤200, while the lowest performers brought in less than ¤8 each.
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/bar_top_films.png"" ><br>
    <em>The top five titles earned between ¤204.72 and ¤231.73, led by “Telegraph Voyage”, “Wife Turn”, and “Zorro Ark”.</em>
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

### 2. Rental Return Behaviour
Although each film was assigned a fixed rental term between 3 and 7 days, actual return behaviour showed little variation, ranging from same-day returns to 10 days, with an average of 5. Most returns were evenly distributed between 1 and 9 days regardless of the assigned duration, with notably fewer same-day and 10-day returns, suggesting that assigned terms had limited influence on actual return behaviour.

**Summary Statistics - Actual Rental Duration by Rental Term**
| Rental Duration (Days) | Number of Transactions | Minimum Actual Duration | Maximum Actual Duration | Average Actual Duration |
|:----------------------:|:----------------------:|:-----------------------:|:-----------------------:|:-----------------------:|
| 3 | 3,366 | 0 | 10 | 5 |
| 4 | 3,213 | 0 | 10 | 5 |
| 5 | 3,132 | 0 | 10 | 5 |
| 6 | 3,352 | 0 | 10 | 5 |
| 7 | 2,798 | 0 | 10 | 5 |
| All | 15,861 | 0 | 10 | 5 |

Returns were relatively evenly spread across terms, with actual durations ranging between 0 and 10 days, with an average of 5 days.
<br><br>

**Transaction Distribution – Actual Rental Duration per Rental Term**
<table>
  <thead>
    <tr>
      <th rowspan="2">Rental Term (Days)</th>
      <th colspan="11">Actual Duration (Days)</th>
    </tr>
    <tr>
      <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>3</td><td>18</td><td>356</td><td>370</td><td>371</td><td>358</td><td>400</td><td>366</td><td>357</td><td>385</td><td>360</td><td>25</td></tr>
    <tr><td>4</td><td>22</td><td>309</td><td>361</td><td>369</td><td>339</td><td>337</td><td>401</td><td>358</td><td>363</td><td>335</td><td>19</td></tr>
    <tr><td>5</td><td>26</td><td>336</td><td>375</td><td>337</td><td>327</td><td>331</td><td>344</td><td>361</td><td>346</td><td>335</td><td>14</td></tr>
    <tr><td>6</td><td>22</td><td>342</td><td>371</td><td>354</td><td>356</td><td>383</td><td>372</td><td>430</td><td>355</td><td>345</td><td>22</td></tr>
    <tr><td>7</td><td>17</td><td>301</td><td>318</td><td>283</td><td>301</td><td>310</td><td>300</td><td>315</td><td>313</td><td>316</td><td>24</td></tr>
  </tbody>
</table>

Return behaviour followed a broadly uniform distribution between 1 and 9 days for each rental term, with a consistent drop in frequency at 0 and 10 days.
<br>

### 3. Revenue and Customer Distribution by Country
With 599 customers across 597 cities in 108 countries, activity is concentrated in a few key markets. India, China, and the United States account for nearly a quarter of global customers and total revenue.

<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/map_revenue_customers.png" ><br>
    <em>India, China, and the United States were the top 3 countries in terms of total revenue and number of customers.</em>
</td>
</tr>
</table>
<br>

**Top 10 Countries - Total Revenue and Number of Customers**
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

The top 3 countries together account for 149 of global customers and ¤16,400.82 in total revenue.
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
