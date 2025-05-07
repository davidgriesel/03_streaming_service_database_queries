# Request

I am working on an SQL analytics project using a dataset provided through CareerFoundry as part of their Data Analytics programme. The original dataset appears to have been created as a training set for PostgreSQL users for a fictional video game store called Rockbuster. There are many open source projects that used this particular data source. My project goal was to create an ERD and draw up a Data Dictionary, and then to answer 5 ad-hoc business questions posed by the board of directors and present them with the results. 

- Which movies contributed the most/least to revenue gain?
- What was the average rental duration for all videos?
- Which countries are Rockbuster customers based in?
- Where are customers with a high lifetime value based?
- Do sales figures vary between geographic regions?

In order to do this I drew an ERD and created a data dictionary. I then wanted to gain an understanding of the data by exploring it, profiling it, and doing some integrity and quality checks to see if I need to do any cleaning. I then want to create some queries to address these 5 questions and finally I want to create a KeyNote presentation for the board of directors containing the information they required in an appropriate format. This should be very high level and focussed on the questions only, but I do want to add a slide showing some information about the customer base like how many customers there are, where they are located etc, and the catalogue such as the number of titles, available langauges, copies in each store etc. 

I want you to start by reviewing the ERD and my Data Dictionary and tell me if you can find any errors. The attached refers. Tell me if you need anything else to do this. 

⸻

## 1. ERD Check
- Overall, your ERD matches the structure of the Rockbuster Stealth dataset correctly.
- Relationships and Keys: Primary keys and foreign keys are well-marked, and relationships align logically (e.g., rental connects to inventory, customer, and staff; payment connects to rental and customer).
- Completeness: All major entities (film, customer, staff, payment, rental, inventory, etc.) are included.
- Normalisation: Data appears reasonably normalised (e.g., cities and countries are separate, avoiding duplication).

✅ Nothing critical is missing or structurally wrong.

⸻

## 2. Data Dictionary Review
- General: Very comprehensive. Tables, columns, types, and relationships are well-documented.
- Minor Issues/Improvements:
  **Consistency of Data Types:** In Payment, you mention payment_id as integer but in the ERD it’s SERIAL — that’s acceptable, but you could clarify that SERIAL implies an auto-incrementing integer in PostgreSQL.
  **Small Typo:** In Language, the field name is described as character(255) — in the ERD, it’s character(20). Minor but should match exactly.
  **Redundancy:** Customer table has both activebool (boolean) and active (integer). You correctly listed both, but you may want to highlight that this is redundant. (It’s an original dataset flaw — you could flag it for cleaning or simplification.)
  **Film Category / Film Actor:** You show film_id and category_id/actor_id both as “Primary/Foreign keys”, which is technically correct for join tables, but you could explicitly note that these are composite primary keys for clarity.
  **Descriptive Field Improvements:** Film table: fulltext field — you list it as “Text of film”, but technically it’s a tsvector for full-text search. I’d recommend describing it as “Full-text search vector for film title/description” for accuracy.

⸻

## 3. Other Comments
- **Entity Classification:** You correctly separate Fact Tables (rental, payment) and Dimension Tables. Some people might also describe inventory as a factless fact table since it links films to stores.
- **Diagram Layout:** The ERD could be slightly cleaner if you group address → city → country vertically (it’s minor, not critical).
- **Missing: Amount field precision:** In Payment, amount is listed simply as numeric. You might specify precision (e.g., NUMERIC(5,2)) to be exact as in the ERD.

⸻

# Quick Summary

Area|Status|Comments
:---:|:---:|:---:
ERD structure|✅|Accurate and complete
Data Dictionary detail|✅|Good, very minor consistency/clarity improvements
Suggestions|✏️|Minor typographical fixes, clarity on data types



⸻

# Recommendations
- Add a brief “assumptions/limitations” note at the start of your project (e.g., highlighting redundant fields like activebool vs active, and slight inconsistencies in the original dataset).
- When you do data cleaning later, consider consolidating the active flags to avoid confusion.
- In your presentation, avoid showing too much ERD detail to the directors — a simple stylised version highlighting only key tables (Customer, Rental, Payment, Film, Store) would be more appropriate for a high-level audience.

⸻

# Key Takeaways for Later (Post-Analysis / Cleaning Phase)
1. Customer Table – Redundant Field
  ✔️ Yes, active (integer) and activebool (boolean) seem redundant.
  Action: Validate if they are always aligned (e.g., active = 1 when activebool = TRUE), then keep only one for clarity. Prefer activebool since it’s semantically cleaner (boolean).
2. Language Table – Field Length Mismatch
  🔍 Minor note: The name field should have consistent length (character(20), not 255).
  Action: Decide whether you want to adjust it during profiling, although this is very minor and won’t affect your 5 business questions.
3. Film Table – Fulltext Field
  🛠 fulltext is a tsvector for full-text search.
  Action: You likely won’t need it for the 5 questions. Ignore unless you explore search functionalities later.
4. Inventory Table – No rental pricing
  📌 Inventory only tracks copies; pricing comes from Film (rental rate) and Payment (actual transaction).
  Action: Be careful when answering “revenue gain” questions — you need to join Rental → Payment, not just Rental.
5. Payments Table – Precision
  📏 Precision of amount (should be NUMERIC(5,2)).
  Action: Only relevant if you do money aggregations later (which you will for revenue questions). It’s a good habit to always cast amounts precisely in reports.