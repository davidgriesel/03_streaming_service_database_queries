# Streaming Service Database Queries
*This project was completed as part of the [CareerFoundry Data Analytics Programme](https://careerfoundry.com/en/courses/become-a-data-analyst/).*

## Overview
A legacy movie rental company is planning to re-enter the market with a new online streaming service. This project supports the launch strategy by using SQL to query a relational database containing inventory, customer, and payment data. The analysis addresses a series of ad hoc business questions posed by management, helping to identify revenue-driving films, high-value markets, and regional sales trends to inform content strategy and customer targeting.
<br><br>

## Tools
- **PostgreSQL** - Relational Database
- **DbVisualizer** - Entity Relationship Diagram
- **Tableau** - Visualisation
- **Excel** - Output
- **Word** - Documentation
- **PowerPoint** - Presentation
<br><br>

## Process
- **Understanding** - ERD Creation | Data Dictionary Documentation
- **Data Preparation** - Profiling | Integrity Checks | Quality Checks | Cleaning | Integration
- **Analysis** - Business Rule Validation | Metric Derivation | Ad Hoc Querying
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
1. The top 5 revenue-generating films earned between ¤205 and ¤232, while 7 films shared the bottom five positions, generating between ¤6 and ¤8.
<table>
<tr>
<td align="center" valign="top" width="50%">
    <img src="visualisations/top_films.png"" ><br>
    <em>...</em>
</td>
<td align="center" valign="top" width="50%">
    <img src="visualisations/bottom_films.png" ><br>
    <em>...</em>
</td>
</tr>
</table>
<br>

2. Rental durations across all terms ranged from same-day returns to a maximum of 10, with an average duration of 5 days.

Rental Duration|Number of transactions|Min Actual Duration|Max Actual Duration|Avg Actual Duration
:---|:---|:---|:---|:---
3|3 366|0|10|5
4|3 213|0|10|5
5|3 132|0|10|5
6|3 352|0|10|5
7|2 798|0|10|5
All|15 861|0|10|5
<br>

<table width="100%">
  <tr>
    <th>Rental Duration (Days)</th>
    <th>Number of Transactions</th>
    <th>Minimum Actual Duration</th>
    <th>Maximum Actual Duration</th>
    <th>Average Actual Duration</th>
  </tr>
  <tr>
    <td>3</td><td>3 366</td><td>0</td><td>10</td><td>5</td>
  </tr>



  <h3>2. Rental durations across all terms ranged from same-day returns to a maximum of 10, with an average duration of 5 days.</h3>

<table style="width:100%; border-collapse: collapse;">
  <thead>
    <tr style="background-color: #f2f2f2;">
      <th style="text-align: left; padding: 8px; border: 1px solid #ddd;">Rental Duration (Days)</th>
      <th style="text-align: left; padding: 8px; border: 1px solid #ddd;">Number of Transactions</th>
      <th style="text-align: left; padding: 8px; border: 1px solid #ddd;">Minimum Actual Duration</th>
      <th style="text-align: left; padding: 8px; border: 1px solid #ddd;">Maximum Actual Duration</th>
      <th style="text-align: left; padding: 8px; border: 1px solid #ddd;">Average Actual Duration</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 8px; border: 1px solid #ddd;">3</td>
      <td style="padding: 8px; border: 1px solid #ddd;">3 366</td>
      <td style="padding: 8px; border: 1px solid #ddd;">0</td>
      <td style="padding: 8px; border: 1px solid #ddd;">10</td>
      <td style="padding: 8px; border: 1px solid #ddd;">5</td>
    </tr>
    <tr>
      <td style="padding: 8px; border: 1px solid #ddd;">4</td>
      <td style="padding: 8px; border: 1px solid #ddd;">3 213</td>
      <td style="padding: 8px; border: 1px solid #ddd;">0</td>
      <td style="padding: 8px; border: 1px solid #ddd;">10</td>
      <td style="padding: 8px; border: 1px solid #ddd;">5</td>
    </tr>
    <tr>
      <td style="padding: 8px; border: 1px solid #ddd;">5</td>
      <td style="padding: 8px; border: 1px solid #ddd;">3 132</td>
      <td style="padding: 8px; border: 1px solid #ddd;">0</td>
      <td style="padding: 8px; border: 1px solid #ddd;">10</td>
      <td style="padding: 8px; border: 1px solid #ddd;">5</td>
    </tr>
    <tr>
      <td style="padding: 8px; border: 1px solid #ddd;">6</td>
      <td style="padding: 8px; border: 1px solid #ddd;">3 352</td>
      <td style="padding: 8px; border: 1px solid #ddd;">0</td>
      <td style="padding: 8px; border: 1px solid #ddd;">10</td>
      <td style="padding: 8px; border: 1px solid #ddd;">5</td>
    </tr>
    <tr>
      <td style="padding: 8px; border: 1px solid #ddd;">7</td>
      <td style="padding: 8px; border: 1px solid #ddd;">2 798</td>
      <td style="padding: 8px; border: 1px solid #ddd;">0</td>
      <td style="padding: 8px; border: 1px solid #ddd;">10</td>
      <td style="padding: 8px; border: 1px solid #ddd;">5</td>
    </tr>
    <tr style="font-weight: bold; background-color: #f9f9f9;">
      <td style="padding: 8px; border: 1px solid #ddd;">All</td>
      <td style="padding: 8px; border: 1px solid #ddd;">15 861</td>
      <td style="padding: 8px; border: 1px solid #ddd;">0</td>
      <td style="padding: 8px; border: 1px solid #ddd;">10</td>
      <td style="padding: 8px; border: 1px solid #ddd;">5</td>
    </tr>
  </tbody>
</table>

3. Total revenue by country varied from ¤68 to ¤6,628, with customer counts between 1 and 60. India led in both customer numbers and total revenue, followed closely by China, and the United States.
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/revenue_customers.png" ><br>
    <em>...</em>
</td>
</tr>
</table>
<br>

4. Average customer lifetime value (CLV) varied between ¤68 to ¤217, with Réunion having the highest CLV, followed by Vatican City and Nauru.
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/clv_customers.png" ><br>
    <em>...</em>
</td>
</tr>
</table>
<br>

Rank|Top 10 Countries|Number of Customers|Total Revenue
:---|:---|:---|:---
1|India|60|6 628
2|Chine|53|5 799
3|United States|36|4 110
4|Japan|31|3 471
5|Mexico|30|3 307
6|Brazil|28|3 201
7|Russion Federation|28|3 046
8|Philippines|20|2 381
9|Turkey|15|1 662
10|Indonesia|14|1 510


5. The Asia-Pacific region emerged as the clear leader ¤26 468 in sales and 235 customers, while Latin America performed the worst selling ¤8 096 from 73 customers.
<table>
<tr>
<td align="center" valign="top" width="100%">
    <img src="visualisations/regional.png" ><br>
    <em>...</em>
</td>
</tr>
</table>
<br>


1	Réunion	1	216.54	216.54
2	Holy See (Vatican City State)	1	152.66	152.66
3	Nauru	1	148.69	148.69
4	Sweden	1	144.66	144.66
5	Hong Kong	1	142.70	142.70
6	Thailand	3	419.04	139.68
7	Belarus	2	277.34	138.67
8	Greenland	1	137.66	137.66
9	Turkmenistan	1	136.73	136.73
10	Chad	1	135.68	135.68



## Takeaways
### Successes
The project successfully used SQL to query a relational database and extract relevant information in response to specific business questions.

### Challenges
The static and hypothetical nature of the sample data limited opportunities for deeper engagement with real-time stakeholder needs. In the absence of direct business interaction, interpreting findings into practical decisions remained largely hypothetical. Presenting results without feedback loops also limited iteration and refinement of analysis.

### Way Forward
Future projects could benefit from working with more interactive stakeholder contexts or simulated business scenarios to mirror the iterative nature of real-world decision-making. Expanding the reporting output to include automated dashboards or integrations with business intelligence platforms could also support more dynamic data consumption.
