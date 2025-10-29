-- ============================================
-- DATABASE: Sistema Gestione Attività Didattiche
-- Data: 2025-10-27
-- ============================================

DROP DATABASE IF EXISTS AttivitaDidatticheDB;
CREATE DATABASE AttivitaDidatticheDB;
USE AttivitaDidatticheDB;

-- ============================================
-- TABELLA: SEDE
-- ============================================
CREATE TABLE Sede (
    CodiceSede INT AUTO_INCREMENT PRIMARY KEY,
    NomeSede VARCHAR(100) NOT NULL,
    Indirizzo VARCHAR(200),
    Citta VARCHAR(100),
    CAP VARCHAR(10),
    Capienza INT,
    TipoSede ENUM('Fisica', 'Online') DEFAULT 'Fisica',
    CONSTRAINT unique_sede UNIQUE (NomeSede, Indirizzo)
);

-- ============================================
-- TABELLA: AULA
-- ============================================
CREATE TABLE Aula (
    CodiceAula INT AUTO_INCREMENT PRIMARY KEY,
    NomeAula VARCHAR(50) NOT NULL,
    Capienza INT,
    Attrezzature TEXT,
    CodiceSede INT NOT NULL,
    FOREIGN KEY (CodiceSede) REFERENCES Sede(CodiceSede)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT unique_aula_sede UNIQUE (NomeAula, CodiceSede)
);

-- ============================================
-- TABELLA: STUDENTE
-- ============================================
CREATE TABLE Studente (
    CodiceStudente INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(50) NOT NULL,
    Cognome VARCHAR(50) NOT NULL,
    DataNascita DATE,
    Email VARCHAR(100) UNIQUE,
    Telefono VARCHAR(20),
    Indirizzo VARCHAR(200),
    Citta VARCHAR(100),
    CAP VARCHAR(10),
    INDEX idx_nome_cognome (Cognome, Nome)
);

-- ============================================
-- TABELLA: DOCENTE
-- ============================================
CREATE TABLE Docente (
    CodiceDocente INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(50) NOT NULL,
    Cognome VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefono VARCHAR(20),
    Specializzazione VARCHAR(200),
    CV TEXT,
    INDEX idx_nome_cognome (Cognome, Nome)
);

-- ============================================
-- TABELLA: TUTOR
-- ============================================
CREATE TABLE Tutor (
    CodiceTutor INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(50) NOT NULL,
    Cognome VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefono VARCHAR(20),
    AreaCompetenza VARCHAR(200),
    INDEX idx_nome_cognome (Cognome, Nome)
);

-- ============================================
-- TABELLA: CORSO
-- ============================================
CREATE TABLE Corso (
    CodiceCorso INT AUTO_INCREMENT PRIMARY KEY,
    NomeCorso VARCHAR(100) NOT NULL,
    Descrizione TEXT,
    DataInizio DATE,
    DataFine DATE,
    NumeroOre INT,
    Livello ENUM('Base', 'Intermedio', 'Avanzato') DEFAULT 'Base',
    CONSTRAINT check_date_corso CHECK (DataFine >= DataInizio)
);

-- ============================================
-- TABELLA: UNITA_FORMATIVA
-- ============================================
CREATE TABLE UnitaFormativa (
    CodiceUF INT AUTO_INCREMENT PRIMARY KEY,
    Titolo VARCHAR(100) NOT NULL,
    Descrizione TEXT,
    NumeroOre INT,
    Ordine INT,
    CodicCorso INT NOT NULL,
    FOREIGN KEY (CodicCorso) REFERENCES Corso(CodiceCorso)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT unique_ordine_corso UNIQUE (CodicCorso, Ordine)
);

-- ============================================
-- TABELLA: ISCRIZIONE (Relazione Studente-Corso)
-- ============================================
CREATE TABLE Iscrizione (
    CodiceIscrizione INT AUTO_INCREMENT PRIMARY KEY,
    CodiceStudente INT NOT NULL,
    CodiceCorso INT NOT NULL,
    DataIscrizione DATE NOT NULL,
    Stato ENUM('Attivo', 'Completato', 'Ritirato') DEFAULT 'Attivo',
    ValutazioneFinale DECIMAL(4,2),
    Note TEXT,
    FOREIGN KEY (CodiceStudente) REFERENCES Studente(CodiceStudente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CodiceCorso) REFERENCES Corso(CodiceCorso)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT unique_studente_corso UNIQUE (CodiceStudente, CodiceCorso),
    CONSTRAINT check_valutazione CHECK (ValutazioneFinale >= 0 AND ValutazioneFinale <= 100)
);

