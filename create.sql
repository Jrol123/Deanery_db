DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Specializations;
DROP VIEW IF EXISTS Specializations_merge;
DROP TABLE IF EXISTS Groups;
DROP VIEW IF EXISTS Group_merge;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Activity;

CREATE TABLE Teachers
(
    ID              INTEGER PRIMARY KEY AUTOINCREMENT,
    'Full Name'     varchar(200)                                   NOT NULL,
    Gender          varchar(1) CHECK ( Gender IN ('m', 'f', 'o') ) NOT NULL,
    Has_degree      INTEGER CHECK (Has_degree IN (0, 1))           NOT NULL,
    'Date of birth' date
);

CREATE TABLE Specializations
(
    'Code group'     INTEGER(2)   NOT NULL,
    'Code education' INTEGER(2)   NOT NULL,
    'Code work'      INTEGER(2)   NOT NULL,
    Name             varchar(100) NOT NULL UNIQUE,
    PRIMARY KEY ('Code group', 'Code education', 'Code work')
);

CREATE VIEW Specializations_merge
AS
SELECT 'Code group' || '.' || 'Code education' || '.' || 'Code work' AS ID_spec
FROM Specializations;

CREATE TABLE Groups
(
    Year_start     INTEGER(4) NOT NULL,
    Specialization varchar(9) NOT NULL,
    PRIMARY KEY (Year_start, Specialization),
    FOREIGN KEY (Specialization) REFERENCES Specializations_merge (ID_spec)
);

CREATE VIEW Group_merge
AS
SELECT Year_start || '-' || Specialization AS ID_group
FROM Groups;

CREATE TABLE Students
(
    ID_certificate  INTEGER PRIMARY KEY UNIQUE,
    'Full Name'     varchar(200)                                   NOT NULL,
    Gender          varchar(1) CHECK ( Gender IN ('m', 'f', 'o') ) NOT NULL,
    'Date of birth' date
);

CREATE TABLE Activity
(
    ID_student  INTEGER                                 NOT NULL,
    Date_active date                                    NOT NULL,
    ID_group    varchar(14)                             NOT NULL,
    Status      INTEGER(1) CHECK ( Status IN (0, 1)) NOT NULL,
    PRIMARY KEY (ID_student, ID_group, Date_active),
    FOREIGN KEY (ID_group) REFERENCES Group_merge (ID_group),
    FOREIGN KEY (ID_student) REFERENCES Students (ID_certificate)
);

CREATE TABLE Disciplines
(

);

CREATE TABLE Subjects
(

)
