import csv
from pathlib import Path
from datetime import date, datetime, timedelta
import random
from faker import Faker

fake = Faker("it_IT")

# Configuration
N_STUDENTS = 15
N_SUBJECTS = 3
N_LESSONS = 200
N_PAYMENTS = 150

RANDOM_SEED = 1234
Faker.seed(RANDOM_SEED)
random.seed(RANDOM_SEED)

# Dates for lessons: last 30 days
lesson_dates = [date.today() - timedelta(days=x) for x in range(30)]

# Pick 5 dates with more lessons ("hot dates")
hot_dates = random.sample(lesson_dates, 3)

# Allowed lesson start times
start_times = ["15:00:00", "16:30:00", "18:00:00"]

def make_output_folder(base="csv_out"):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    path = Path(base) / f"PrivateTeacherDB_{timestamp}"
    path.mkdir(parents=True, exist_ok=True)
    return path

def write_csv(filepath, fields, rows):
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)

def generate_students(n):
    grades = ["1A", "2B", "3C", "4D", "5E"]
    students = []
    for i in range(1, n + 1):
        students.append({
            "StudentID": i,
            "FirstName": fake.first_name(),
            "LastName": fake.last_name(),
            "Email": fake.email(),
            "Grade": random.choice(grades),
            "IsDeleted": 0
        })
    return students

def generate_subjects(n):
    subjects = []
    predefined_subjects = ["Math", "French", "History"]
    for i, subject_name in enumerate(predefined_subjects, start=1):
        subjects.append({
            "SubjectID": i,
            "SubjectName": subject_name,
            "HourlyRate": round(random.uniform(15, 50), 2),
            "IsDeleted": 0
        })
    return subjects

def generate_lessons(n, students, subjects):
    lessons = []
    lesson_id = 1

    # 60% lessons on hot dates, 40% on other dates
    hot_count = int(n * 0.6)
    other_count = n - hot_count

    tariff_categories = ["Standard", "Premium", "Economy"]

    for _ in range(hot_count):
        date_ = random.choice(hot_dates)
        start_time = random.choice(start_times)
        duration = 90  # Fixed duration of 90 minutes
        student = random.choice(students)
        subject = random.choice(subjects)
        category = random.choice(tariff_categories)
        expected_amount = round((duration / 60) * subject["HourlyRate"], 2)
        lessons.append({
            "LessonID": lesson_id,
            "ExpectedAmount": expected_amount,
            "LessonDate": date_.isoformat(),
            "StartTime": start_time,
            "DurationMinutes": duration,
            "StudentID": student["StudentID"],
            "SubjectID": subject["SubjectID"],
            "Category": category,
            "IsDeleted": 0
        })
        lesson_id += 1

    for _ in range(other_count):
        date_ = random.choice([d for d in lesson_dates if d not in hot_dates])
        start_time = random.choice(start_times)
        duration = 90  # Fixed duration of 90 minutes
        student = random.choice(students)
        subject = random.choice(subjects)
        category = random.choice(tariff_categories)
        expected_amount = round((duration / 60) * subject["HourlyRate"], 2)
        lessons.append({
            "LessonID": lesson_id,
            "ExpectedAmount": expected_amount,
            "LessonDate": date_.isoformat(),
            "StartTime": start_time,
            "DurationMinutes": duration,
            "StudentID": student["StudentID"],
            "SubjectID": subject["SubjectID"],
            "Category": category,
            "IsDeleted": 0
        })
        lesson_id += 1

    return lessons

def generate_payments(n, lessons):
    payments = []
    payment_id = 1

    # Randomly pick lessons to have payments
    lessons_paid = random.sample(lessons, k=min(n, len(lessons)))

    for lesson in lessons_paid:
        paid_fraction = random.choice([1.0, 0.5, 0.75])
        amount_paid = round(lesson["ExpectedAmount"] * paid_fraction, 2)
        payment_date = datetime.strptime(lesson["LessonDate"], "%Y-%m-%d").date() + timedelta(days=random.randint(0, 15))
        payments.append({
            "PaymentID": payment_id,
            "LessonID": lesson["LessonID"],
            "PaymentDate": payment_date.isoformat(),
            "AmountPaid": amount_paid,
            "IsDeleted": 0
        })
        payment_id += 1

    return payments

def main():
    output_folder = make_output_folder()

    students = generate_students(N_STUDENTS)
    subjects = generate_subjects(N_SUBJECTS)
    lessons = generate_lessons(N_LESSONS, students, subjects)
    payments = generate_payments(N_PAYMENTS, lessons)

    write_csv(output_folder / "Student.csv", ["StudentID", "FirstName", "LastName", "Email", "Grade", "IsDeleted"], students)
    write_csv(output_folder / "Subject.csv", ["SubjectID", "SubjectName", "HourlyRate", "IsDeleted"], subjects)
    # Match the exact column order of the SQL table: LessonID, LessonDate, ExpectedAmount, StartTime, DurationMinutes, StudentID, SubjectID, Category
    write_csv(
        output_folder / "Lesson.csv",
        [
            "LessonID",
            "LessonDate",
            "ExpectedAmount",
            "StartTime",
            "DurationMinutes",
            "StudentID",
            "SubjectID",
            "Category",
            "IsDeleted",
        ],
        lessons,
    )
    write_csv(output_folder / "Payment.csv", ["PaymentID", "LessonID", "PaymentDate", "AmountPaid", "IsDeleted"], payments)

    print(f"CSV files generated at: {output_folder.resolve()}")
    hot_strs = {d.isoformat() for d in hot_dates}
    print("Hot dates (more lessons):", sorted(hot_strs))

if __name__ == "__main__":
    main()
