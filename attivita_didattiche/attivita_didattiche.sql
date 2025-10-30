-- Schema per la gestione delle attività didattiche in un istituto di formazione

CREATE TABLE sede (
  sede_id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  indirizzo VARCHAR(200),
  citta VARCHAR(80),
  cap VARCHAR(10),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE aula (
  aula_id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL,
  capienza INT,
  sede_id INT,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_aula_sede FOREIGN KEY (sede_id) REFERENCES sede(sede_id)
);

CREATE TABLE corso (
  corso_id INT AUTO_INCREMENT PRIMARY KEY,
  titolo VARCHAR(150) NOT NULL,
  descrizione TEXT,
  ore_totali INT,
  modalita VARCHAR(20),
  sede_id INT,
  attivo TINYINT(1) DEFAULT 1,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_corso_sede FOREIGN KEY (sede_id) REFERENCES sede(sede_id)
);

CREATE TABLE docente (
  docente_id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(60) NOT NULL,
  cognome VARCHAR(80) NOT NULL,
  codice_fiscale VARCHAR(16),
  email VARCHAR(100),
  telefono VARCHAR(30),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE tutor (
  tutor_id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(60),
  cognome VARCHAR(80),
  email VARCHAR(100),
  telefono VARCHAR(30),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE studente (
  studente_id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(60) NOT NULL,
  cognome VARCHAR(80) NOT NULL,
  data_nascita DATE,
  codice_fiscale VARCHAR(16),
  email VARCHAR(100),
  indirizzo VARCHAR(200),
  citta VARCHAR(80),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE unita_formativa (
  unita_formativa_id INT AUTO_INCREMENT PRIMARY KEY,
  titolo VARCHAR(150) NOT NULL,
  descrizione TEXT,
  ore INT,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE corso_uf (
  corso_uf_id INT AUTO_INCREMENT PRIMARY KEY,
  corso_id INT NOT NULL,
  unita_formativa_id INT NOT NULL,
  docente_id INT,
  attivo TINYINT(1) DEFAULT 1,
  ore_assegnate INT,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_corsouf_corso FOREIGN KEY (corso_id) REFERENCES corso(corso_id),
  CONSTRAINT fk_corsouf_unita FOREIGN KEY (unita_formativa_id) REFERENCES unita_formativa(unita_formativa_id),
  CONSTRAINT fk_corsouf_docente FOREIGN KEY (docente_id) REFERENCES docente(docente_id),
  CONSTRAINT uq_corso_unita UNIQUE (corso_id, unita_formativa_id)
);

CREATE TABLE lezione (
  lezione_id INT AUTO_INCREMENT PRIMARY KEY,
  corso_uf_id INT,
  docente_id INT,
  aula_id INT,
  data_ora_inizio DATETIME,
  data_ora_fine DATETIME,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_lezione_corsouf FOREIGN KEY (corso_uf_id) REFERENCES corso_uf(corso_uf_id),
  CONSTRAINT fk_lezione_docente FOREIGN KEY (docente_id) REFERENCES docente(docente_id),
  CONSTRAINT fk_lezione_aula FOREIGN KEY (aula_id) REFERENCES aula(aula_id)
);

CREATE TABLE iscrizione (
  iscrizione_id INT AUTO_INCREMENT PRIMARY KEY,
  studente_id INT NOT NULL,
  corso_id INT NOT NULL,
  data_iscrizione DATE DEFAULT CURRENT_DATE,
  stato VARCHAR(30),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_iscrizione_studente FOREIGN KEY (studente_id) REFERENCES studente(studente_id),
  CONSTRAINT fk_iscrizione_corso FOREIGN KEY (corso_id) REFERENCES corso(corso_id)
);

CREATE TABLE tutor_corso (
  tutor_corso_id INT AUTO_INCREMENT PRIMARY KEY,
  tutor_id INT NOT NULL,
  corso_id INT NOT NULL,
  data_inizio DATE,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_tutorcorso_tutor FOREIGN KEY (tutor_id) REFERENCES tutor(tutor_id),
  CONSTRAINT fk_tutorcorso_corso FOREIGN KEY (corso_id) REFERENCES corso(corso_id),
  CONSTRAINT uq_tutor_corso_period UNIQUE (tutor_id, corso_id, data_inizio)
);

CREATE TABLE valutazione (
  valutazione_id INT AUTO_INCREMENT PRIMARY KEY,
  studente_id INT NOT NULL,
  unita_formativa_id INT NOT NULL,
  corso_id INT,
  corso_uf_id INT,
  docente_id INT,
  data_valutazione DATE,
  voto DECIMAL(5,2),
  esito VARCHAR(30),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_valutazione_studente FOREIGN KEY (studente_id) REFERENCES studente(studente_id),
  CONSTRAINT fk_valutazione_unita FOREIGN KEY (unita_formativa_id) REFERENCES unita_formativa(unita_formativa_id),
  CONSTRAINT fk_valutazione_corso FOREIGN KEY (corso_id) REFERENCES corso(corso_id),
  CONSTRAINT fk_valutazione_corsouf FOREIGN KEY (corso_uf_id) REFERENCES corso_uf(corso_uf_id),
  CONSTRAINT fk_valutazione_docente FOREIGN KEY (docente_id) REFERENCES docente(docente_id)
);

-- Tabella view per le viste richieste

DROP VIEW IF EXISTS v_studenti_carriera_valutazioni;

CREATE VIEW v_studenti_carriera_valutazioni AS
SELECT
    s.studente_id,
    CONCAT(s.nome, ' ', s.cognome) AS studente,
    TIMESTAMPDIFF(YEAR, s.data_nascita, CURDATE()) AS eta,
    c.corso_id,
    c.titolo AS corso,
    uf.unita_formativa_id,
    uf.titolo AS unita_formativa,
    d.docente_id,
    CONCAT(d.nome, ' ', d.cognome) AS docente,
    v.voto,
    v.esito,
    v.data_valutazione
FROM valutazione v
JOIN studente s ON v.studente_id = s.studente_id AND s.is_deleted = 0
JOIN corso c ON v.corso_id = c.corso_id AND c.is_deleted = 0
JOIN unita_formativa uf ON v.unita_formativa_id = uf.unita_formativa_id AND uf.is_deleted = 0
LEFT JOIN docente d ON v.docente_id = d.docente_id AND d.is_deleted = 0
WHERE v.is_deleted = 0;

-- ------------------------------------------
-- -- Query per le cinque views richieste:
-- ------------------------------------------

-- -- Carriera di uno studente, uno studente alla volta

-- SELECT studente_id, studente, corso, unita_formativa, voto, esito, data_valutazione FROM v_studenti_carriera_valutazioni 
-- WHERE studente_id = :studente_id
-- ORDER BY data_valutazione

-- -- Esiti di una specifica materia, di uno specifico corso

-- SELECT * FROM v_studenti_carriera_valutazioni
-- WHERE corso = :corso AND unita_formativa = :unita_formativa;
-- ORDER BY studente

-- -- Media del voto per ciascuna materia di ciascun corso

-- SELECT corso, unita_formativa, ROUND(AVG(voto), 2) AS media_voti
-- FROM v_studenti_carriera_valutazioni
-- GROUP BY corso, unita_formativa

-- -- La media globale dei voti per ciascuno studente in ordine discendente

-- SELECT 
--     studente_id,
--     studente,
--     ROUND(AVG(voto), 2) AS media_globale
-- FROM v_studenti_carriera_valutazioni
-- GROUP BY studente_id, studente
-- ORDER BY media_globale DESC

-- -- La media dei voti per ciascuno studente con più di 30 anni

-- SELECT studente_id, studente, eta, ROUND(AVG(voto), 2) AS media_voti
-- FROM v_studenti_carriera_valutazioni
-- WHERE eta > 30
-- GROUP BY studente_id, studente, eta
-- ORDER BY media_voti DESC