-- ============================================
-- TABELLA: LEZIONE
-- ============================================
CREATE TABLE Lezione (
    CodiceLezione INT AUTO_INCREMENT PRIMARY KEY,
    CodiceUF INT NOT NULL,
    CodiceDocente INT NOT NULL,
    CodiceAula INT,
    DataOra DATETIME NOT NULL,
    Durata INT NOT NULL COMMENT 'Durata in minuti',
    Argomento VARCHAR(200),
    Note TEXT,
    FOREIGN KEY (CodiceUF) REFERENCES UnitaFormativa(CodiceUF)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CodiceDocente) REFERENCES Docente(CodiceDocente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (CodiceAula) REFERENCES Aula(CodiceAula)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    INDEX idx_data (DataOra),
    INDEX idx_docente (CodiceDocente)
);

-- ============================================
-- TABELLA: TUTORAGGIO (Relazione Tutor-Studente-Corso)
-- ============================================
CREATE TABLE Tutoraggio (
    CodiceTutoraggio INT AUTO_INCREMENT PRIMARY KEY,
    CodiceTutor INT NOT NULL,
    CodiceStudente INT NOT NULL,
    CodiceCorso INT NOT NULL,
    DataInizio DATE NOT NULL,
    DataFine DATE,
    Note TEXT,
    FOREIGN KEY (CodiceTutor) REFERENCES Tutor(CodiceTutor)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CodiceStudente) REFERENCES Studente(CodiceStudente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CodiceCorso) REFERENCES Corso(CodiceCorso)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT check_date_tutoraggio CHECK (DataFine IS NULL OR DataFine >= DataInizio),
    INDEX idx_tutor (CodiceTutor),
    INDEX idx_studente (CodiceStudente)
);

-- ============================================
-- TABELLA: MATERIALE_DIDATTICO (Entità aggiuntiva utile)
-- ============================================
CREATE TABLE MaterialeDidattico (
    CodiceMateriale INT AUTO_INCREMENT PRIMARY KEY,
    CodiceUF INT NOT NULL,
    Titolo VARCHAR(100) NOT NULL,
    TipoMateriale ENUM('Slide', 'Video', 'Documento', 'Esercizi', 'Altro') NOT NULL,
    URLFile VARCHAR(500),
    Descrizione TEXT,
    DataCaricamento DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CodiceUF) REFERENCES UnitaFormativa(CodiceUF)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================
-- TABELLA: VALUTAZIONE_UF (Per tracciare le valutazioni delle unità formative)
-- ============================================
CREATE TABLE ValutazioneUF (
    CodiceValutazione INT AUTO_INCREMENT PRIMARY KEY,
    CodiceStudente INT NOT NULL,
    CodiceUF INT NOT NULL,
    DataValutazione DATE NOT NULL,
    Voto DECIMAL(4,2),
    Superata BOOLEAN DEFAULT FALSE,
    Note TEXT,
    FOREIGN KEY (CodiceStudente) REFERENCES Studente(CodiceStudente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CodiceUF) REFERENCES UnitaFormativa(CodiceUF)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT unique_studente_uf UNIQUE (CodiceStudente, CodiceUF),
    CONSTRAINT check_voto CHECK (Voto >= 0 AND Voto <= 100)
);

-- ============================================
-- VISTE UTILI
-- ============================================

-- Vista: Iscrizioni attive con dettagli
CREATE VIEW v_Iscrizioni_Attive AS
SELECT 
    i.CodiceIscrizione,
    CONCAT(s.Nome, ' ', s.Cognome) AS NomeStudente,
    s.Email AS EmailStudente,
    c.NomeCorso,
    c.DataInizio,
    c.DataFine,
    i.DataIscrizione,
    i.Stato
FROM Iscrizione i
JOIN Studente s ON i.CodiceStudente = s.CodiceStudente
JOIN Corso c ON i.CodiceCorso = c.CodiceCorso
WHERE i.Stato = 'Attivo';

