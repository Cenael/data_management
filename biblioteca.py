"""
make_csv_biblioteca_auto.py
----------------------------
Generatore CSV *zero-config* per lo schema BibliotecaDB.
- Nessun parametro esterno: esegui `python make_csv_biblioteca_auto.py`.
- Crea una cartella di output timestampata dentro `csv_out/`.
- Rispetta PK / FK / UK e coerenze (dipendenti attivi, libri disponibili).
Requisiti: pip install Faker python-dateutil
"""
# Import delle librerie necessarie
import csv
from pathlib import Path
import random
from datetime import date, datetime, timedelta
from dateutil.relativedelta import relativedelta
from faker import Faker
from itertools import count

fake = Faker("it_IT")

# Parametri di configurazione per la quantità di dati da generare
N_SUPPLIERS = 10           # Numero di fornitori
N_EMPLOYEES = 20           # Numero di dipendenti
N_CUSTOMERS = 150          # Numero di clienti
N_BOOKS = 300              # Numero di libri
N_COPIES_PER_BOOK = 3      # Numero medio di copie per libro
N_PAYMENTS = 50            # Numero di pagamenti
N_RENTALS = 400            # Numero di noleggi

# Seed per la generazione casuale (riproducibilità)
RANDOM_SEED = 42
RENTALS_START = date.today() - relativedelta(months=12)
RENTALS_END = date.today() - timedelta(days=1)

# Inizializzazione Faker e random
random.seed(RANDOM_SEED)
Faker.seed(RANDOM_SEED)
random.seed(RANDOM_SEED)
Faker.seed(RANDOM_SEED)


# Crea una cartella di output con timestamp
def ts_outdir(base="csv_out"):
    t = datetime.now().strftime("%Y%m%d_%H%M%S")
    p = Path(base) / f"BibliotecaDB_{t}"
    p.mkdir(parents=True, exist_ok=True)
    return p


# Restituisce una data casuale tra start e end
def daterange(start: date, end: date) -> date:
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))


# Scrive una lista di dizionari su file CSV
def write_csv(path, fieldnames, rows):
    # Normalize values: dates -> ISO string, datetimes -> ISO, bool -> TRUE/FALSE
    def normalize_value(v):
        if isinstance(v, (date, datetime)):
            return v.isoformat()
        if isinstance(v, bool):
            return "TRUE" if v else "FALSE"
        return v

    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in rows:
            row = {k: normalize_value(r.get(k)) for k in fieldnames}
            writer.writerow(row)


# Genera fornitori
def gen_suppliers(n):
    suppliers = []
    for i in range(1, n + 1):
        suppliers.append({
            "SupplierID": i,
            "CompanyName": fake.company()[:100],
            "ContactInfo": f"{fake.email()}, {fake.phone_number()}"[:200]
        })
    return suppliers


# Genera dipendenti
def gen_employees(n):
    return [{
        "EmployeeID": i,
        "FirstName": fake.first_name()[:50],
        "LastName": fake.last_name()[:50]
    } for i in range(1, n + 1)]


# Genera clienti
def gen_customers(n):
    return [{
        "CustomerID": i,
        "FirstName": fake.first_name()[:50],
        "LastName": fake.last_name()[:50],
        "Email": fake.email()[:100]
    } for i in range(1, n + 1)]


# Genera libri
def gen_books(n, suppliers):
    books = []
    supplier_ids = [s["SupplierID"] for s in suppliers]
    for i in range(1, n + 1):
        books.append({
            "BookID": i,
            "Title": fake.sentence(nb_words=4)[:200],
            "Author": f"{fake.first_name()} {fake.last_name()}"[:100],
            "Genre": random.choice(["Romanzo", "Giallo", "Fantasy", "Sci-Fi", "Storia"]),
            "SupplierID": random.choice(supplier_ids)
        })
    return books


