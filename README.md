# Streaming Service Database Queries
*This project was completed as part of the [CareerFoundry Data Analytics Programme](https://careerfoundry.com/en/courses/become-a-data-analyst/).*

## Overview
A legacy movie rental company is planning to re-enter the market with a new online streaming service. This project supports the launch strategy by using SQL to query a relational database containing inventory, customer, and payment data. The analysis addresses a series of ad hoc business questions posed by management, helping to identify revenue-driving films, high-value markets, and regional sales trends to inform content strategy and customer targeting.

## Tools
- **PostgreSQL** - Relational Database
- **DbVisualizer** - Entity Relationship Diagram
- **Tableau** - Visualisation
- **Excel** - Output
- **Word** - Documentation
- **PowerPoint** - Presentation

## Process
- **Understanding** - ERD Creation | Data Dictionary Documentation
- **Data Preparation** - Profiling | Integrity Checks | Quality Checks | Cleaning | Integration
- **Analysis** - Business Rule Validation | Metric Derivation | Ad Hoc Querying
- **Communication** - Visualisation | Presentation

## Data
This analysis uses a modified version of the DVD Rental dataset originally provided as a sample database for learning and testing SQL with PostgreSQL. The dataset was adapted and provided by CareerFoundry as part of their Data Analytics Programme.

- [**Dataset**](http://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip) – Film, inventory, customer, payment, and rental records

## Links
- [**Entity Relationship Diagram**](deliverables/erd_dbvisualiser.png)
- [**Entity Relationship Diagram**](https://github.com/davidgriesel/03-streaming-service-database-queries/blob/main/deliverables/erd_dbvisualiser.png)
- [**Data Dictionary**](https://github.com/davidgriesel/03-streaming-service-database-queries/blob/main/deliverables/data_dictionary.pdf)
- [**Interactive Tableau Dashboard**](https://public.tableau.com/views/StreamingService_17486375379040/Dashboard1?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- [**Presentation**](https://github.com/davidgriesel/03-streaming-service-database-queries/blob/main/deliverables/presentation.pdf)

## Key Insights

1. The top 5 revenue-generating films earned between ¤205 and ¤232, while 7 films shared the bottom five positions, generating between ¤6 and ¤8.
2. <table width="100%">
<tr>
<td align="center" valign="top" width="50%">
    <img src="visualisations/top_films.png""><br>
</td>
<td align="center" valign="top" width="50%">
    <img src="visualisations/bottom_films.png"><br>
</td>
</tr>

3. Rental durations across all terms ranged from same-day returns to a maximum of 10, with an average duration of 5 days.
4. Total revenue by country varied from ¤68 to ¤6,628, with customer counts between 1 and 60. India led in both customer numbers and total revenue, followed closely by China, and the United States.
5. Average customer lifetime value (CLV) varied between ¤68 to ¤217, with Réunion having the highest CLV, followed by Vatican City and Nauru.
6. The Asia-Pacific region emerged as the clear leader ¤26 468 in sales and 235 customers, while Latin America performed the worst selling ¤8 096 from 73 customers.




## Takeaways
### Successes
The project successfully used SQL to query a relational database and extract relevant information in response to specific business questions.

### Challenges
The static and hypothetical nature of the sample data limited opportunities for deeper engagement with real-time stakeholder needs. In the absence of direct business interaction, interpreting findings into practical decisions remained largely hypothetical. Presenting results without feedback loops also limited iteration and refinement of analysis.

### Way Forward
Future projects could benefit from working with more interactive stakeholder contexts or simulated business scenarios to mirror the iterative nature of real-world decision-making. Expanding the reporting output to include automated dashboards or integrations with business intelligence platforms could also support more dynamic data consumption.
