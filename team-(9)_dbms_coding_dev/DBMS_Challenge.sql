-- ============================================================
--              LIBRARY LENDING SYSTEM
-- ============================================================

-- ------------------------------------------------------------
-- 1. CREATE DATABASE
-- ------------------------------------------------------------

-- Create the database for the Library Lending System
CREATE DATABASE LibraryLendingSystem;

-- Select the database so that all tables are created inside it
USE LibraryLendingSystem;


-- ============================================================
-- 2. CREATE BOOK TABLE
-- ============================================================

-- The Book table stores information about a book/edition.
-- ISBN can be shared by multiple physical copies.
-- Each book gets a unique book_id.

CREATE TABLE Book (
    
    -- Primary Key: uniquely identifies each book/edition
    book_id INT PRIMARY KEY AUTO_INCREMENT,

    -- ISBN number of the book
    isbn VARCHAR(20) NOT NULL,

    -- Title of the book
    title VARCHAR(200) NOT NULL,

    -- Author of the book
    author VARCHAR(200) NOT NULL,

    -- Publisher of the book
    publisher VARCHAR(200),

    -- Year in which the book was published
    publication_year INT,

    -- Category/subject of the book
    category VARCHAR(100)
);


-- ============================================================
-- 3. CREATE BOOKCOPY TABLE
-- ============================================================

-- A book can have multiple physical copies.
-- Therefore, availability is maintained for each physical copy.
--
-- Example:
-- Book: "Clean Code"
-- Copy 1 -> Available
-- Copy 2 -> Borrowed
-- Copy 3 -> Available

CREATE TABLE BookCopy (

    -- Primary Key: uniquely identifies each physical copy
    copy_id INT PRIMARY KEY AUTO_INCREMENT,

    -- Foreign Key: identifies which book this copy belongs to
    book_id INT NOT NULL,

    -- TRUE  = copy is available
    -- FALSE = copy is currently borrowed
    available BOOLEAN NOT NULL DEFAULT TRUE,

    -- Physical shelf where the copy is stored
    shelf VARCHAR(50),

    -- Section of the library
    section VARCHAR(50),

    -- Connect BookCopy with Book
    FOREIGN KEY (book_id)
        REFERENCES Book(book_id)

        -- If a book is deleted, its copies are also deleted
        ON DELETE CASCADE

        -- If book_id changes, update it here too
        ON UPDATE CASCADE
);


-- ============================================================
-- 4. CREATE MEMBER TABLE
-- ============================================================

-- The Member table stores information about people
-- who are registered with the library.

CREATE TABLE Member (

    -- Primary Key: uniquely identifies each member
    member_id INT PRIMARY KEY AUTO_INCREMENT,

    -- Member's first name
    first_name VARCHAR(100) NOT NULL,

    -- Member's last name
    last_name VARCHAR(100) NOT NULL,

    -- Member's address
    address VARCHAR(255),

    -- Member's phone number
    phone VARCHAR(20),

    -- Member's email address
    -- UNIQUE prevents duplicate email addresses
    email VARCHAR(150) UNIQUE,

    -- Date on which the member joined the library
    membership_date DATE NOT NULL
);


-- ============================================================
-- 5. CREATE LIBRARIAN TABLE
-- ============================================================

-- The Librarian table stores information about
-- library staff members.

CREATE TABLE Librarian (

    -- Primary Key: uniquely identifies a librarian
    librarian_id INT PRIMARY KEY AUTO_INCREMENT,

    -- Librarian's name
    name VARCHAR(150) NOT NULL,

    -- Librarian's email
    email VARCHAR(150) UNIQUE,

    -- Date when the librarian was hired
    hire_date DATE NOT NULL
);


-- ============================================================
-- 6. CREATE LOAN TABLE
-- ============================================================

-- The Loan table stores every borrowing transaction.
--
-- It also maintains the complete loan history.
--
-- return_date can be NULL when the book has not yet
-- been returned.

