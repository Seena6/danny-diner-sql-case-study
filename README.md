# 🍽️ Danny Diner SQL Case Study

## 📌 Project Overview

This project is based on the **Danny Diner Case Study** from the *8 Week SQL Challenge*.

The objective of this project is to analyze customer purchasing behaviour, menu performance, and the impact of a loyalty program using SQL. The project focuses on solving real-world business questions using structured queries and transforming raw data into meaningful insights.

---

## 🗂️ Dataset Description

The dataset consists of three tables:

**sales**

* customer_id – Unique ID of the customer
* order_date – Date of purchase
* product_id – Purchased product

**menu**

* product_id – Unique product ID
* product_name – Name of the item
* price – Price of the item

**members**

* customer_id – Unique customer ID
* join_date – Date when customer joined the loyalty program

---

## 🛠️ Tools Used

* SQL (MySQL)
* GitHub

---

## Business Questions Solved

This project answers the following business questions:

* What is the total amount each customer spent at the restaurant?
* How many days has each customer visited the restaurant?
* What was the first item purchased by each customer?
* What is the most purchased item on the menu?
* Which item was the most popular for each customer?
* Which item was purchased first after a customer became a member?
* Which item was purchased just before a customer became a member?
* What is the total number of items and total amount spent before becoming a member?
* How many loyalty points does each customer have?
* How many points do customers earn in the first week after joining the loyalty program?

📌 **All SQL queries used to solve these questions are available in the file:**
`danny_diner.sql`

---

## Sample SQL Queries

### 1. Total amount spent by each customer

```sql
SELECT customer_id, SUM(price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id;
```

---

### 2. First item purchased by each customer

```sql
WITH cte AS (
  SELECT s.customer_id, m.product_name,
         DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM cte
WHERE rnk = 1;
```

---

### 3. Loyalty points calculation

```sql
WITH cte AS (
  SELECT s.customer_id,
         CASE 
           WHEN product_name = 'sushi' THEN price * 20
           ELSE price * 10
         END AS points
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, SUM(points) AS points
FROM cte
GROUP BY customer_id;
```

---

## 🎯 Key Insights

* Some customers contribute significantly more revenue than others
* Sushi is the most frequently purchased and highest point-generating item
* Customers tend to spend more after joining the loyalty program
* Loyalty incentives increase customer engagement and repeat purchases

---

## 📊 Skills Demonstrated

* SQL Joins (INNER JOIN)
* Aggregation Functions (SUM, COUNT)
* Window Functions (RANK, DENSE_RANK)
* CTEs (Common Table Expressions)
* Conditional Logic (CASE WHEN)
* Business Problem Solving using SQL

---

## 📸 Query Output Screenshots

Screenshots of query outputs are available in the **screenshots** folder.

---

## 🚀 Project Structure

```
danny-diner-sql-case-study/
│
├── README.md
├── danny_diner_analysis.sql
├── schema.sql
└── screenshots/
```

---

## 🚀 Conclusion

This project demonstrates how SQL can be used to analyze real-world customer transaction data and generate meaningful business insights that can help improve customer retention and decision-making.

---
