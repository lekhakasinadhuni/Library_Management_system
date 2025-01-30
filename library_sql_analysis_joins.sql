SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM members;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;

-- Project Task
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- Task 3: Delete a Record from the Issued Status Table-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id ='IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_emp_id, 
	count(*) total_book_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING total_book_issued > 1 
order by total_book_issued;

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

CREATE TABLE issued_book_count
AS
SELECT b.isbn, b.book_title, count(ist.issued_book_isbn) as total_book_issued_cnt
FROM BOOKS as b
JOIN 
issued_status ist 
ON b.isbn = ist.issued_book_isbn
group by b.isbn, b.book_title
order by total_book_issued_cnt DESC;

SELECT * FROM issued_book_count;

-- Data Analysis & Findings

-- The following SQL queries were used to address specific questions:
-- Task 7. Retrieve All Books in a Specific Category: Classic

SELECT * FROM books
WHERE category = 'Classic';


-- Task 8: Find Total Rental Income by Category:

SELECT 
b.category, 
sum(b.rental_price) as total_rental_income 
FROM books as b
JOIN issued_status as ist
ON b.isbn = ist.issued_book_isbn
GROUP BY b.category
ORDER BY total_rental_income DESC;


-- Task 9.List Members Who Registered in the Last 180 Days:

SELECT * 
FROM members
WHERE reg_date >= NOW() - INTERVAL 180 DAY ;

 

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES 
('C120', 'ross', '167 Oak St', '2024-08-01'),
('C121', 'tim', '133 Chestnut St', '2024-09-01');

-- Task 10. List Employees with Their Branch Manager's Name and their branch details:

SELECT 
e1.*,
b.manager_id,
e2.emp_name as manager
FROM employees e1
JOIN branch b
on e1.branch_id = b.branch_id
JOIN employees e2
ON b.manager_id = e2.emp_id;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold(>7.00):
 
 CREATE TABLE expensive_books 
 AS
 SELECT * FROM books
 WHERE rental_price > 7.0;
 
 SELECT * FROM expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
DISTINCT ist.issued_id,
ist.issued_date,
ist.issued_book_name
FROM issued_status ist
LEFT JOIN return_status rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id IS NULL;


/* Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
*/

SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;


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


/* Task 14: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

SELECT * FROM branch;

SELECT * FROM issued_status;

SELECT * FROM employees;

SELECT * FROM books;

SELECT * FROM return_status;

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

SELECT * FROM branch_reports;


/* Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
*/ 

CREATE TABLE active_members
SELECT 
DISTINCT issued_member_id,
issued_book_name,
issued_date
FROM issued_status
WHERE issued_date >= ('2024-02-01' - INTERVAL 60 day);

SELECT * FROM active_members;

/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.*/


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


/* Task 18: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include: The number of overdue books. 
The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
The resulting table should show: Member ID, Number of overdue books, Total fines
*/

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









