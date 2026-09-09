# Library Lending System

## 📚 Project Overview

The **Library Lending System** is a relational database project designed to manage the essential operations of a library.

The system manages:

* Books and their details
* Multiple physical copies of books
* Library members
* Librarians
* Book borrowing and returning
* Loan history
* Book availability
* Overdue books

The main challenge is to ensure that a book **cannot be issued when no physical copy is available**, while maintaining an accurate history of all borrowing and returning transactions.

---

## 🎯 Objectives

The main objectives of this project are:

1. Design a relational database for a library.
2. Identify entities, attributes, primary keys, and foreign keys.
3. Manage books and their physical copies.
4. Manage library members and librarians.
5. Record book borrowing and returning transactions.
6. Maintain complete loan history.
7. Identify overdue books.
8. Maintain accurate availability of physical copies.
9. Apply appropriate constraints for data integrity.

---

## 🗂️ Database Structure

The database consists of five main tables:

| Table       | Description                                 |
| ----------- | ------------------------------------------- |
| `Book`      | Stores information about books/editions     |
| `BookCopy`  | Stores individual physical copies of books  |
| `Member`    | Stores library member information           |
| `Librarian` | Stores librarian information                |
| `Loan`      | Stores borrowing and returning transactions |

---

## 🔑 Entities and Attributes

### 1. Book

The `Book` table stores common information about a book.

**Attributes:**

* `book_id` – Primary Key
* `isbn` – ISBN number
* `title` – Book title
* `author` – Author name
* `publisher` – Publisher
* `publication_year` – Year of publication
* `category` – Book category

---

### 2. BookCopy

A book can have multiple physical copies. Therefore, each physical copy is stored separately.

**Attributes:**

* `copy_id` – Primary Key
* `book_id` – Foreign Key referencing `Book`
* `available` – Indicates whether the copy is available
* `shelf` – Shelf location
* `section` – Library section

For example:

```text
Book: Clean Code

Copy 1 → Available
Copy 2 → Borrowed
Copy 3 → Available
```

This design allows availability to be tracked accurately for each physical copy.

---

### 3. Member

The `Member` table stores information about people who use the library.

**Attributes:**

* `member_id` – Primary Key
* `first_name`
* `last_name`
* `address`
* `phone`
* `email`
* `membership_date`

---

### 4. Librarian

The `Librarian` table stores information about library staff.

**Attributes:**

* `librarian_id` – Primary Key
* `name`
* `email`
* `hire_date`

---

### 5. Loan

The `Loan` table records every borrowing transaction.

**Attributes:**

* `loan_id` – Primary Key
* `copy_id` – Foreign Key
* `member_id` – Foreign Key
* `librarian_id` – Foreign Key
* `borrow_date`
* `due_date`
* `return_date`
* `status`

Possible loan statuses are:

```text
borrowed
returned
overdue
```

`return_date` can be `NULL` when the book has not yet been returned.

---

## 🔗 Relationships

The major relationships are:

```text
                 BOOK
                   |
                   | 1 : Many
                   ↓
               BOOKCOPY
                   |
                   | 1 : Many
                   ↓
                  LOAN
                /      \
               /        \
              ↓          ↓
           MEMBER     LIBRARIAN
```

### Relationships Explained

* One `Book` can have many `BookCopy` records.
* One `BookCopy` can appear in many `Loan` records over time.
* One `Member` can have many loans.
* Each `Loan` belongs to one member.
* Each `Loan` belongs to one physical book copy.
* A `Librarian` can be associated with multiple loans.

---

## 🛠️ Technologies Used

* **Database:** MySQL
* **Language:** SQL
* **Tool:** MySQL Workbench / MySQL-compatible SQL environment

---

## ⚙️ Main Features

### 1. Book Management

The system allows books to be stored with:

* ISBN
* Title
* Author
* Publisher
* Publication year
* Category

### 2. Multiple Copy Management

The system supports multiple physical copies of the same book.

Each copy has its own:

* Copy ID
* Availability status
* Shelf
* Section

### 3. Member Management

The system stores registered library members and their contact information.

### 4. Loan Management

The system records:

* Who borrowed the book
* Which physical copy was borrowed
* Borrow date
* Due date
* Return date
* Loan status
* Librarian handling the transaction

### 5. Overdue Management

Loans whose due date has passed and which have not been returned can be identified as overdue.

### 6. Loan History

Loan records are retained after books are returned so that the library has a complete borrowing history.

---

## 🔒 Database Constraints

Several constraints are used to maintain data integrity.

### Primary Keys

Each table has a unique identifier:

```text
Book       → book_id
BookCopy   → copy_id
Member     → member_id
Librarian  → librarian_id
Loan       → loan_id
```

### Foreign Keys

The relationships are enforced using foreign keys:

```text
BookCopy.book_id
        ↓
Book.book_id

Loan.copy_id
        ↓
BookCopy.copy_id

Loan.member_id
        ↓
Member.member_id

Loan.librarian_id
        ↓
Librarian.librarian_id
```

### Other Constraints

The database also uses:

* `NOT NULL`
* `UNIQUE`
* `CHECK`
* `DEFAULT`
* `AUTO_INCREMENT`

For example:

```sql
CHECK (due_date >= borrow_date)
```

ensures that the due date cannot occur before the borrowing date.

---

## 📅 Lending Period

The system uses a typical lending period of **14 days**.

The due date is calculated using:

```sql
DATE_ADD(CURDATE(), INTERVAL 14 DAY)
```

---

## 📖 Issue Book

