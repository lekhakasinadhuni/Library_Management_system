# Library_Management_system
## Project Overview
**Project Title: Library Management System**
This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![image Alt](https://github.com/lekhakasinadhuni/Library_Management_system/blob/983dc31169ebe6b8936e53fcf5308a2cbc6a8d0f/library.1.jpg)

# Objectives
1. **Set up the Library Management System Database:** Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations:** Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select):** Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries:** Develop complex queries to analyze and retrieve specific data.

# Project Structure
## 1. Database Setup

![image Alt](https://github.com/lekhakasinadhuni/Library_Management_system/blob/b7fdb0f9a366c1ff51e6740d91ba578bc1e59f7e/data%20model.png)

- **Database Creation:** Created a database named library_project.
- **Table Creation:** Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_project;

CREATE TABLE branch
(
branch_id VARCHAR(10) PRIMARY KEY, 
manager_id VARCHAR(10), 
branch_address VARCHAR(55), 
contact_no VARCHAR(10)
);

ALTER TABLE branch 
MODIFY COLUMN contact_no VARCHAR(15);

-- Create table "Employee"
CREATE TABLE employees 
(
emp_id VARCHAR(10) PRIMARY KEY,
emp_name VARCHAR(25),
position VARCHAR(15),
salary INT,
branch_id VARCHAR(25) -- FK
);

-- Create table "Books"
CREATE TABLE books
(
isbn VARCHAR(20) PRIMARY KEY,
book_title VARCHAR(75),
category VARCHAR(20),
rental_price FLOAT,
status VARCHAR(20),
author VARCHAR(30),
publisher VARCHAR(55)
);

-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
member_id VARCHAR(20) PRIMARY KEY,
member_name VARCHAR(25),
member_address VARCHAR(75),
reg_date DATE
);

-- Create table "Issued Status"
CREATE TABLE issued_status
(
issued_id VARCHAR(10) PRIMARY KEY,
issued_member_id VARCHAR(20), -- FOREIGN KEY
issued_book_name VARCHAR(75),
issued_date DATE,
issued_book_isbn VARCHAR(25), -- FK
issued_emp_id VARCHAR(10) -- FK
);

-- Create table "Returned Status"
CREATE TABLE return_status
(
return_id VARCHAR(10) PRIMARY KEY,
issued_id VARCHAR(10),
return_book_name VARCHAR(75),
return_date DATE,
return_book_isbn VARCHAR(20)
);


-- FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);
```
## 2. CRUD Operations
- **Create:** Inserted sample records into the books table.
- **Read:** Retrieved and displayed data from various tables.
- **Update:** Updated records in the employees table.
- **Delete:** Removed records from the members table as needed.

**Task 1. Create a New Book Record** -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address** 
```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```
**Task 3: Delete a Record from the Issued Status Table** -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```
**Task 4: Retrieve All Books Issued by a Specific Employee** -- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```
**Task 5: List Members Who Have Issued More Than One Book** -- Objective: Use GROUP BY to find members who have issued more than one book.
```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```
## 3. CTAS (Create Table As Select)
- **Task 6: Create Summary Tables:** Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
```sql
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```
## 4. Data Analysis & Findings
The following SQL queries were used to address specific questions:
- **Task 7. Retrieve All Books in a Specific Category:**
```sql
SELECT * FROM books
WHERE category = 'Classic';
```
- **Task 8: Find Total Rental Income by Category:**
```sql
SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1
```
- **Task 9. List Members Who Registered in the Last 180 Days:**
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```
- **Task 10. List Employees with Their Branch Manager's Name and their branch details:**
```sql
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id
```
**Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:**
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```
**Task 12: Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```
## Advanced SQL Operations
**Task 13: Identify Members with Overdue Books**

Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
```sql
SELECT DISTINCT 
m.member_id,  
m.member_name, 
ist.issued_book_name as book_title, 
ist.issued_date, 
GREATEST(DATEDIFF('2024-08-24', ist.issued_date),0) as days_overdue
FROM issued_status ist 
JOIN  members m
ON m.member_id = ist.issued_member_id
LEFT JOIN return_status rst
ON ist.issued_id = rst.issued_id 
WHERE rst.return_date IS NULL
ORDER BY 1;
```
**Task 14: Branch Performance Report**
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
```sql
CREATE TABLE branch_reports
AS
SELECT 
emp.branch_id,
COUNT(ist.issued_id) AS num_books_issued, 
COUNT(rst.return_id) AS num_books_returned, 
SUM(b.rental_price) AS total_revenue
FROM issued_status ist
JOIN employees emp
ON 	ist.issued_emp_id = emp.emp_id
LEFT JOIN books b
ON ist.issued_book_isbn = b.isbn
LEFT JOIN return_status rst
ON ist.issued_id = rst.issued_id
GROUP BY branch_id;
```
**Task 16: CTAS: Create a Table of Active Members**
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
```sql
CREATE TABLE active_members
SELECT 
DISTINCT issued_member_id,
issued_book_name,
issued_date
FROM issued_status
WHERE issued_date >= ('2024-02-01' - INTERVAL 60 day);

SELECT * FROM active_members;
```
**Task 17: Find Employees with the Most Book Issues Processed**
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
```sql
SELECT 
b.*,
emp.emp_name,
count(ist.issued_book_name) AS num_books_processed
FROM issued_status ist
JOIN employees emp
ON ist.issued_emp_id = emp.emp_id
JOIN branch b
ON b.branch_id = emp.branch_id
GROUP BY b.branch_id, emp.emp_name;
```
**Task 18: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.**
```sql
SELECT 
ist.issued_member_id,
COUNT(ist.issued_book_name) AS total_books_issued,
SUM(CASE         -- If the book is returned late, calculate fine based on days overdue

        WHEN return_date IS NOT NULL AND DATEDIFF(return_date, issued_date) > 30 
        THEN (DATEDIFF(return_date, issued_date) - 30) * 0.50 
        
        -- If the book is still not returned and overdue, calculate fine up to today
        WHEN return_date IS NULL AND DATEDIFF(CURDATE(), issued_date) > 30 
        THEN (DATEDIFF(CURDATE(), issued_date) - 30) * 0.50 
        ELSE 0
END) AS total_fine
FROM issued_status ist
JOIN members m
ON ist.issued_member_id = m.member_id
LEFT JOIN return_status rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_date >= ist.issued_date + INTERVAL 30 DAY
OR rst.return_id IS NULL
GROUP BY ist.issued_member_id
```
# Reports
- **Database Schema:** Detailed table structures and relationships.
- **Data Analysis:** Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports:** Aggregated data on high-demand books and employee performance.

# Conclusion
This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.
