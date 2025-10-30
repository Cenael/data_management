import csv
from pathlib import Path
from datetime import date, datetime, timedelta
import random
from faker import Faker

fake = Faker("it_IT")

# Configuration
N_SEDI = 3
N_AULE = 8
N_CORSI = 4
N_DOCENTI = 8
N_TUTOR = 4
N_STUDENTI = 60
N_UNITA = 12
N_CORSO_UF = 18
N_LEZIONI = 300
N_ISCRIZIONI = N_STUDENTI
N_TUTOR_CORSO = 6
N_VALUTAZIONI = 450

RANDOM_SEED = 1234
Faker.seed(RANDOM_SEED)
random.seed(RANDOM_SEED)

# --- Helpers ---
def make_output_folder(base="csv_out"):
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    p = Path(base) / f"attivita_didattiche_{ts}"
    p.mkdir(parents=True, exist_ok=True)
    return p

def write_csv(path, fields, rows):
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)

# --- Generators ---
def gen_sedi(n):
    rows = []
    for i in range(1, n+1):
        rows.append({
            "sede_id": i,
            "nome": f"{fake.city()} Campus",
            "indirizzo": fake.street_address(),
            "citta": fake.city(),
            "cap": fake.postcode(),
            "is_deleted": 0
        })
    return rows

def gen_aule(n, sedi):
    rows = []
    for i in range(1, n+1):
        sede = random.choice(sedi)
        rows.append({
            "aula_id": i,
            "nome": f"Aula {chr(64 + (i%26 or 26))}{i}",
            "capienza": random.randint(15, 50),
            "sede_id": sede["sede_id"],
            "is_deleted": 0
        })
    return rows

def gen_corsi(n, sedi):
    modalities = ["presenza", "online", "blended"]
    corsi_names = ["Full-Stack Developer", "Cybersecurity", "Data Science", "UX/UI Design"]
    rows = []
    for i in range(1, n+1):
        sede = random.choice(sedi)
        rows.append({
            "corso_id": i,
            "titolo": corsi_names[i-1],
            "descrizione": f"Percorso formativo avanzato in {corsi_names[i-1]}",
            "ore_totali": random.choice([300, 600, 900]),
            "modalita": random.choice(modalities),
            "sede_id": sede["sede_id"],
            "attivo": 1,
            "is_deleted": 0
        })
    return rows

def gen_docenti(n):
    rows = []
    for i in range(1, n+1):
        rows.append({
            "docente_id": i,
            "nome": fake.first_name(),
            "cognome": fake.last_name(),
            "codice_fiscale": fake.bothify(text="??????????????").upper()[:16],
            "email": fake.email(),
            "telefono": fake.phone_number(),
            "is_deleted": 0
        })
    return rows

def gen_tutors(n):
    rows = []
    for i in range(1, n+1):
        rows.append({
            "tutor_id": i,
            "nome": fake.first_name(),
            "cognome": fake.last_name(),
            "email": fake.email(),
            "telefono": fake.phone_number(),
            "is_deleted": 0
        })
    return rows

def gen_studenti(n):
    rows = []
    for i in range(1, n+1):
        # 85% tra 18 e 28 anni, 15% tra 31 e 45 anni
        if random.random() < 0.85:
            age = random.randint(18, 28)
        else:
            age = random.randint(31, 45)
        dob = date.today() - timedelta(days=age*365 + random.randint(0, 365))
        rows.append({
            "studente_id": i,
            "nome": fake.first_name(),
            "cognome": fake.last_name(),
            "data_nascita": dob.isoformat(),
            "codice_fiscale": fake.bothify(text="??????????????").upper()[:16],
            "email": fake.email(),
            "indirizzo": fake.street_address(),
            "citta": fake.city(),
            "is_deleted": 0
        })
    return rows

def gen_unita(n):
    uf_topics = ["Frontend", "Backend", "Networking", "Cybersecurity", "UX", "Data Analysis", "Machine Learning", "Design Thinking"]
    rows = []
    for i in range(1, n+1):
        topic = random.choice(uf_topics)
        rows.append({
            "unita_formativa_id": i,
            "titolo": f"Modulo: {topic} Avanzato",
            "descrizione": f"Approfondimento pratico su {topic}",
            "ore": random.choice([20,40,60,80]),
            "is_deleted": 0
        })
    return rows

def gen_corso_uf(n, corsi, unita, docenti):
    pairs = set()
    rows = []
    cid = 1
    attempts = 0
    while len(rows) < n and attempts < n*10:
        attempts += 1
        corso = random.choice(corsi)
        uf = random.choice(unita)
        key = (corso["corso_id"], uf["unita_formativa_id"])
        if key in pairs:
            continue
        pairs.add(key)
        rows.append({
            "corso_uf_id": cid,
            "corso_id": corso["corso_id"],
            "unita_formativa_id": uf["unita_formativa_id"],
            "docente_id": random.choice(docenti)["docente_id"],
            "attivo": 1,
            "ore_assegnate": uf["ore"],
            "is_deleted": 0
        })
        cid += 1
    return rows

