# What is the total amount each customer spent at the restaurant?
SELECT customer_id , sum(price) as total_spent
FROM sales s
INNER JOIN menu m
	ON s.product_id=m.product_id
GROUP BY customer_id;

#  How many days has each customer visited the restaurant?
SELECT customer_id , count(distinct order_date) as days
FROM sales
GROUP BY customer_id;

# What was the first item from the menu purchased by each customer?
WITH CTE AS (
SELECT s.customer_id,
	m.product_name, 
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
)
SELECT  customer_id, product_name
FROM CTE 
WHERE rnk =1;

# What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name ,COUNT(*) AS most_ordered
FROM sales s
INNER JOIN menu m
	ON s.product_id  = m.product_id
GROUP BY product_name
ORDER BY COUNT(*) DESC
LIMIT 1;

# Which item was the most popular for each customer?
WITH CTE AS (
SELECT customer_id,
product_name,
COUNT(*) AS no_of_times_ord,
DENSE_RANK()OVER (PARTITION BY customer_id order by COUNT(*) DESC) rnk
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
GROUP BY customer_id,product_name)
SELECT customer_id , product_name
FROM CTE 
WHERE rnk = 1 ;

# Which item was purchased first by the customer after they became a member?
with cte as (
SELECT  s.customer_id,m.product_name,rank() over(partition by s.customer_id order by order_date) as rnk
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
INNER JOIN members mm
	ON s.customer_id = mm.customer_id
WHERE order_date >= join_date
GROUP BY s.customer_id,m.product_name,order_date
ORDER BY order_date)
SELECT customer_id,product_name
FROM cte 
WHERE rnk = 1;

# Which item was purchased just before the customer became a member?

with cte as (
SELECT  s.customer_id,m.product_name,rank() over(partition by s.customer_id order by order_date desc) as rnk
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
INNER JOIN members mm
	ON s.customer_id = mm.customer_id
WHERE order_date <= join_date
GROUP BY s.customer_id,m.product_name,order_date
ORDER BY order_date)
SELECT customer_id,product_name
FROM cte 
WHERE rnk = 1
ORDER BY customer_id;

# What is the total items and amount spent for each member before they became a member?
SELECT COUNT(*), SUM(price) AS total_spent,s.customer_id
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
INNER JOIN members mm
	ON s.customer_id = mm.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id;

# If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH CTE AS(
SELECT s.customer_id,
 CASE WHEN product_name ='sushi' THEN price*20
 ELSE price*10
 END as points
 FROM sales s
 INNER JOIN menu m
	ON s.product_id = m.product_id)
SELECT customer_id ,
sum(points) as points
FROM CTE
GROUP BY customer_id;

# In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
-- not just sushi - how many points do customer A and B have at the end of January?

WITH points_calc AS (
  SELECT
    s.customer_id,
    CASE
      -- 2× points on all items in the first 7 days after joining
      WHEN s.order_date BETWEEN mm.join_date AND DATE_ADD(mm.join_date, INTERVAL 6 DAY)
        THEN m.price * 10 * 2
      -- Sushi always doubles
      WHEN m.product_name = 'sushi'
        THEN m.price * 10 * 2
      -- Otherwise single points
      ELSE m.price * 10
    END AS points
  FROM sales s
  INNER JOIN menu m
	ON s.product_id = m.product_id
INNER JOIN members mm
	ON s.customer_id = mm.customer_id
  WHERE
    s.order_date BETWEEN '2021-01-01' AND '2021-01-31'
)
SELECT customer_id, SUM(points) AS points_total
FROM points_calc
GROUP BY customer_id
ORDER BY customer_id ;

#      BONUS QUESTION

# Determine the name and price of the product ordered by each customer on all order dates & find out wheather the customer was member on the order date or not

SELECT s.customer_id,
s.order_date,
m.product_name,
m.price,
CASE WHEN s.order_date >= join_date THEN 'Y'
	ELSE 'N'
END AS member    
FROM menu m
INNER JOIN sales s
	ON s.product_id = m.product_id
LEFT JOIN members mm
	ON s.customer_id = mm.customer_id 
ORDER BY customer_id,order_date;

# Rank the previous output based on the order date for each customer. Display null if customer was not a member when dish was ordered

SELECT s.customer_id,
s.order_date,
m.product_name,
m.price,
CASE WHEN s.order_date >= join_date THEN 'Y'
	ELSE 'N'
END AS member,
CASE WHEN order_date >= join_date THEN RANK() OVER ( PARTITION BY customer_id,order_date >= join_date ORDER BY order_date)
		ELSE NULL
END AS rnk      
FROM menu m
INNER JOIN sales s
	ON s.product_id = m.product_id
LEFT JOIN members mm
	ON s.customer_id = mm.customer_id 
ORDER BY customer_id,order_date;
