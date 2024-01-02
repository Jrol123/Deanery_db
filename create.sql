DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Specializations;
DROP TABLE IF EXISTS Groups;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Activity;
DROP TABLE IF EXISTS Disciplines;
DROP TABLE IF EXISTS Subjects;
DROP TABLE IF EXISTS Grades;
DROP VIEW IF EXISTS Specializations_merge;
DROP TRIGGER IF EXISTS prevent_spec_deletion;
DROP TRIGGER IF EXISTS prevent_group_deletion;
DROP TRIGGER IF EXISTS try_spec_deletion;
DROP TRIGGER IF EXISTS prevent_teacher_toSubj;
DROP TRIGGER IF EXISTS relocate_student_fromGroup;

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

CREATE TABLE Students
(
    ID_certificate  INTEGER PRIMARY KEY UNIQUE,
    'Full Name'     varchar(200)                                   NOT NULL,
    Gender          varchar(1) CHECK ( Gender IN ('m', 'f', 'o') ) NOT NULL,
    'Date of birth' date
);


CREATE TABLE Activity

(
    ID_student       INTEGER                              NOT NULL,
    Date_active      date                                 NOT NULL,
    Year_start_group INTEGER(4)                           NOT NULL,
    Specialization   varchar(8)                           NOT NULL,
    Status           INTEGER(1) CHECK ( Status IN (0, 1)) NOT NULL,
    PRIMARY KEY (ID_student, Date_active, Year_start_group, Specialization),
    -- ON DELETE RESTRICT не работает
    FOREIGN KEY (Year_start_group, Specialization) REFERENCES Groups (Year_start, Specialization) ON DELETE RESTRICT,
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
    Teacher              INTEGER,
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
    Student              INTEGER                                NOT NULL,
    Year_start           varchar(14)                            NOT NULL,
    Specialization_group varchar(8)                             NOT NULL,
    Discipline           varchar(100)                           NOT NULL,
    Date_year            INTEGER(4)                             NOT NULL,
    Date_sem             INTEGER(1)                             NOT NULL,
    -- Не допускается проставление оценки передним числом. (позднее текущего момента).
    Date_add             date CHECK ( Date_add <= date('now') ) NOT NULL,
    FOREIGN KEY (Student) REFERENCES Students (ID_certificate),
    FOREIGN KEY (Discipline, Specialization_group, Date_year, Date_sem) REFERENCES Subjects (Discipline, Specialization_group, Date_year, Date_sem)
    -- Насколько необходимо постоянно писать NotNull, если в ForeignKey перечислены сразу все строки...
);

-- ТРИГГЕРЫ

/*Проверка перед удалением специализации.
  Есть ли непустые группы?*/
CREATE TRIGGER prevent_spec_deletion
    BEFORE DELETE
    ON Specializations
    FOR EACH ROW
BEGIN
    SELECT CASE
               WHEN EXISTS(SELECT 1
                           FROM (SELECT *,
                                        first_value(Status)
                                                    over (partition by ID_student order by Date_active desc) as last_stat
                                 FROM Activity A
                                 WHERE (OLD."Code group" || '.' || OLD."Code education" || '.' || OLD."Code work") ==
                                       A.Specialization) AS Records
                           WHERE Records.last_stat == 1)
                   THEN RAISE(ABORT, 'У этой специальности есть непустые группы!')
               END;
END;

/*При удалении всех групп привязанных к какой-либо специализации её также следует удалить.*/
CREATE TRIGGER try_spec_deletion
    AFTER DELETE
    ON Groups
    FOR EACH ROW
BEGIN
    DELETE
    FROM Specializations
    WHERE ("Code group" || '.' || "Code education" || '.' || "Code work") ==
          CASE
              WHEN NOT EXISTS(SELECT 1
                              FROM Groups G
                              WHERE G.Specialization == OLD.Specialization)
                  THEN OLD.Specialization
              END;
END;

/*Проверка перед удалением группы.
  Есть ли у группы какие-то записи?*/
CREATE TRIGGER prevent_group_deletion
    BEFORE DELETE
    ON Groups
    FOR EACH ROW
BEGIN
    SELECT CASE
               WHEN EXISTS(SELECT 1
                           FROM Activity A
                           WHERE OLD.Specialization == A.Specialization)
                   THEN RAISE(ABORT, 'У этой группы есть/были студенты!')
               END;
END;

/*Проверка перед добавлением студента в новую группу.
  Подвязан ли студент к какой-то другой группе?
  Если да, то создаётся новая запись об отписывании от предыдущей.*/
CREATE TRIGGER relocate_student_fromGroup
    BEFORE INSERT
    ON Activity
    FOR EACH ROW
BEGIN
    INSERT
    INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
    SELECT ID_student, data, Year_start_group, Specialization, 0
    FROM (SELECT *, date('now') as data
          FROM (SELECT *
                FROM Activity A
                WHERE A.ID_student == NEW.ID_student
                ORDER BY Date_active desc
                LIMIT 1) as filter_student
          WHERE filter_student.Status == 1
            AND NEW.Status != 0);
END;

-- Не протестировано
/*Не допускается удаление дисциплин, связанных с существующими предметами.*/
CREATE TRIGGER prevent_disc_deletion
    BEFORE DELETE
    ON Disciplines
    FOR EACH ROW
BEGIN
    SELECT CASE
               WHEN EXISTS(SELECT 1
                           FROM Subjects S
                           WHERE OLD.Name == S.Discipline)
                   THEN RAISE(ABORT, 'У этой дисциплины есть предметы!')
               END;
END;

-- Благодаря Primary Key обеспечена уникальность значений.
/*Разные преподаватели не могут одновременно вести одинаковые дисциплины в одной и той же группе*/
CREATE TRIGGER prevent_teacher_toSubj
    BEFORE INSERT
    ON Subjects
    FOR EACH ROW
BEGIN
    SELECT CASE
               WHEN EXISTS(SELECT 1
                           FROM Subjects S
                           WHERE NEW.Discipline == S.Discipline
                             AND NEW.Specialization_group == S.Specialization_group
                             AND (NEW.Date_year == S.Date_year and NEW.Date_sem == S.Date_sem)
                             AND NEW.Teacher != S.Teacher)
                   THEN RAISE(ABORT, 'У этой группы уже есть преподаватель по этому предмету!')
               END;
END;