CREATE TABLE Loan (

    -- Primary Key: uniquely identifies every loan
    loan_id INT PRIMARY KEY AUTO_INCREMENT,

    -- Foreign Key: identifies the physical copy borrowed
    copy_id INT NOT NULL,

    -- Foreign Key: identifies the member who borrowed it
    member_id INT NOT NULL,

    -- Foreign Key: identifies the librarian handling the loan
    librarian_id INT,

    -- Date on which the book was borrowed
    borrow_date DATE NOT NULL,

    -- Date by which the book should be returned
    due_date DATE NOT NULL,

    -- Actual return date
    -- NULL means the book has not been returned yet
    return_date DATE,

    -- Current status of the loan
    -- borrowed = currently borrowed
    -- returned = already returned
    -- overdue = not returned after due date
    status ENUM('borrowed', 'returned', 'overdue')
           NOT NULL DEFAULT 'borrowed',


    -- --------------------------------------------------------
    -- FOREIGN KEY CONSTRAINTS
    -- --------------------------------------------------------

    -- Connect Loan with BookCopy
    FOREIGN KEY (copy_id)
        REFERENCES BookCopy(copy_id)
        ON UPDATE CASCADE,

    -- Connect Loan with Member
    FOREIGN KEY (member_id)
        REFERENCES Member(member_id)
        ON UPDATE CASCADE,

    -- Connect Loan with Librarian
    FOREIGN KEY (librarian_id)
        REFERENCES Librarian(librarian_id)
        ON UPDATE CASCADE,


    -- --------------------------------------------------------
    -- CHECK CONSTRAINTS
    -- --------------------------------------------------------

    -- Due date cannot be before borrow date
    CHECK (due_date >= borrow_date),

    -- Return date cannot be before borrow date
    CHECK (
        return_date IS NULL
        OR return_date >= borrow_date
    )
);


-- ============================================================
-- 7. INSERT SAMPLE BOOKS
-- ============================================================

-- Insert some sample books into the Book table.

INSERT INTO Book
(isbn, title, author, publisher, publication_year, category)
VALUES

-- Book 1
('9780135166307',
 'Database System Concepts',
 'Abraham Silberschatz',
 'McGraw-Hill',
 2019,
 'Database'),

-- Book 2
('9780132350884',
 'Clean Code',
 'Robert C. Martin',
 'Prentice Hall',
 2008,
 'Programming'),

-- Book 3
('9780262033848',
 'Introduction to Algorithms',
 'Thomas H. Cormen',
 'MIT Press',
 2009,
 'Algorithms'),

-- Book 4
('9780134685991',
 'Effective Java',
 'Joshua Bloch',
 'Addison-Wesley',
 2018,
 'Programming');


-- ============================================================
-- 8. INSERT MULTIPLE BOOK COPIES
-- ============================================================

-- A single book can have multiple physical copies.
--
-- Book 1 has three copies.
-- Book 2 has two copies.
-- Book 3 has one copy.
-- Book 4 has one copy.

INSERT INTO BookCopy
(book_id, available, shelf, section)
VALUES

-- Copies of Database System Concepts
(1, TRUE, 'S1', 'Database'),
(1, TRUE, 'S1', 'Database'),
(1, TRUE, 'S2', 'Database'),

-- Copies of Clean Code
(2, TRUE, 'S3', 'Programming'),
(2, TRUE, 'S3', 'Programming'),

-- Copy of Introduction to Algorithms
(3, TRUE, 'S4', 'Algorithms'),

-- Copy of Effective Java
(4, TRUE, 'S5', 'Programming');


-- ============================================================
-- 9. INSERT SAMPLE MEMBERS
-- ============================================================

INSERT INTO Member
(first_name, last_name, address, phone, email, membership_date)
VALUES

('Raja',
 'Reddy',
 'Mangalagiri',
 '9876543210',
 'raja@gmail.com',
 '2026-01-10'),

('Rahul',
 'Kumar',
 'Vijayawada',
 '9876543211',
 'rahul@gmail.com',
 '2026-02-15'),

('Ananya',
 'Sharma',
 'Guntur',
 '9876543212',
 'ananya@gmail.com',
 '2026-03-20');


-- ============================================================
-- 10. INSERT SAMPLE LIBRARIANS
-- ============================================================

INSERT INTO Librarian
(name, email, hire_date)
VALUES

('John Smith',
 'john@library.com',
 '2024-06-01'),

('Priya Sharma',
 'priya@library.com',
 '2025-01-15');


