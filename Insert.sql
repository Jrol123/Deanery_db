--ТРЕБОВАНИЕ 1

INSERT INTO Specializations("code group", "code education", "code work", name)
VALUES ('02', '03', '01', 'СЦТ');
INSERT INTO Specializations ("Code group", "Code education", "Code work", Name)
VALUES ('01', '03', '02', 'ПМИ');

INSERT INTO Groups(Year_start, Specialization)
VALUES (2022, '02.03.01');
INSERT INTO Groups(Year_start, Specialization)
VALUES (2022, '01.03.02');

INSERT INTO Teachers ("Full Name", Gender, Has_degree, "Date of birth")
VALUES ('Ларионов Андрей Игоревич', 'm', 0, '2000-09-18');

INSERT INTO Students (ID_certificate, "Full Name", Gender, "Date of birth")
VALUES (01, 'Поповкин Артемий Андреевич', 'm', date('2004-07-23'));

INSERT INTO Students
VALUES (101, 'Death', 'o', date('983-06-25'));

INSERT INTO Students
VALUES (666, 'Dude Postal', 'o', date('983-06-25'));

-- ТРЕБОВАНИЕ 2

INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (01, '2022-09-01', 2022, '02.03.01', 1);
INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (01, '2024-09-01', 2022, '02.03.01', 1);
INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (01, '2026-09-01', 2022, '02.03.01', 0);

INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (101, '2024-09-01', 2022, '02.03.01', 1);
INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (101, '2026-09-01', 2022, '02.03.01', 0);

INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (666, '2022-09-01', 2022, '02.03.01', 1);
INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (666, '2024-09-01', 2022, '01.03.02', 1);

-- ТРЕБОВАНИЕ 3

SELECT 'Преподаватель'               as "Должность",
       "Full Name"                   as "ФИО",
       Gender                        as Пол,
       (SELECT age FROM Teacher_age) as "Возраст"
FROM Teachers
WHERE "Возраст" <= 30
UNION
SELECT 'Студент'                     as "Должность",
       "Full Name"                   as "ФИО",
       Gender                        as Пол,
       (SELECT age FROM Student_age) as "Возраст"
FROM Students
WHERE "Возраст" <= 30;

-- ТРЕБОВАНИЕ 4

SELECT 'Преподаватель' as "Должность",
       "Full Name"     as "ФИО",
       Gender          as Пол,
       "Date of birth" as "День рождения"
FROM Teachers
WHERE "Date of birth" <= date('2004-01-01')
UNION
SELECT 'Студент'       as "Должность",
       "Full Name"     as "ФИО",
       Gender          as Пол,
       "Date of birth" as "Возраст"
FROM Students
WHERE "Date of birth" <= date('2004-01-01');

-- ТРЕБОВАНИЕ 5

SELECT "Full Name" as "ФИО",
       Gender      as Пол
FROM Subjects S
         JOIN main.Teachers T on T.ID = S.Teacher
-- Можно сделать через чистое сравнение по параметрам
WHERE date('2024-07-23') >= CASE
                                WHEN S.Date_sem == 2
                                    THEN DATE(
                                        ((S.Year_start_group + S.Date_year - 1) || '-09-01'),
                                        '+6 month')
                                ELSE DATE(((S.Year_start_group + S.Date_year - 1) || '-09-01'))
    END;

-- ТРЕБОВАНИЕ 6

SELECT *
FROM (SELECT *
      FROM Activity_student A
      WHERE "Группа" == '2022-02.03.01'
        AND date('2028-07-23') >= "Дата"
      ORDER BY "Дата" desc)
-- Если нужны все записи по группе за промежуток — просто используйте View
GROUP BY ID;

-- ТРЕБОВАНИЕ 7

-- CTE напрочь отказывается работать...
SELECT "Full name"    as "ФИО",
       Gender         as "Пол",
       Specialization as "Направление",
       Date_active    as "Дата поступления"
FROM (SELECT ID_student as ID, Specialization, Date_active, Status
      FROM Activity
      WHERE Specialization == (SELECT Specialization as student_spec
                               FROM (SELECT *
                                     FROM Activity
                                     WHERE ID_student == 01
                                       AND '2024-09-01' >= Date_active
                                     ORDER BY Date_active desc
                                     LIMIT 1)
                               WHERE Status == 1)
        AND '2024-09-01' >= Date_active
      ORDER BY Date_active desc)
         JOIN Students S on ID == S.ID_certificate
WHERE Status == 1;

-- Требование 8

INSERT INTO Disciplines (Name)
VALUES ('Матан');
INSERT INTO Subjects (Discipline, Date_year, Date_sem, Grade_type, Year_start_group, Specialization_group, Teacher)
VALUES ('Матан', 2, 2, 1, 2022, '02.03.01', 1);
INSERT into Grades (Student, Discipline, Date_grade, Grade)
VALUES (01, 'Матан', date('now'), 4);
INSERT into Grades (Student, Discipline, Date_grade, Grade)
VALUES (01, 'Матан', date('now', '+3 month'), 4);
INSERT into Grades (Student, Discipline, Date_grade, Grade)
VALUES (01, 'Матан', date('now', '+4 month'), 5);

INSERT INTO Disciplines (Name)
VALUES ('Линал');
INSERT INTO Subjects (Discipline, Date_year, Date_sem, Grade_type, Year_start_group, Specialization_group, Teacher)
VALUES ('Линал', 2, 2, 1, 2022, '02.03.01', 1);
INSERT INTO Grades (Student, Discipline, Date_grade, Grade)
VALUES (101, 'Матан', date('now', '+3 month'), 5);
INSERT INTO Grades (Student, Discipline, Date_grade, Grade)
VALUES (101, 'Линал', date('now', '+3 month'), 5);

INSERT INTO Disciplines (Name)
VALUES ('Черчение');
INSERT INTO Subjects (Discipline, Date_year, Date_sem, Grade_type, Year_start_group, Specialization_group, Teacher)
VALUES ('Черчение', 2, 2, 1, 2022, '01.03.02', 1);
INSERT INTO Grades (Student, Discipline, Date_grade, Grade)
VALUES (666, 'Матан', date('now', '+3 month'), 5);


-- Требование 9

SELECT *
FROM Grades
WHERE Student == 101
  -- Если не нужен фильтр по дисциплинам — удалить
  AND Discipline in ('Матан');

-- Требование 10

SELECT Discipline as "Предмет",
       AVG(Grade)
FROM (SELECT *
      FROM (SELECT *
            FROM Activity
            WHERE Specialization == '02.03.01'
            ORDER BY Date_active desc)
      GROUP BY ID_student
      HAVING Status == 1)
         JOIN Grades on ID_student
-- Если не нужен фильтр по дисциплинам — закомментировать
WHERE Discipline == 'Линал'
GROUP BY Discipline
