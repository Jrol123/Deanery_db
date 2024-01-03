--ТРЕБОВАНИЕ 1

INSERT INTO Disciplines (Name)
VALUES ('Матан');

INSERT INTO Subjects (Discipline, Date_year, Date_sem, Grade_type, Year_start_group, Specialization_group, Teacher)
VALUES ('Матан', 2, 2, 1, 2022, '02.03.01', 1);

INSERT INTO Teachers ("Full Name", Gender, Has_degree, "Date of birth")
VALUES ('Ларионов Андрей Игоревич', 'm', 0, '2000-09-18');

INSERT INTO Students (ID_certificate, "Full Name", Gender, "Date of birth")
VALUES (01, 'Поповкин Артемий Андреевич', 'm', date('2004-07-23'));


-- ТРЕБОВАНИЕ 2

INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (01, '2022-09-01', 2022, '02.03.01', 1);
INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (01, '2024-09-01', 2022, '02.03.01', 1);
INSERT INTO Activity (ID_student, Date_active, Year_start_group, Specialization, Status)
VALUES (01, '2026-09-01', 2022, '02.03.01', 0);

-- ТРЕБОВАНИЕ 3


SELECT 'Teacher'                                                     as Status,
       "Full Name"                                                   as "ФИО",
       (SELECT age FROM Teacher_age) as "Возраст"
FROM Teachers
WHERE "Возраст" <= 30
UNION
SELECT 'Student'                                                     as Status,
       "Full Name"                                                   as "ФИО",
       (SELECT age FROM Student_age) as "Возраст"
FROM Students
WHERE "Возраст" <= 30;

