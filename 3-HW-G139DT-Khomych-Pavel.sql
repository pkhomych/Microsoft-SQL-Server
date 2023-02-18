--  !!! В выходной выборке должны присутствовать только запрашиваемые в условии поля.
use QALight

-- 1. Напишите один запрос с использованием псевдонимов для таблиц и псевдонимов полей, 
--    выбирающий все возможные комбинации городов (CITY) из таблиц 
--    STUDENTS, LECTURERS и UNIVERSITIES
--    строки не должны повторяться, убедитесь в выводе только уникальных троек городов
--    Внимание: убедитесь, что каждая колонка выборки имеет свое уникальное имя

select distinct St.CITY as St_c, 
                Lc.CITY as Lc_c, 
				Un.CITY as Un_c
           from STUDENTS as St, 
		        LECTURERS as Lc, 
				UNIVERSITIES as Un;
        --where St.UNIV_ID=Lc.UNIV_ID and Lc.UNIV_ID=Un.ID;

-- 2. Напишите запрос для вывода полей в следущем порядке: семестр, в котором он
--    читается, идентификатора (номера ID) предмета обучения, его наименования и 
--    количества отводимых на этот предмет часов для всех строк таблицы SUBJECTS

select SEMESTER, ID, NAME, HOURS 
  from SUBJECTS;


-- 3. Выведите все строки таблицы EXAM_MARKS, в которых предмет обучения SUBJ_ID равен 4

select *
  from EXAM_MARKS
 where SUBJ_ID = 4;

-- 4. Необходимо выбирать все данные, в следующем порядке 
--    Стипендия, Курс, Фамилия, Имя  из таблицы STUDENTS, причем интересуют
--    студенты, родившиеся после '1993-07-21'

select STIPEND, COURSE, SURNAME, NAME, BIRTHDAY
  from STUDENTS
 where BIRTHDAY > '1993-07-21';

-- 5. Вывести на экран все предметы: их наименования и кол-во часов для каждого из них
--    в 1-м семестре и при этом кол-во часов не должно превышать 41

select NAME, SEMESTER, HOURS
  from SUBJECTS
 where SEMESTER = 1 and HOURS <= 41; 

-- 6. Напишите запрос, позволяющий вывести из таблицы EXAM_MARKS уникальные 
--    значения экзаменационных оценок, которые были получены '2012-06-12'

select distinct MARK, EXAM_DATE
           from EXAM_MARKS
		  where EXAM_DATE = '2012-06-12';

-- 7. Выведите список фамилий студентов, обучающихся на третьем и последующих 
--    курсах и при этом проживающих не в Киеве, не Харькове и не Львове.

select SURNAME, COURSE, CITY
  from STUDENTS 
 where COURSE >= 3 and CITY not in ('Киев','Харьков','Львов');
 
 select SURNAME, COURSE, CITY
  from STUDENTS 
 where COURSE >= 3 and (CITY <> 'Киев' and CITY <> 'Харьков' and CITY <> 'Львов');

-- 8. Покажите данные о фамилии, имени и номере курса для студентов, 
--    получающих стипендию в диапазоне от 450 до 650, не включая 
--    эти граничные суммы. Приведите несколько вариантов решения этой задачи.

select SURNAME, NAME, COURSE, STIPEND
  from STUDENTS 
 where STIPEND>450 and STIPEND<650;

select SURNAME, NAME, COURSE, STIPEND
  from STUDENTS 
 where STIPEND between 450.01 and 649.99;

select SURNAME, NAME, COURSE, STIPEND
  from STUDENTS 
 where STIPEND between 450 and 650 and (STIPEND <> 450 and STIPEND != 650);

select SURNAME, NAME, COURSE, STIPEND
  from STUDENTS 
 where STIPEND between 450 and 650 and STIPEND not in (450,650);

-- 9. Напишите запрос, выполняющий выборку из таблицы LECTURERS всех фамилий
--    преподавателей, проживающих во Львове, либо же преподающих в университете
--    с идентификатором 14

select SURNAME
  from LECTURERS
 where CITY = 'Львов' or UNIV_ID = 14; 

-- 10. Выясните в каких городах (названия) расположены университеты,  
--     рейтинг которых составляет 528 +/- 47 баллов.

select CITY 
  from UNIVERSITIES
 where RATING between 528-47 and 528+47;

-- 11. Отобрать список фамилий киевских студентов, их имен и дат рождений 
--     для всех нечетных курсов.

select SURNAME, NAME, BIRTHDAY, COURSE, COURSE%2 result
  from STUDENTS
 where COURSE%2 = 1;

-- 12. Упростите выражение фильтрации (избавтесь от NOT) и дайте логическую формулировку запроса?
-- SELECT * FROM STUDENTS WHERE (STIPEND < 500 OR NOT (BIRTHDAY >= '1993-01-01' AND ID > 9))
-- Подсказка: после упрощения, запрос должен возвращать ту же выборку, что и оригинальный

select * 
  from STUDENTS 
 where (STIPEND < 500 or not (BIRTHDAY >= '1993-01-01' and ID > 9));

 -- Выбрать все из таблицы студентов где стипендия меньше 500 или день рождение 
 -- до '1993-01-01' или идентификатор не больше 9 

select * 
  from STUDENTS 
 where STIPEND < 500 or BIRTHDAY < '1993-01-01' or ID <= 9;

-- 13. Упростите выражение фильтрации (избавтесь от NOT) и дайте логическую формулировку запроса?
-- SELECT * FROM STUDENTS WHERE NOT ((BIRTHDAY = '1993-06-07' OR STIPEND > 500) AND ID >= 9)
-- Подсказка: после упрощения, запрос должен возвращать ту же выборку, что и оригинальный

select * 
  from STUDENTS 
 where not ((BIRTHDAY = '1993-06-07' or STIPEND > 500) and ID >= 9);

 -- Выбрать всю информацию из таблицы студентов где день рождение не соответствует
 -- дате '1993-06-07' и стипендия не больше 500 или идентификатор меньше 9.

select *
  from STUDENTS
 where BIRTHDAY <> '1993-06-07' and STIPEND <= 500 or ID < 9;