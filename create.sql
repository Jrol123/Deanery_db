DROP TABLE IF EXISTS Teachers;

CREATE TABLE IF NOT EXISTS Teachers
(
    ID              INTEGER PRIMARY KEY AUTOINCREMENT,
    'Full Name'     varchar(200)                                 NOT NULL,
    Gender          varchar(1) CHECK (Gender IN ('m', 'f', 'o')) NOT NULL,
    Has_degree      INTEGER CHECK (Has_degree IN (0, 1))         NOT NULL,
    'Date of birth' date
);

CREATE TABLE IF NOT EXISTS Students
(
    ID_certificate  INTEGER PRIMARY KEY,
    'Full Name'     varchar(200)                                 NOT NULL,
    Gender          varchar(1) CHECK (Gender IN ('m', 'f', 'o')) NOT NULL,
    'Date of birth' date
);

CREATE TABLE IF NOT EXISTS Groups
(
    Year_start     INTEGER(4) NOT NULL,
    Specialization INTEGER(6) NOT NULL,
    PRIMARY KEY (Year_start, Specialization),
    FOREIGN KEY (Specialization) REFERENCES Specializations (ID)
);