-- Vista: Calendario lezioni con dettagli
CREATE VIEW v_Calendario_Lezioni AS
SELECT 
    l.CodiceLezione,
    l.DataOra,
    l.Durata,
    l.Argomento,
    uf.Titolo AS UnitaFormativa,
    c.NomeCorso,
    CONCAT(d.Nome, ' ', d.Cognome) AS Docente,
    CONCAT(se.NomeSede, ' - ', a.NomeAula) AS Sede_Aula
FROM Lezione l
JOIN UnitaFormativa uf ON l.CodiceUF = uf.CodiceUF
JOIN Corso c ON uf.CodicCorso = c.CodiceCorso
JOIN Docente d ON l.CodiceDocente = d.CodiceDocente
LEFT JOIN Aula a ON l.CodiceAula = a.CodiceAula
LEFT JOIN Sede se ON a.CodiceSede = se.CodiceSede
ORDER BY l.DataOra;

-- Vista: Studenti con tutor assegnati
CREATE VIEW v_Studenti_Tutor AS
SELECT 
    CONCAT(s.Nome, ' ', s.Cognome) AS NomeStudente,
    c.NomeCorso,
    CONCAT(t.Nome, ' ', t.Cognome) AS NomeTutor,
    t.AreaCompetenza,
    tu.DataInizio,
    tu.DataFine,
    CASE WHEN tu.DataFine IS NULL THEN 'Attivo' ELSE 'Concluso' END AS StatoTutoraggio
FROM Tutoraggio tu
JOIN Studente s ON tu.CodiceStudente = s.CodiceStudente
JOIN Tutor t ON tu.CodiceTutor = t.CodiceTutor
JOIN Corso c ON tu.CodiceCorso = c.CodiceCorso;

-- Vista: Progressione studenti per corso
CREATE VIEW v_Progressione_Studenti AS
SELECT 
    s.CodiceStudente,
    CONCAT(s.Nome, ' ', s.Cognome) AS NomeStudente,
    c.CodiceCorso,
    c.NomeCorso,
    COUNT(DISTINCT uf.CodiceUF) AS TotaleUnitaFormative,
    COUNT(DISTINCT v.CodiceUF) AS UnitaSuperata,
    ROUND((COUNT(DISTINCT v.CodiceUF) * 100.0 / COUNT(DISTINCT uf.CodiceUF)), 2) AS PercentualeCompletamento,
    AVG(v.Voto) AS MediaVoti
FROM Studente s
JOIN Iscrizione i ON s.CodiceStudente = i.CodiceStudente
JOIN Corso c ON i.CodiceCorso = c.CodiceCorso
JOIN UnitaFormativa uf ON c.CodiceCorso = uf.CodicCorso
LEFT JOIN ValutazioneUF v ON s.CodiceStudente = v.CodiceStudente 
    AND uf.CodiceUF = v.CodiceUF 
    AND v.Superata = TRUE
GROUP BY s.CodiceStudente, c.CodiceCorso;

-- ============================================
-- DATI DI ESEMPIO
-- ============================================

-- Inserimento Sedi
INSERT INTO Sede (NomeSede, Indirizzo, Citta, CAP, Capienza, TipoSede) VALUES
('Sede Centrale', 'Via Roma 123', 'Milano', '20100', 200, 'Fisica'),
('Sede Nord', 'Via Garibaldi 45', 'Torino', '10100', 150, 'Fisica'),
('Piattaforma Online', NULL, NULL, NULL, 1000, 'Online');

-- Inserimento Aule
INSERT INTO Aula (NomeAula, Capienza, Attrezzature, CodiceSede) VALUES
('Aula Magna', 100, 'Proiettore, Lavagna interattiva, Sistema audio', 1),
('Laboratorio Informatica 1', 30, '30 PC, Proiettore, WiFi', 1),
('Aula 101', 40, 'Proiettore, Lavagna', 2),
('Laboratorio Lingue', 25, 'Cuffie audio, PC multimediali', 2);

-- Inserimento Studenti
INSERT INTO Studente (Nome, Cognome, DataNascita, Email, Telefono, Indirizzo, Citta, CAP) VALUES
('Mario', 'Rossi', '2000-05-15', 'mario.rossi@email.com', '3331234567', 'Via Verdi 10', 'Milano', '20100'),
('Laura', 'Bianchi', '1999-08-22', 'laura.bianchi@email.com', '3339876543', 'Via Manzoni 5', 'Milano', '20100'),
('Giovanni', 'Verdi', '2001-03-10', 'giovanni.verdi@email.com', '3335555666', 'Corso Italia 78', 'Torino', '10100'),
('Sofia', 'Neri', '2000-11-30', 'sofia.neri@email.com', '3337778889', 'Via Po 12', 'Torino', '10100');

