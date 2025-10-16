Import guide for phpMyAdmin (PrivateTeacherDB)

1) Import order (respect foreign keys)
- Student.csv
- Subject.csv
- Lesson.csv
- Payment.csv

2) CSV options in phpMyAdmin
- Check: The first line of the file contains the table column names
- Columns must be in this exact order:
  - Student: StudentID, FirstName, LastName, Email, Grade, IsDeleted
  - Subject: SubjectID, SubjectName, HourlyRate, IsDeleted
  - Lesson: LessonID, LessonDate, ExpectedAmount, StartTime, DurationMinutes, StudentID, SubjectID, Category, IsDeleted
  - Payment: PaymentID, LessonID, PaymentDate, AmountPaid, IsDeleted
- Field separator: match your CSV (commonly ",")
- Quote: "
- Escape: \
- Date format: YYYY-MM-DD; Time format: HH:MM:SS

3) Common pitfalls and fixes
- If StartTime or Category appears empty after import: the CSV column order likely didn't match the table order. Re-import Lesson.csv ensuring the order above and the header checkbox is enabled.
- If you imported headers as data (rows where StudentID = 'StudentID', etc.), delete them:
  DELETE FROM Payment WHERE PaymentID = 'PaymentID';
  DELETE FROM Lesson  WHERE LessonID  = 'LessonID';
  DELETE FROM Subject WHERE SubjectID = 'SubjectID';
  DELETE FROM Student WHERE StudentID = 'StudentID';
- Foreign key errors when importing Payment: ensure all LessonIDs exist (import Lesson.csv first) and that you didn't import header rows.

4) Optional: clean rebuild
- To re-run schema and views safely, execute in SQL tab before CREATE statements:
  DROP VIEW IF EXISTS Lessons_On_Specific_Day,
                       Lessons_At_Specific_StartTime,
                       Lessons_Of_Specific_Subject,
                       Lessons_Of_Specific_Student,
                       Lessons_Of_Specific_Category,
                       Lessons_Without_Payment,
                       Lesson_Payment_Register,
                       Monthly_Revenue_Summary,
                       Payer_Financial_Situation,
                       Student_Lesson_Analysis;
  DROP TABLE IF EXISTS Payment, Lesson, Subject, Student;
  -- Then run CREATE TABLE statements and re-import in the order given.

5) Query examples (apply ORDER BY outside views)
- SELECT * FROM Lessons_Without_Payment ORDER BY LessonID DESC;
- SELECT * FROM Lesson_Payment_Register ORDER BY LessonID DESC, PaymentDate DESC;
- SELECT * FROM Payer_Financial_Situation ORDER BY Balance DESC;
