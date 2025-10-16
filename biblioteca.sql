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
    CONSTRAINT fkBookSupplierID FOREIGN KEY (SupplierID) REFERENCES Supplier (SupplierID)
);
CREATE INDEX idxBook ON Book(BookID);
CREATE INDEX idxBookSupplier ON Book(SupplierID);

-- Tabella BookCopy
CREATE TABLE BookCopy (
    BookCopyID int NOT NULL AUTO_INCREMENT,
    BookID int NOT NULL,
    CopyNumber int NOT NULL,
    BookStatus varchar(20) NOT NULL,
    BookCondition varchar(20),
    CONSTRAINT pkBookCopyID PRIMARY KEY (BookCopyID),
    CONSTRAINT fkBookCopyBookID FOREIGN KEY (BookID) REFERENCES Book (BookID)
);
CREATE INDEX idxBookCopy ON BookCopy(BookCopyID);

-- Tabella Payment
CREATE TABLE Payment (
    PaymentID int NOT NULL AUTO_INCREMENT,
    SupplierID int NOT NULL,
    EmployeeID int NOT NULL,
    Amount decimal(10,2) NOT NULL,
    PaymentDate date NOT NULL,
    CONSTRAINT pkPaymentID PRIMARY KEY (PaymentID),
    CONSTRAINT fkPaymentSupplierID FOREIGN KEY (SupplierID) REFERENCES Supplier (SupplierID),
    CONSTRAINT fkPaymentEmployeeID FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
);
CREATE INDEX idxPayment ON Payment(PaymentID);

-- Tabella Rental
CREATE TABLE Rental (
    RentalID int NOT NULL AUTO_INCREMENT,
    BookCopyID int NOT NULL,
    CustomerID int NOT NULL,
    EmployeeID int NOT NULL,
    StartDate date NOT NULL,
    EndDate date NOT NULL,
    Returned boolean NOT NULL,
    CONSTRAINT pkRentalID PRIMARY KEY (RentalID),
    CONSTRAINT fkRentalBookCopyID FOREIGN KEY (BookCopyID) REFERENCES BookCopy (BookCopyID),
    CONSTRAINT fkRentalCustomerID FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID),
    CONSTRAINT fkRentalEmployeeID FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
);
CREATE INDEX idxRental ON Rental(RentalID);