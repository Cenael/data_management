-- Tabella Supplier
CREATE TABLE Supplier (
    SupplierID int NOT NULL AUTO_INCREMENT,
    CompanyName varchar(100) NOT NULL,
    ContactInfo varchar(200),
    CONSTRAINT pkSupplierID PRIMARY KEY (SupplierID),
    CONSTRAINT ukSupplierCompanyName UNIQUE (CompanyName)
);
CREATE INDEX idxSupplier ON Supplier(SupplierID);

-- Tabella Employee
CREATE TABLE Employee (
    EmployeeID int NOT NULL AUTO_INCREMENT,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    CONSTRAINT pkEmployeeID PRIMARY KEY (EmployeeID)
);
CREATE INDEX idxEmployee ON Employee(EmployeeID);

-- Tabella Customer
CREATE TABLE Customer (
    CustomerID int NOT NULL AUTO_INCREMENT,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    Email varchar(100) NOT NULL,
    CONSTRAINT pkCustomerID PRIMARY KEY (CustomerID)
);
CREATE INDEX idxCustomer ON Customer(CustomerID);
-- Tabella Book
CREATE TABLE Book (
    BookID int NOT NULL AUTO_INCREMENT,
    Title varchar(200) NOT NULL,
    Author varchar(100) NOT NULL,
    Genre varchar(50),
    SupplierID int NOT NULL,
    CONSTRAINT pkBookID PRIMARY KEY (BookID),

)
    -- =============================
    -- VIEWS (compact, based on a single base view)
    -- Base view: Rental_Details (joins Rental -> BookCopy -> Book -> Customer -> Employee)
    -- Then a few small views/selects reuse this base view (active, overdue, history, summaries)
    -- =============================

    DROP VIEW IF EXISTS Rental_Details;
    CREATE VIEW Rental_Details AS
    SELECT
        R.RentalID,
        R.BookCopyID,
        BC.CopyNumber,
        BC.BookID,
        B.Title,
        B.Author,
        B.Genre,
        R.CustomerID,
        C.FirstName AS CustomerFirstName,
        C.LastName AS CustomerLastName,
        C.Email AS CustomerEmail,
        R.EmployeeID,
        E.FirstName AS EmployeeFirstName,
        E.LastName AS EmployeeLastName,
        R.StartDate,
        R.EndDate,
        R.Returned
    FROM Rental R
    JOIN BookCopy BC ON R.BookCopyID = BC.BookCopyID
    JOIN Book B ON BC.BookID = B.BookID
    JOIN Customer C ON R.CustomerID = C.CustomerID
    JOIN Employee E ON R.EmployeeID = E.EmployeeID;

    -- Active rentals (not returned)
    DROP VIEW IF EXISTS Rental_Active;
    CREATE VIEW Rental_Active AS
    SELECT * FROM Rental_Details WHERE Returned = 0;

    -- Overdue rentals (not returned and end date in the past)
    DROP VIEW IF EXISTS Rental_Overdue;
    CREATE VIEW Rental_Overdue AS
    SELECT *, CASE WHEN Returned = 0 AND EndDate < CURRENT_DATE() THEN 1 ELSE 0 END AS IsOverdue
    FROM Rental_Details
    WHERE Returned = 0 AND EndDate < CURRENT_DATE();

    -- Rental history (all rentals with full details)
    DROP VIEW IF EXISTS Rental_History;
    CREATE VIEW Rental_History AS
    SELECT * FROM Rental_Details;

    -- Example reports built on top of Rental_Details
    -- 1) Elenco noleggi attivi
    -- SELECT RentalID, Title, CopyNumber, CustomerFirstName, CustomerLastName, StartDate, EndDate
    -- FROM Rental_Active
    -- ORDER BY EndDate ASC;

    -- 2) Noleggi scaduti
    -- SELECT RentalID, Title, CopyNumber, CustomerFirstName, CustomerLastName, StartDate, EndDate
    -- FROM Rental_Overdue
    -- ORDER BY EndDate ASC;

    -- 3) Storico noleggi per cliente (conteggi)
    -- SELECT CustomerID, CustomerFirstName, CustomerLastName,
    --        COUNT(*) AS TotalRentals,
    --        SUM(CASE WHEN Returned = 0 THEN 1 ELSE 0 END) AS CurrentRentals
    -- FROM Rental_History
    -- GROUP BY CustomerID, CustomerFirstName, CustomerLastName
    -- ORDER BY TotalRentals DESC;

    -- 4) Noleggi mensili (conteggio per mese)
    -- SELECT DATE_FORMAT(StartDate, '%Y-%m') AS YearMonth, COUNT(*) AS RentalsCount
    -- FROM Rental_History
    -- GROUP BY YearMonth
    -- ORDER BY YearMonth DESC;

    -- 5) Disponibilità per libro (semplice query, non vista)
    -- SELECT B.BookID, B.Title,
    --        COUNT(BC.BookCopyID) AS TotalCopies,
    --        SUM(BC.BookStatus = 'Available') AS AvailableCopies,
    --        SUM(BC.BookStatus = 'Rented') AS RentedCopies
    -- FROM Book B
    -- LEFT JOIN BookCopy BC ON BC.BookID = B.BookID
    -- GROUP BY B.BookID, B.Title;

    COUNT(BC.BookCopyID) AS TotalCopies,
    SUM(CASE WHEN BC.BookStatus = 'Rented' THEN 1 ELSE 0 END) AS CopiesMarkedRented,
    SUM(CASE WHEN BC.BookStatus = 'Available' THEN 1 ELSE 0 END) AS CopiesMarkedAvailable