-- ============================================================
-- 11. ISSUE A BOOK
-- ============================================================

-- We use a transaction to make sure that checking availability,
-- creating the loan, and changing availability happen safely.

START TRANSACTION;


-- Find one available physical copy of Book 1.
--
-- FOR UPDATE locks the selected row while this transaction
-- is running.

SELECT copy_id
FROM BookCopy
WHERE book_id = 1
AND available = TRUE
LIMIT 1
FOR UPDATE;


-- Suppose the selected copy_id is 1.
--
-- Create a new loan.
-- The due date is 14 days after the borrow date.

INSERT INTO Loan
(
    copy_id,
    member_id,
    librarian_id,
    borrow_date,
    due_date,
    status
)
VALUES
(
    1,                          -- Physical copy
    1,                          -- Member
    1,                          -- Librarian
    CURDATE(),                  -- Today's date
    DATE_ADD(
        CURDATE(),
        INTERVAL 14 DAY
    ),                          -- Due date
    'borrowed'                  -- Loan status
);


-- Mark the physical copy as unavailable
-- because it has now been borrowed.

UPDATE BookCopy
SET available = FALSE
WHERE copy_id = 1;


-- Permanently save all changes.

COMMIT;


-- ============================================================
-- 12. RETURN A BOOK
-- ============================================================

-- Start a transaction for the return operation.

START TRANSACTION;


-- Update the loan record.
--
-- Store today's date as the return date.
-- Change status to returned.

UPDATE Loan
SET
    return_date = CURDATE(),
    status = 'returned'
WHERE loan_id = 1
AND status IN ('borrowed', 'overdue');


-- Make the physical copy available again.

UPDATE BookCopy
SET available = TRUE
WHERE copy_id = (
    
    -- Find the copy associated with this loan
    SELECT copy_id
    FROM Loan
    WHERE loan_id = 1
);


-- Save the changes.

COMMIT;


-- ============================================================
-- 13. MARK OVERDUE LOANS
-- ============================================================

-- If the due date has passed and the book has not
-- been returned, mark the loan as overdue.

UPDATE Loan
SET status = 'overdue'
WHERE return_date IS NULL
AND due_date < CURDATE()
AND status = 'borrowed';


-- ============================================================
-- 14. FIND OVERDUE BOOKS
-- ============================================================

-- Display all books that are overdue.

SELECT

    -- Loan ID
    l.loan_id,

    -- Book title
    b.title,

    -- Physical copy ID
    bc.copy_id,

    -- Member's full name
    CONCAT(
        m.first_name,
        ' ',
        m.last_name
    ) AS member_name,

    -- Borrow date
    l.borrow_date,

    -- Due date
    l.due_date,

    -- Return date
    l.return_date

FROM Loan l

-- Connect Loan to BookCopy
JOIN BookCopy bc
    ON l.copy_id = bc.copy_id

-- Connect BookCopy to Book
JOIN Book b
    ON bc.book_id = b.book_id

-- Connect Loan to Member
JOIN Member m
    ON l.member_id = m.member_id

-- Only books that have not been returned
WHERE l.return_date IS NULL

-- And whose due date has passed
AND l.due_date < CURDATE();


-- ============================================================
-- 15. FIND CURRENTLY AVAILABLE BOOKS
-- ============================================================

-- Display every physical copy that is currently available.

SELECT

    b.book_id,
    b.isbn,
    b.title,
    b.author,

    -- Physical copy ID
    bc.copy_id,

    -- Location of the copy
    bc.shelf,
    bc.section

FROM Book b

JOIN BookCopy bc
    ON b.book_id = bc.book_id

WHERE bc.available = TRUE;


-- ============================================================
-- 16. FIND TOTAL AND AVAILABLE COPIES
-- ============================================================

-- Display how many copies exist for each book
-- and how many are currently available.

SELECT

    b.book_id,

    b.title,

    -- Total number of physical copies
    COUNT(bc.copy_id) AS total_copies,

    -- Number of currently available copies
    SUM(bc.available) AS available_copies

FROM Book b

LEFT JOIN BookCopy bc
    ON b.book_id = bc.book_id

GROUP BY
    b.book_id,
    b.title;