-- Inserimento Docenti
INSERT INTO Docente (Nome, Cognome, Email, Telefono, Specializzazione, CV) VALUES
('Paolo', 'Ferrari', 'paolo.ferrari@istituto.it', '3401234567', 'Informatica e Programmazione', 'Laurea in Informatica, PhD in Computer Science'),
('Anna', 'Colombo', 'anna.colombo@istituto.it', '3409876543', 'Lingue e Letterature Straniere', 'Laurea in Lingue, Master in Didattica'),
('Marco', 'Ricci', 'marco.ricci@istituto.it', '3405556677', 'Matematica e Statistica', 'Laurea in Matematica, PhD in Statistica');

-- Inserimento Tutor
INSERT INTO Tutor (Nome, Cognome, Email, Telefono, AreaCompetenza) VALUES
('Chiara', 'Moretti', 'chiara.moretti@istituto.it', '3451234567', 'Supporto Tecnico e Informatica'),
('Luca', 'Galli', 'luca.galli@istituto.it', '3459876543', 'Orientamento e Metodologia di Studio');

-- Inserimento Corsi
INSERT INTO Corso (NomeCorso, Descrizione, DataInizio, DataFine, NumeroOre, Livello) VALUES
('Programmazione Python Base', 'Corso introduttivo al linguaggio Python', '2025-01-15', '2025-03-30', 60, 'Base'),
('Inglese Intermedio B1', 'Corso di lingua inglese livello intermedio', '2025-02-01', '2025-06-30', 80, 'Intermedio'),
('Data Science Avanzato', 'Corso avanzato di analisi dati e machine learning', '2025-03-01', '2025-07-31', 120, 'Avanzato');

-- Inserimento Unità Formative
INSERT INTO UnitaFormativa (Titolo, Descrizione, NumeroOre, Ordine, CodicCorso) VALUES
-- Corso Python
('Introduzione a Python', 'Sintassi base, variabili e tipi di dati', 10, 1, 1),
('Strutture di controllo', 'If, for, while e gestione del flusso', 12, 2, 1),
('Funzioni e moduli', 'Definizione di funzioni e organizzazione del codice', 15, 3, 1),
('Programmazione ad oggetti', 'Classi, oggetti e ereditarietà', 15, 4, 1),
('Progetto finale Python', 'Sviluppo di un progetto completo', 8, 5, 1),
-- Corso Inglese
('Grammar Review', 'Ripasso delle strutture grammaticali', 15, 1, 2),
('Conversation Skills', 'Pratica della conversazione', 20, 2, 2),
('Business English', 'Inglese per il contesto lavorativo', 20, 3, 2),
('Writing Skills', 'Tecniche di scrittura', 15, 4, 2),
('Exam Preparation', 'Preparazione alla certificazione B1', 10, 5, 2),
-- Corso Data Science
('Python per Data Science', 'NumPy, Pandas e Matplotlib', 20, 1, 3),
('Statistical Analysis', 'Statistica descrittiva e inferenziale', 25, 2, 3),
('Machine Learning Basics', 'Algoritmi di ML supervisionato', 30, 3, 3),
('Deep Learning', 'Reti neurali e applicazioni', 25, 4, 3),
('Progetto Capstone', 'Progetto finale di Data Science', 20, 5, 3);

-- Inserimento Iscrizioni
INSERT INTO Iscrizione (CodiceStudente, CodiceCorso, DataIscrizione, Stato) VALUES
(1, 1, '2025-01-10', 'Attivo'),
(2, 2, '2025-01-28', 'Attivo'),
(3, 1, '2025-01-12', 'Attivo'),
(4, 3, '2025-02-25', 'Attivo');

