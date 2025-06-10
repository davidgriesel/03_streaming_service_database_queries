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
The top five highest-grossing films each brought in over ¤200, while the lowest performers generated under ¤8.
<table>
<tr>
<td align="center" valign="top" width="50%">
    <img src="visualisations/top_films.png"" ><br>
    <em>The top five titles earned between ¤204.72 and ¤231.73..</em>
</td>
<td align="center" valign="top" width="50%">
    <img src="visualisations/bottom_films.png" ><br>
    <em>Seven films shared the bottom five revenue positions, each earning between ¤5.94 and ¤7.93 over the period.</em>
</td>
</tr>
</table>
<br>

### 2. Actual Rental Duration
Regardles of selected rental term, actual rental durations ranged from same-day returns to a maximum of 10 days, with an average duration of 5 days.
<table style="width:100%; border-collapse: collapse;">
  <thead>
    <tr>
      <th style="text-align: right;">Rental Duration (Days)</th>
      <th style="text-align: right;">Number of Transactions</th>
      <th style="text-align: right;">Minimum Actual Duration</th>
      <th style="text-align: right;">Maximum Actual Duration</th>
      <th style="text-align: right;">Average Actual Duration</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>3</td>
      <td>3 366</td>
      <td>0</td>
      <td>10</td>
      <td>5</td>
    </tr>
    <tr>
      <td>4</td>
      <td>3 213</td>
      <td>0</td>
      <td>10</td>
      <td>5</td>
    </tr>
    <tr>
      <td>5</td>
      <td>3 132</td>
      <td>0</td>
      <td>10</td>
      <td>5</td>
    </tr>
    <tr>
      <td>6</td>
      <td>3 352</td>
      <td>0</td>
      <td>10</td>
      <td>5</td>
    </tr>
    <tr>
      <td>7</td>
      <td>2 798</td>
      <td>0</td>
      <td>10</td>
      <td>5</td>
    </tr>
    <tr>
      <td>All</td>
      <td>15 861</td>
      <td>0</td>
      <td>10</td>
      <td>5</td>
    </tr>
  </tbody>
</table>
<br>

### 3. Revenue and Customer Distribution by Country
Customer activity is concentrated in a small number of countries, with India, China, and the United States leading in both the number of customers and total revenue. These three markets alone account for 149 of the 599 global customers and a quarter of overall revenue. 
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/revenue_customers.png" ><br>
    <em>...</em>
</td>
</tr>
</table>
<br>

<table style="width:100%; border-collapse: collapse;">
  <thead>
    <tr>
      <th style="text-align: center; padding: 8px; border: 1px solid #ddd; min-width: 120px;">#</th>
      <th style="text-align: center; padding: 8px; border: 1px solid #ddd; min-width: 200px;">Country</th>
      <th style="text-align: center; padding: 8px; border: 1px solid #ddd; min-width: 200px;">Customer Count</th>
      <th style="text-align: center; padding: 8px; border: 1px solid #ddd; min-width: 200px;">Total Revenue</th>
    </tr>
  </thead>
  <tbody>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">India</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">60</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">6,628.28</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">2</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">China</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">53</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">5,798.74</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">3</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">United States</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">36</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">4,110.32</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">4</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Japan</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">31</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">3,470.75</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">5</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Mexico</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">30</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">3,307.04</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">6</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Brazil</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">28</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">3,200.52</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">7</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Russian Federation</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">28</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">3,045.87</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">8</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Philippines</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">20</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">2,381.32</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">9</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Turkey</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">15</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1,662.12</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">10</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Indonesia</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">14</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1,510.33</td></tr>
  </tbody>
</table>
<br>

### 4. Customer Lifetime Value by Country
The highest average customer lifetime values were recorded in countries with one or two customers that contributed disproportionately high revenue over time.
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/clv_customers.png" ><br>
    <em>...</em>
</td>
</tr>
</table>
<br>

<table style="width:100%; border-collapse: collapse;">
  <thead>
    <tr>
      <th style="text-align: center; padding: 8px; border: 1px solid #ddd; min-width: 120px;">#</th>
      <th style="text-align: center; padding: 8px; border: 1px solid #ddd; min-width: 200px;">Country</th>
      <th style="text-align: center; padding: 8px; border: 1px solid #ddd; min-width: 200px;">Customer Count</th>
      <th style="text-align: center; padding: 8px; border: 1px solid #ddd; min-width: 200px;">Total Revenue</th>
      <th style="text-align: center; padding: 8px; border: 1px solid #ddd; min-width: 200px;">Avg Lifetime Value</th>
    </tr>
  </thead>
  <tbody>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Réunion</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">216.54</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">216.54</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">2</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Holy See (Vatican City State)</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">152.66</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">152.66</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">3</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Nauru</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">148.69</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">148.69</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">4</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Sweden</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">144.66</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">144.66</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">5</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Hong Kong</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">142.70</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">142.70</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">6</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Thailand</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">3</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">419.04</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">139.68</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">7</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Belarus</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">2</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">277.34</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">138.67</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">8</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Greenland</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">137.66</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">137.66</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">9</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Turkmenistan</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">136.73</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">136.73</td></tr>
    <tr><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">10</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">Chad</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">1</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">135.68</td><td style="text-align: center; padding: 8px; border: 1px solid #ddd;">135.68</td></tr>
  </tbody>
</table>
<br>

### 5. Regional Sales Performance and Customer Numbers
Sales figures vary considerably across geographic regions, with the Asia-Pacific market emerging as the clear leader. This region accounted for the highest number of customers (235) and the greatest total revenue (¤26,468), more than double that of any other region.
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/regional.png" ><br>
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