-- ============================================================
-- 17. FIND MEMBER BORROWING HISTORY
-- ============================================================

-- Display all books previously borrowed by Member 1.
--
-- Returned books are also displayed because Loan records
-- are never deleted.

SELECT

    l.loan_id,

    b.title,

    b.author,

    l.borrow_date,

    l.due_date,

    l.return_date,

    l.status

FROM Loan l

JOIN BookCopy bc
    ON l.copy_id = bc.copy_id

JOIN Book b
    ON bc.book_id = b.book_id

WHERE l.member_id = 1

ORDER BY l.borrow_date DESC;


-- ============================================================
-- 18. FIND ALL CURRENTLY BORROWED BOOKS
-- ============================================================

-- Display books that have not yet been returned.

SELECT

    l.loan_id,

    b.title,

    bc.copy_id,

    CONCAT(
        m.first_name,
        ' ',
        m.last_name
    ) AS member_name,

    l.borrow_date,

    l.due_date,

    l.status

FROM Loan l

JOIN BookCopy bc
    ON l.copy_id = bc.copy_id

JOIN Book b
    ON bc.book_id = b.book_id

JOIN Member m
    ON l.member_id = m.member_id

WHERE l.return_date IS NULL;


-- ============================================================
-- 19. CHECK MEMBER FOR OVERDUE BOOKS
-- ============================================================

-- Count the number of overdue books belonging to Member 1.

SELECT COUNT(*) AS overdue_count

FROM Loan

WHERE member_id = 1

AND return_date IS NULL

AND due_date < CURDATE();


-- If overdue_count is greater than 0,
-- the member has at least one overdue book.


-- ============================================================
-- 20. SEARCH BOOKS BY CATEGORY
-- ============================================================

-- Find all books belonging to the Programming category.

SELECT *

FROM Book

WHERE category = 'Programming';


-- ============================================================
-- 21. SEARCH BOOKS BY AUTHOR
-- ============================================================

-- Find books written by an author whose name contains "Martin".

SELECT *

FROM Book

WHERE author LIKE '%Martin%';


-- ============================================================
-- 22. SEARCH BOOK BY ISBN
-- ============================================================

-- Find a specific book using its ISBN.

SELECT *

FROM Book

WHERE isbn = '9780135166307';


-- ============================================================
-- 23. FIND LOANS HANDLED BY A LIBRARIAN
-- ============================================================

-- Display all loans handled by Librarian 1.

SELECT

    l.loan_id,

    b.title,

    CONCAT(
        m.first_name,
        ' ',
        m.last_name
    ) AS member_name,

    l.borrow_date,

    l.return_date,

    l.status

FROM Loan l

JOIN BookCopy bc
    ON l.copy_id = bc.copy_id

JOIN Book b
    ON bc.book_id = b.book_id

JOIN Member m
    ON l.member_id = m.member_id

WHERE l.librarian_id = 1;


-- ============================================================
-- 24. DISPLAY ALL BOOKS
-- ============================================================

SELECT *
FROM Book;


-- ============================================================
-- 25. DISPLAY ALL BOOK COPIES
-- ============================================================

SELECT *
FROM BookCopy;


-- ============================================================
-- 26. DISPLAY ALL MEMBERS
-- ============================================================

SELECT *
FROM Member;


-- ============================================================
-- 27. DISPLAY ALL LIBRARIANS
-- ============================================================

SELECT *
FROM Librarian;


-- ============================================================
-- 28. DISPLAY COMPLETE LOAN HISTORY
-- ============================================================

-- This query combines information from all related tables.

SELECT

    l.loan_id,

    b.title,

    bc.copy_id,

    CONCAT(
        m.first_name,
        ' ',
        m.last_name
    ) AS member_name,

    lib.name AS librarian_name,

    l.borrow_date,

    l.due_date,

    l.return_date,

    l.status

FROM Loan l

JOIN BookCopy bc
    ON l.copy_id = bc.copy_id

JOIN Book b
    ON bc.book_id = b.book_id

JOIN Member m
    ON l.member_id = m.member_id

LEFT JOIN Librarian lib
    ON l.librarian_id = lib.librarian_id

ORDER BY l.borrow_date DESC;