CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Grade VARCHAR(20),
    IsDeleted TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE Subject (
    SubjectID INT PRIMARY KEY,
    SubjectName VARCHAR(50),
    HourlyRate DECIMAL(6,2),
    IsDeleted TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE Lesson (
    LessonID INT PRIMARY KEY,
    LessonDate DATE,
    ExpectedAmount DECIMAL(6,2),
    StartTime TIME,
    DurationMinutes INT,
    StudentID INT,
    SubjectID INT,
    Category VARCHAR(50),
    IsDeleted TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID)
);

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    LessonID INT,
    PaymentDate DATE,
    AmountPaid DECIMAL(6,2),
    IsDeleted TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (LessonID) REFERENCES Lesson(LessonID)
);

-- VIEWS 

-- BASE VIEW: ALL LESSONS WITH DETAILS (filter by date in outer SELECT)
DROP VIEW IF EXISTS Lesson_Details;
CREATE VIEW Lesson_Details AS
-- Taking lesson, student, and subject details
SELECT 
    L.LessonID,
    L.LessonDate,
    L.StartTime,
    L.DurationMinutes,
    ROUND(L.ExpectedAmount, 2) AS ExpectedAmount,
    L.Category,
    ST.StudentID,
    ST.FirstName,
    ST.LastName,
    SB.SubjectID,
    SB.SubjectName AS SubjectName,
    SB.HourlyRate
FROM Lesson L
-- Joining tables to get student and subject info
JOIN Student ST ON L.StudentID = ST.StudentID 
JOIN Subject SB ON L.SubjectID = SB.SubjectID
WHERE L.IsDeleted = 0 AND ST.IsDeleted = 0 AND SB.IsDeleted = 0;

-- BASE VIEW: LESSON + PAYMENT DETAILS (reuse in payment-related reports)
DROP VIEW IF EXISTS Lesson_Payment_Details;
CREATE VIEW Lesson_Payment_Details AS
SELECT 
    LD.LessonID,
    LD.LessonDate,
    LD.StartTime,
    LD.DurationMinutes,
    LD.ExpectedAmount,
    LD.Category,
    LD.StudentID,
    LD.FirstName,
    LD.LastName,
    LD.SubjectID,
    LD.SubjectName,
    LD.HourlyRate,
    P.PaymentID,
    P.PaymentDate,
    ROUND(P.AmountPaid, 2) AS AmountPaid,
    CASE 
        WHEN P.PaymentID IS NULL THEN 'Not Paid'
        WHEN P.AmountPaid < LD.ExpectedAmount THEN 'Partially Paid'
        WHEN P.AmountPaid = LD.ExpectedAmount THEN 'Paid'
        ELSE 'Overpaid'
    END AS PaymentStatus
FROM Lesson_Details LD
LEFT JOIN Payment P ON LD.LessonID = P.LessonID AND P.IsDeleted = 0;

-- Lezioni senza pagamento (con expected amount)
SELECT LessonID, LessonDate, StartTime, ExpectedAmount,
       FirstName, LastName, SubjectName, PaymentStatus
FROM Lesson_Payment_Details
WHERE PaymentID IS NULL
ORDER BY LessonDate DESC, StartTime DESC, LessonID DESC;

-- Registro lezioni-pagamenti (chi ha pagato ciascuna lezione)
SELECT LessonID, LessonDate, FirstName, LastName, SubjectName,
       ExpectedAmount, AmountPaid, PaymentStatus, PaymentDate
FROM Lesson_Payment_Details
ORDER BY LessonID DESC, PaymentDate DESC;

-- Fatturato mensile (aggregato per mese su PaymentDate)

SELECT DATE_FORMAT(PaymentDate, '%Y-%m') AS YearMonth,
       ROUND(SUM(AmountPaid), 2) AS TotalRevenue,
       COUNT(DISTINCT LessonID)  AS LessonsPaid
FROM Lesson_Payment_Details
WHERE AmountPaid IS NOT NULL
GROUP BY YearMonth
ORDER BY YearMonth DESC;

-- Situazione economica per pagante (totale atteso, totale pagato, saldo)

SELECT E.StudentID, E.FirstName, E.LastName,
       ROUND(IFNULL(E.TotalExpected, 0.00), 2) AS TotalExpected,
       ROUND(IFNULL(P.TotalPaid, 0.00), 2)     AS TotalPaid,
       ROUND(IFNULL(E.TotalExpected, 0.00) - IFNULL(P.TotalPaid, 0.00), 2) AS Balance
FROM (
  SELECT StudentID, FirstName, LastName, SUM(ExpectedAmount) AS TotalExpected
  FROM Lesson_Details
  GROUP BY StudentID, FirstName, LastName
) E
LEFT JOIN (
  SELECT StudentID, SUM(AmountPaid) AS TotalPaid
  FROM Lesson_Payment_Details
  WHERE AmountPaid IS NOT NULL
  GROUP BY StudentID
) P ON P.StudentID = E.StudentID
ORDER BY Balance DESC;

-- Analisi studente per periodo

SET @from = '2025-09-01';
SET @to   = '2025-10-14';

SELECT 
  LD.StudentID, LD.FirstName, LD.LastName,
  COUNT(LD.LessonID) AS TotalLessons,
  ROUND(SUM(LD.DurationMinutes) / 60.0, 2) AS TotalHours,
  (
    SELECT LD2.SubjectName
    FROM Lesson_Details LD2
    WHERE LD2.StudentID = LD.StudentID
      AND LD2.LessonDate BETWEEN @from AND @to
    GROUP BY LD2.SubjectName
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) AS MostFrequentSubject, 
  (
    SELECT LD3.StartTime
    FROM Lesson_Details LD3
    WHERE LD3.StudentID = LD.StudentID
      AND LD3.LessonDate BETWEEN @from AND @to
    GROUP BY LD3.StartTime
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) AS MostCommonStartTime,
  MAX(LD.LessonDate) AS LastLessonDate
FROM Lesson_Details LD
WHERE LD.LessonDate BETWEEN @from AND @to
GROUP BY LD.StudentID, LD.FirstName, LD.LastName
ORDER BY LD.StudentID;