# Genera copie dei libri
def gen_book_copies(books):
    copies = []
    copy_id = count(1)
    for book in books:
        # generate between 1 and N_COPIES_PER_BOOK copies per book
        copies_count = random.randint(1, N_COPIES_PER_BOOK)
        for copy_num in range(1, copies_count + 1):
            copies.append({
                "BookCopyID": next(copy_id),
                "BookID": book["BookID"],
                "CopyNumber": copy_num,
                "BookStatus": random.choice(["Available", "Rented", "Maintenance"]),
                "BookCondition": random.choice(["Excellent", "Good", "Fair", "Poor"])
            })
    return copies


# Genera pagamenti
def gen_payments(n, suppliers, employees):
    payments = []
    supplier_ids = [s["SupplierID"] for s in suppliers]
    employee_ids = [e["EmployeeID"] for e in employees]
    for i in range(1, n + 1):
        payments.append({
            "PaymentID": i,
            "SupplierID": random.choice(supplier_ids),
            "EmployeeID": random.choice(employee_ids),
            "Amount": round(random.uniform(100, 1000), 2),
            "PaymentDate": daterange(RENTALS_START, RENTALS_END)
        })
    return payments


# Genera noleggi
def gen_rentals(n, book_copies, customers, employees):
    rentals = []
    customer_ids = [c["CustomerID"] for c in customers]
    employee_ids = [e["EmployeeID"] for e in employees]
    available_copies = [bc for bc in book_copies if bc["BookStatus"] == "Available"]
    max_rentals = min(n, len(available_copies))
    for i in range(1, max_rentals + 1):
        start = daterange(RENTALS_START, RENTALS_END)
        # ensure end date is on or after start date (max rental 60 days)
        latest_end = min(RENTALS_END, start + timedelta(days=60))
        end = daterange(start, latest_end) if latest_end >= start else start
        returned = random.choice([True, False])

        # mark the chosen copy as rented (update original book_copies list)
        book_copy = available_copies[i - 1]
        book_copy_id = book_copy["BookCopyID"]
        # update status in the master list as well
        for bc in book_copies:
            if bc["BookCopyID"] == book_copy_id:
                bc["BookStatus"] = "Rented"
                break

        rentals.append({
            "RentalID": i,
            "BookCopyID": book_copy_id,
            "CustomerID": random.choice(customer_ids),
            "EmployeeID": random.choice(employee_ids),
            "StartDate": start,
            "EndDate": end,
            "Returned": returned
        })
    return rentals


# Funzione principale
def main():
    outdir = ts_outdir()

    suppliers = gen_suppliers(N_SUPPLIERS)
    employees = gen_employees(N_EMPLOYEES)
    customers = gen_customers(N_CUSTOMERS)
    books = gen_books(N_BOOKS, suppliers)
    book_copies = gen_book_copies(books)
    payments = gen_payments(N_PAYMENTS, suppliers, employees)
    rentals = gen_rentals(N_RENTALS, book_copies, customers, employees)

    # Scrittura dei file CSV
    write_csv(outdir / "Supplier.csv", ["SupplierID", "CompanyName", "ContactInfo"], suppliers)
    write_csv(outdir / "Employee.csv", ["EmployeeID", "FirstName", "LastName"], employees)
    write_csv(outdir / "Customer.csv", ["CustomerID", "FirstName", "LastName", "Email"], customers)
    write_csv(outdir / "Book.csv", ["BookID", "Title", "Author", "Genre", "SupplierID"], books)
    write_csv(outdir / "BookCopy.csv", ["BookCopyID", "BookID", "CopyNumber", "BookStatus", "BookCondition"], book_copies)
    write_csv(outdir / "Payment.csv", ["PaymentID", "SupplierID", "EmployeeID", "Amount", "PaymentDate"], payments)
    write_csv(outdir / "Rental.csv", ["RentalID", "BookCopyID", "CustomerID", "EmployeeID", "StartDate", "EndDate", "Returned"], rentals)

    print(f"✅ CSV generati in: {outdir.resolve()}")


if __name__ == "__main__":
    main()