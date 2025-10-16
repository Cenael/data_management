SET FOREIGN_KEY_CHECKS = 0; -- Disabilita i vincoli di chiave esterna

USE `private_teacher-db`; -- Sostituisci 'nome_database' con il nome del tuo database

DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Grade VARCHAR(20) -- ad esempio livello scolastico o altro
);

DROP TABLE IF EXISTS Subject;

CREATE TABLE Subject (
    SubjectID INT PRIMARY KEY,
    Name VARCHAR(50),
    HourlyRate DECIMAL(6,2)
);

DROP TABLE IF EXISTS Lesson;

CREATE TABLE Lesson (
    LessonID INT PRIMARY KEY,
    LessonDate DATE,
    ExpectedAmount DECIMAL(6,2),
    StartTime TIME,
    DurationMinutes INT,
    StudentID INT,
    SubjectID INT,
    Category DECIMAL(6,2),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID)
);

DROP TABLE IF EXISTS Payment;

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    LessonID INT,
    PaymentDate DATE,
    AmountPaid DECIMAL(6,2),
    FOREIGN KEY (LessonID) REFERENCES Lesson(LessonID)
);

-- orari dell'inizio lezione: 15.00, 16.30, 18.00 

-- Views per ottimizzare le query

DROP VIEW IF EXISTS Lessons_On_Specific_Day;
CREATE VIEW Lessons_On_Specific_Day AS
SELECT *
FROM Lesson
WHERE LessonDate = '2025-10-14';

DROP VIEW IF EXISTS Lessons_At_Specific_StartTime;
CREATE VIEW Lessons_At_Specific_StartTime AS
SELECT *
FROM Lesson
WHERE StartTime = '15:00:00';

DROP VIEW IF EXISTS Lessons_Of_Specific_Subject;
CREATE VIEW Lessons_Of_Specific_Subject AS
SELECT * FROM Lesson
WHERE SubjectID = '1';

DROP VIEW IF EXISTS Lessons_Of_Specific_Student;
CREATE VIEW Lessons_Of_Specific_Student AS
SELECT * FROM Lesson
WHERE StudentID = '1';

DROP VIEW IF EXISTS Lessons_Of_Specific_Category;
CREATE VIEW Lessons_Of_Specific_Category AS
SELECT * FROM Lesson
WHERE Category = 'Standard';

DROP VIEW IF EXISTS Lessons_Without_Payment;
CREATE VIEW Lessons_Without_Payment AS
SELECT Lesson.LessonID, Lesson.ExpectedAmount FROM Lesson
WHERE Lesson.LessonID NOT IN (SELECT LessonID FROM Payment);

SET FOREIGN_KEY_CHECKS = 1; -- Riabilita i vincoli di chiave esterna