When issuing a book, the system first searches for an available physical copy.

```sql
SELECT copy_id
FROM BookCopy
WHERE book_id = 1
AND available = TRUE
LIMIT 1
FOR UPDATE;
```

After an available copy is selected, a loan is created:

```sql
INSERT INTO Loan
(copy_id, member_id, librarian_id,
 borrow_date, due_date, status)
VALUES
(1, 1, 1,
 CURDATE(),
 DATE_ADD(CURDATE(), INTERVAL 14 DAY),
 'borrowed');
```

The copy is then marked unavailable:

```sql
UPDATE BookCopy
SET available = FALSE
WHERE copy_id = 1;
```

---

## 🔄 Return Book

When a book is returned:

```sql
UPDATE Loan
SET
    return_date = CURDATE(),
    status = 'returned'
WHERE loan_id = 1;
```

The physical copy is then made available again:

```sql
UPDATE BookCopy
SET available = TRUE
WHERE copy_id = (
    SELECT copy_id
    FROM Loan
    WHERE loan_id = 1
);
```

---

## ⏰ Overdue Books

Loans can be marked overdue using:

```sql
UPDATE Loan
SET status = 'overdue'
WHERE return_date IS NULL
AND due_date < CURDATE()
AND status = 'borrowed';
```

To find overdue books:

```sql
SELECT
    l.loan_id,
    b.title,
    bc.copy_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    l.borrow_date,
    l.due_date
FROM Loan l
JOIN BookCopy bc
    ON l.copy_id = bc.copy_id
JOIN Book b
    ON bc.book_id = b.book_id
JOIN Member m
    ON l.member_id = m.member_id
WHERE l.return_date IS NULL
AND l.due_date < CURDATE();
```

---

## 🔎 Sample Queries

### Find Available Books

```sql
SELECT
    b.book_id,
    b.title,
    b.author,
    bc.copy_id,
    bc.shelf,
    bc.section
FROM Book b
JOIN BookCopy bc
    ON b.book_id = bc.book_id
WHERE bc.available = TRUE;
```

### Find Member Borrowing History

```sql
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
```

### Find Currently Borrowed Books

```sql
SELECT
    l.loan_id,
    b.title,
    bc.copy_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
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
```

### Find Total and Available Copies

```sql
SELECT
    b.book_id,
    b.title,
    COUNT(bc.copy_id) AS total_copies,
    SUM(bc.available) AS available_copies
FROM Book b
LEFT JOIN BookCopy bc
    ON b.book_id = bc.book_id
GROUP BY b.book_id, b.title;
```

---

## 🧠 Main Challenge Solution

The main challenge is preventing a book from being issued when there are no available physical copies.

The solution is to separate:

```text
Book
```

from:

```text
BookCopy
```

Instead of storing availability only in `Book`, availability is stored in `BookCopy`.

For example:

```text
Book
------------------------------------------------
book_id = 1
title   = Database System Concepts

BookCopy
------------------------------------------------
copy_id = 1    available = TRUE
copy_id = 2    available = FALSE
copy_id = 3    available = TRUE
```

Therefore:

```text
Total copies     = 3
Available copies = 2
Borrowed copies  = 1
```

A new loan can only use a copy where:

```sql
available = TRUE
```

This prevents the system from issuing a book when every physical copy is already borrowed.

---

## 📊 Expected Database Flow

```text
                 ADD BOOK
                    |
                    ↓
              CREATE COPIES
                    |
                    ↓
             REGISTER MEMBER
                    |
                    ↓
             CHECK AVAILABILITY
                    |
          ┌─────────┴─────────┐
          ↓                   ↓
      AVAILABLE           NOT AVAILABLE
          |                   |
          ↓                   ↓
     ISSUE BOOK          REJECT ISSUE
          |
          ↓
      CREATE LOAN
          |
          ↓
   MARK COPY UNAVAILABLE
          |
          ↓
       BOOK RETURNED
          |
          ↓
   UPDATE LOAN RECORD
          |
          ↓
    MARK COPY AVAILABLE
```

---

## 🚀 How to Run

### Step 1: Open MySQL Workbench

Open MySQL Workbench or another MySQL-compatible SQL environment.

### Step 2: Create the Database

Run:

```sql
CREATE DATABASE LibraryLendingSystem;

USE LibraryLendingSystem;
```

### Step 3: Create Tables

Execute the `CREATE TABLE` statements in this order:

```text
1. Book
2. BookCopy
3. Member
4. Librarian
5. Loan
```

This order ensures that referenced tables exist before foreign keys are created.

### Step 4: Insert Sample Data

Insert:

* Books
* Book copies
* Members
* Librarians

### Step 5: Test Operations

Test:

* Issue a book
* Return a book
* Find overdue books
* Find available books
* View member borrowing history

---

## 📌 Conclusion

The Library Lending System provides a structured relational database for managing library operations.

The use of separate `Book` and `BookCopy` tables allows the system to accurately manage multiple physical copies of the same book. The `Loan` table maintains a complete history of borrowing and returning transactions.

The database uses primary keys, foreign keys, constraints, and transactions to maintain data integrity and ensure that unavailable copies cannot be issued.

---

## 👨‍💻 Project Summary

**Project:** Library Lending System

**Database:** MySQL

**Main Tables:**

```text
Book
BookCopy
Member
Librarian
Loan
```

**Core Operations:**

```text
Add Books
Manage Copies
Register Members
Issue Books
Return Books
Track Loan History
Find Overdue Books
Find Available Books
```
