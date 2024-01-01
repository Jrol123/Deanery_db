DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Specializations;
DROP VIEW IF EXISTS Specializations_merge;
DROP TABLE IF EXISTS Groups;
DROP TRIGGER IF EXISTS prevent_spec_deletion;
DROP TRIGGER IF EXISTS prevent_group_deletion;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Activity;
DROP TABLE IF EXISTS Disciplines;
DROP TABLE IF EXISTS Subjects;
DROP TABLE IF EXISTS Grades;

CREATE TABLE Teachers
(
    ID              INTEGER PRIMARY KEY AUTOINCREMENT,
    'Full Name'     varchar(200)                                   NOT NULL,
    Gender          varchar(1) CHECK ( Gender IN ('m', 'f', 'o') ) NOT NULL,
    Has_degree      INTEGER CHECK (Has_degree IN (0, 1))           NOT NULL,
    'Date of birth' date
);

--TODO: Починить связь между специализациями и группами. Через изменение внешнего ключа или через триггер.

CREATE TABLE Specializations
(
    'Code group'     varchar(2)   NOT NULL,
    'Code education' varchar(2)   NOT NULL,
    'Code work'      varchar(2)   NOT NULL,
    Name             varchar(100) NOT NULL UNIQUE,
    PRIMARY KEY ('Code group', 'Code education', 'Code work')
);

CREATE VIEW Specializations_merge
AS
SELECT "Code group" || '.' || "Code education" || '.' || "Code work" AS ID_spec
FROM Specializations;

CREATE TABLE Groups
(
    Year_start     INTEGER(4) NOT NULL,
    Specialization varchar(8) NOT NULL,
    PRIMARY KEY (Year_start, Specialization),
    FOREIGN KEY (Specialization) REFERENCES Specializations_merge (ID_spec)
);

CREATE TRIGGER prevent_spec_deletion
    BEFORE DELETE
    ON Specializations
    FOR EACH ROW
BEGIN
    SELECT CASE
               WHEN EXISTS (SELECT 1
                            FROM Groups
                                     JOIN Specializations_merge Sm on Groups.Specialization = Sm.ID_spec
                            WHERE Specialization == Sm.ID_spec)
                   THEN RAISE(ABORT, 'Существует группа, привязанная к данной специализации!')
               END;
END;

-- TODO: Дописать триггер
CREATE TRIGGER prevent_group_deletion
    BEFORE DELETE
    ON Groups
    FOR EACH ROW
BEGIN
    SELECT CASE
               WHEN EXISTS (SELECT 1
                            FROM Activity A
                            WHERE Status == 1
                              and OLD.Specialization == A.Specialization)
                   THEN RAISE(ABORT, 'К этой группе ещё привязаны студенты, которые не закончили обучение!')
               END;
END;

CREATE TABLE Students
(
    ID_certificate  INTEGER PRIMARY KEY UNIQUE,
    'Full Name'     varchar(200)                                   NOT NULL,
    Gender          varchar(1) CHECK ( Gender IN ('m', 'f', 'o') ) NOT NULL,
    'Date of birth' date
);

CREATE TABLE Activity
(
    ID_student     INTEGER                              NOT NULL,
    Date_active    date                                 NOT NULL,
    Year_start     INTEGER(4)                           NOT NULL,
    Semester_start INTEGER(1)                           NOT NULL,
    Year_end       INTEGER(4),
    Semester_end   INTEGER(1),
    Specialization varchar(8)                           NOT NULL,
    Status         INTEGER(1) CHECK ( Status IN (0, 1)) NOT NULL,
    PRIMARY KEY (ID_student, Year_start, Semester_start, Specialization, Date_active),
    FOREIGN KEY (Year_start, Specialization) REFERENCES Groups (Year_start, Specialization),
    FOREIGN KEY (ID_student) REFERENCES Students (ID_certificate)
);

CREATE TABLE Disciplines
(
    Name        varchar(100) NOT NULL UNIQUE PRIMARY KEY,
    Description text
);

CREATE TABLE Subjects
(
    Discipline           varchar(100)                                             NOT NULL,
    -- Для удобства будет лучше сразу сделать семестр.
    Date_year            INTEGER(4)                                               NOT NULL,
    Date_sem             INTEGER(1) CHECK ( Date_sem IN (1, 2, 3, 4, 5, 6, 7, 8)) NOT NULL,
    Grade_type           INTEGER(1) CHECK ( Grade_type IN (1, 2))                 NOT NULL,
    Year_start_group     INTEGER(4)                                               NOT NULL,
    Specialization_group varchar(8)                                               NOT NULL,
    Teacher              INTEGER                                                  NOT NULL,
    PRIMARY KEY (Discipline, Year_start_group, Specialization_group, Date_year, Date_sem),
    FOREIGN KEY (Discipline) REFERENCES Disciplines (Name),
    FOREIGN KEY (Year_start_group, Specialization_group) REFERENCES Groups (Year_start, Specialization),
    FOREIGN KEY (Teacher) REFERENCES Teachers (ID)
);

-- Необходимо определить, как связать оценки и предмет.
-- Может, будет лучше связать их с дисциплиной?
-- Или просто добавить доп. поля... Думаю, с доп. полями будет лучше.

CREATE TABLE Grades
(
    Student              INTEGER      NOT NULL,
    Year_start           varchar(14)  NOT NULL,
    Specialization_group varchar(8)   NOT NULL,
    Discipline           varchar(100) NOT NULL,
    Date_year            INTEGER(4)   NOT NULL,
    Date_sem             INTEGER(1)   NOT NULL,
    FOREIGN KEY (Student) REFERENCES Students (ID_certificate),
    FOREIGN KEY (Discipline, Specialization_group, Date_year, Date_sem) REFERENCES Subjects (Discipline, Specialization_group, Date_year, Date_sem)
    -- Насколько необходимо постоянно писать NotNull, если в ForeignKey перечислены сразу все строки...
);