-- Inserimento Lezioni
INSERT INTO Lezione (CodiceUF, CodiceDocente, CodiceAula, DataOra, Durata, Argomento) VALUES
(1, 1, 2, '2025-01-15 09:00:00', 120, 'Introduzione al corso e setup ambiente'),
(1, 1, 2, '2025-01-17 09:00:00', 120, 'Variabili e tipi di dati in Python'),
(2, 1, 2, '2025-01-22 09:00:00', 120, 'Strutture condizionali'),
(6, 2, 4, '2025-02-01 14:00:00', 90, 'Present Perfect vs Simple Past'),
(7, 2, 4, '2025-02-05 14:00:00', 120, 'Conversazione: Talking about experiences');

-- Inserimento Tutoraggi
INSERT INTO Tutoraggio (CodiceTutor, CodiceStudente, CodiceCorso, DataInizio, DataFine) VALUES
(1, 1, 1, '2025-01-15', NULL),
(1, 3, 1, '2025-01-15', NULL),
(2, 2, 2, '2025-02-01', NULL),
(1, 4, 3, '2025-03-01', NULL);

-- Inserimento Materiale Didattico
INSERT INTO MaterialeDidattico (CodiceUF, Titolo, TipoMateriale, URLFile, Descrizione) VALUES
(1, 'Slide Introduzione Python', 'Slide', '/materiali/python/intro_slides.pdf', 'Slide introduttive al linguaggio Python'),
(1, 'Esercizi Setup Ambiente', 'Esercizi', '/materiali/python/esercizi_setup.pdf', 'Esercizi per configurare l ambiente di sviluppo'),
(2, 'Video: Cicli For e While', 'Video', '/materiali/python/video_cicli.mp4', 'Video tutorial sui cicli'),
(6, 'Grammar Reference B1', 'Documento', '/materiali/inglese/grammar_b1.pdf', 'Manuale di grammatica livello B1');

-- Inserimento Valutazioni
INSERT INTO ValutazioneUF (CodiceStudente, CodiceUF, DataValutazione, Voto, Superata) VALUES
(1, 1, '2025-01-25', 85.00, TRUE),
(3, 1, '2025-01-25', 78.00, TRUE),
(2, 6, '2025-02-10', 88.00, TRUE);

-- ============================================
-- QUERY UTILI PER REPORTISTICA
-- ============================================

-- Query: Elenco studenti per corso con stato iscrizione
-- SELECT 
--     c.NomeCorso,
--     CONCAT(s.Nome, ' ', s.Cognome) AS Studente,
--     i.DataIscrizione,
--     i.Stato
-- FROM Corso c
-- JOIN Iscrizione i ON c.CodiceCorso = i.CodiceCorso
-- JOIN Studente s ON i.CodiceStudente = s.CodiceStudente
-- ORDER BY c.NomeCorso, s.Cognome;

-- Query: Carico di lavoro docenti (numero lezioni per docente)
-- SELECT 
--     CONCAT(d.Nome, ' ', d.Cognome) AS Docente,
--     COUNT(l.CodiceLezione) AS NumeroLezioni,
--     SUM(l.Durata) AS MinutiTotali,
--     ROUND(SUM(l.Durata) / 60, 2) AS OreTotali
-- FROM Docente d
-- JOIN Lezione l ON d.CodiceDocente = l.CodiceDocente
-- GROUP BY d.CodiceDocente
-- ORDER BY OreTotali DESC;

-- Query: Utilizzo aule
-- SELECT 
--     se.NomeSede,
--     a.NomeAula,
--     COUNT(l.CodiceLezione) AS NumeroLezioni,
--     SUM(l.Durata) AS MinutiTotali
-- FROM Aula a
-- JOIN Sede se ON a.CodiceSede = se.CodiceSede
-- LEFT JOIN Lezione l ON a.CodiceAula = l.CodiceAula
-- GROUP BY a.CodiceAula
-- ORDER BY NumeroLezioni DESC;

-- Query: Performance studenti con media voti
-- SELECT 
--     CONCAT(s.Nome, ' ', s.Cognome) AS Studente,
--     COUNT(v.CodiceValutazione) AS NumeroValutazioni,
--     AVG(v.Voto) AS MediaVoti,
--     SUM(CASE WHEN v.Superata = TRUE THEN 1 ELSE 0 END) AS UnitaSuperata
-- FROM Studente s
-- LEFT JOIN ValutazioneUF v ON s.CodiceStudente = v.CodiceStudente
-- GROUP BY s.CodiceStudente
-- HAVING NumeroValutazioni > 0
-- ORDER BY MediaVoti DESC;