FROM Book B
LEFT JOIN BookCopy BC ON BC.BookID = B.BookID
GROUP BY B.BookID, B.Title, B.Author, B.Genre;

-- Monthly supplier payments (aggregated by PaymentDate)
DROP VIEW IF EXISTS Monthly_Supplier_Payments;
CREATE VIEW Monthly_Supplier_Payments AS
SELECT DATE_FORMAT(PaymentDate, '%Y-%m') AS YearMonth,
       ROUND(SUM(Amount), 2) AS TotalAmount,
       COUNT(*) AS PaymentsCount
FROM Payment
GROUP BY YearMonth
ORDER BY YearMonth DESC;

-- Supplier payment summary (total paid per supplier)
DROP VIEW IF EXISTS Supplier_Payment_Summary;
CREATE VIEW Supplier_Payment_Summary AS
SELECT S.SupplierID,
       S.CompanyName,
       ROUND(IFNULL(SUM(P.Amount),0), 2) AS TotalPaid,
       COUNT(P.PaymentID) AS PaymentCount
FROM Supplier S
LEFT JOIN Payment P ON P.SupplierID = S.SupplierID
GROUP BY S.SupplierID, S.CompanyName
ORDER BY TotalPaid DESC;

-- Customer rental summary (counts and date ranges)
DROP VIEW IF EXISTS Customer_Rental_Summary;
CREATE VIEW Customer_Rental_Summary AS
SELECT C.CustomerID,
       C.FirstName,
       C.LastName,
       C.Email,
       COUNT(R.RentalID) AS TotalRentals,
       SUM(CASE WHEN R.Returned = 0 THEN 1 ELSE 0 END) AS CurrentRentals,
       MIN(R.StartDate) AS FirstRentalDate,
       MAX(R.EndDate) AS LastRentalDate
FROM Customer C
LEFT JOIN Rental R ON R.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.FirstName, C.LastName, C.Email;

-- End of views
-- Produttivita dei dipendente: numero di noleggi gestiti in un periodo 
-- Profilo complessivo dei clienti con dati anagrafici e statistii sui noleggi 
-- Catalogo dei libri con stato di conservaazione raggruppato per stato di conservazione, autori piu noleggiatri in un dewterminato intervalli d tempo 
-- \frequenza di utilizzo delle singole copie di libro e uiltioma data di noleggio 
-- \controllo tra noleggi ee pagamenti per individuare eventuali incongruenze 