def gen_lezioni(n, corso_uf_list, docenti, aule):
    rows = []
    lesson_id = 1
    start_date = date.today() - timedelta(days=365)
    for _ in range(n):
        corso_uf = random.choice(corso_uf_list)
        docente = random.choice(docenti)
        aula = random.choice(aule)
        d = start_date + timedelta(days=random.randint(0, 365))
        start_dt = datetime.combine(d, datetime.min.time()) + timedelta(hours=random.choice([9,11,14,16]))
        duration = random.choice([60,90,120])
        end_dt = start_dt + timedelta(minutes=duration)
        rows.append({
            "lezione_id": lesson_id,
            "corso_uf_id": corso_uf["corso_uf_id"],
            "docente_id": docente["docente_id"],
            "aula_id": aula["aula_id"],
            "data_ora_inizio": start_dt.isoformat(sep=' '),
            "data_ora_fine": end_dt.isoformat(sep=' '),
            "is_deleted": 0
        })
        lesson_id += 1
    return rows

def gen_iscrizioni(students, corsi):
    rows = []
    i = 1
    for s in students:
        corso = random.choice(corsi)
        rows.append({
            "iscrizione_id": i,
            "studente_id": s["studente_id"],
            "corso_id": corso["corso_id"],
            "data_iscrizione": (date.today() - timedelta(days=random.randint(0,900))).isoformat(),
            "stato": random.choice(["attivo","completato","ritirato"]),
            "is_deleted": 0
        })
        i += 1
    return rows

def gen_tutor_corso(n, tutors, corsi):
    rows = []
    seen = set()
    i = 1
    attempts = 0
    while len(rows) < n and attempts < n*10:
        attempts += 1
        t = random.choice(tutors)
        c = random.choice(corsi)
        key = (t["tutor_id"], c["corso_id"])
        if key in seen:
            continue
        seen.add(key)
        rows.append({
            "tutor_corso_id": i,
            "tutor_id": t["tutor_id"],
            "corso_id": c["corso_id"],
            "data_inizio": (date.today() - timedelta(days=random.randint(0,900))).isoformat(),
            "is_deleted": 0
        })
        i += 1
    return rows

def gen_valutazioni(n, students, corso_uf_list, docenti):
    rows = []
    i = 1
    for _ in range(n):
        corso_uf = random.choice(corso_uf_list)
        stud = random.choice(students)
        docente = random.choice(docenti)
        voto = round(random.uniform(0, 30), 2)
        if voto >= 18:
            esito = "superato"
        elif voto == 0:
            esito = "in corso"
        else:
            esito = "non superato"
        rows.append({
            "valutazione_id": i,
            "studente_id": stud["studente_id"],
            "unita_formativa_id": corso_uf["unita_formativa_id"],
            "corso_id": corso_uf["corso_id"],
            "corso_uf_id": corso_uf["corso_uf_id"],
            "docente_id": docente["docente_id"],
            "data_valutazione": (date.today() - timedelta(days=random.randint(0,720))).isoformat(),
            "voto": voto,
            "esito": esito,
            "is_deleted": 0
        })
        i += 1
    return rows

# --- Main ---
def main():
    out = make_output_folder("csv_out")
    sedi = gen_sedi(N_SEDI)
    aule = gen_aule(N_AULE, sedi)
    corsi = gen_corsi(N_CORSI, sedi)
    docenti = gen_docenti(N_DOCENTI)
    tutors = gen_tutors(N_TUTOR)
    studenti = gen_studenti(N_STUDENTI)
    unita = gen_unita(N_UNITA)
    corso_uf = gen_corso_uf(N_CORSO_UF, corsi, unita, docenti)
    lezioni = gen_lezioni(N_LEZIONI, corso_uf, docenti, aule)
    iscrizioni = gen_iscrizioni(studenti, corsi)
    tutor_corsi = gen_tutor_corso(N_TUTOR_CORSO, tutors, corsi)
    valutazioni = gen_valutazioni(N_VALUTAZIONI, studenti, corso_uf, docenti)

    write_csv(out/"sede.csv", ["sede_id","nome","indirizzo","citta","cap","is_deleted"], sedi)
    write_csv(out/"aula.csv", ["aula_id","nome","capienza","sede_id","is_deleted"], aule)
    write_csv(out/"corso.csv", ["corso_id","titolo","descrizione","ore_totali","modalita","sede_id","attivo","is_deleted"], corsi)
    write_csv(out/"docente.csv", ["docente_id","nome","cognome","codice_fiscale","email","telefono","is_deleted"], docenti)
    write_csv(out/"tutor.csv", ["tutor_id","nome","cognome","email","telefono","is_deleted"], tutors)
    write_csv(out/"studente.csv", ["studente_id","nome","cognome","data_nascita","codice_fiscale","email","indirizzo","citta","is_deleted"], studenti)
    write_csv(out/"unita_formativa.csv", ["unita_formativa_id","titolo","descrizione","ore","is_deleted"], unita)
    write_csv(out/"corso_uf.csv", ["corso_uf_id","corso_id","unita_formativa_id","docente_id","attivo","ore_assegnate","is_deleted"], corso_uf)
    write_csv(out/"lezione.csv", ["lezione_id","corso_uf_id","docente_id","aula_id","data_ora_inizio","data_ora_fine","is_deleted"], lezioni)
    write_csv(out/"iscrizione.csv", ["iscrizione_id","studente_id","corso_id","data_iscrizione","stato","is_deleted"], iscrizioni)
    write_csv(out/"tutor_corso.csv", ["tutor_corso_id","tutor_id","corso_id","data_inizio","is_deleted"], tutor_corsi)
    write_csv(out/"valutazione.csv", ["valutazione_id","studente_id","unita_formativa_id","corso_id","corso_uf_id","docente_id","data_valutazione","voto","esito","is_deleted"], valutazioni)

if __name__ == "__main__":
    main()
