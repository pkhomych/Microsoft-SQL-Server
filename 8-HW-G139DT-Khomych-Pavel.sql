-- /* Везде, где необходимо данные придумать самостоятельно. */
--Для каждого задания (кроме 4-го) можете использовать конструкцию
-------------------------
-- начать транзакцию
begin transaction
-- проверка до изменений
SELECT * FROM EXAM_MARKS
-- изменения
-- insert into SUBJECTS (ID,NAME,HOURS,SEMESTER) values (25,'Этика',58,2),(26,'Астрономия',34,1)
-- insert into EXAM_MARKS ...
-- delete from EXAM_MARKS where SUBJ_ID in (...)
-- проверка после изменений
SELECT * FROM EXAM_MARKS --WHERE STUDENT_ID > 120
-- отменить транзакцию
rollback


-- 1. Необходимо добавить двух новых студентов для нового учебного 
--    заведения "Винницкий Медицинский Университет".

begin transaction
select * from UNIVERSITIES

insert into UNIVERSITIES (id, name, RATING, CITY)
values (16, 'ВМУ', 745, 'Винница')

insert into STUDENTS (id, SURNAME, name, gender, stipend, course, city, BIRTHDAY, UNIV_ID)
values (46, 'Владимир', 'Кречиков', 'm', 650, 2, 'Киев', '1992-11-07', 16),
       (47, 'Анна', 'Мельшева', 'f', 550, 1, 'Винница','1994-08-25', 16)

select * from UNIVERSITIES
select * from STUDENTS

rollback

-- 2. Добавить еще один институт для города Ивано-Франковск, 
--    1-2 преподавателей, преподающих в нем, 1-2 студента,
--    а так же внести новые данные в экзаменационную таблицу.

begin transaction
 
select * from STUDENTS st 
select * from UNIVERSITIES
select * from LECTURERS
select * from EXAM_MARKS

insert into UNIVERSITIES (id, name , city)
values (17, 'НЕВС', 'Ивано-Франковск')

insert into LECTURERS (id, SURNAME, name, UNIV_ID)
values (888,'Колчков', 'ВТ', 17),
       (999,'Арейнин', 'МК', 17)

insert into STUDENTS (id, SURNAME, name, gender, stipend, course, city, BIRTHDAY, UNIV_ID)
values (46, 'Владимир', 'Кречиков', 'm', 650, 2, 'Киев', '1992-11-07', 17),
       (47, 'Анна', 'Мельшева', 'f', 550, 1, 'Винница','1994-08-25', 17)

insert into EXAM_MARKS (STUDENT_ID, SUBJ_ID,MARK)
values (46, 4, 5),
       (47, 5, 5)

rollback 

-- 3. Известно, что студенты Павленко и Пименчук перевелись в ОНПУ. 
--    Модифицируйте соответствующие таблицы и поля.

begin transaction 

select * from STUDENTS

update STUDENTS
   set UNIV_ID = (select id 
                    from UNIVERSITIES un 
				   where name = 'ОНПУ')
 where SURNAME in ('Павленко', 'Пименчук')

rollback 

-- 4. В учебных заведениях Украины проведена реформа и все студенты, 
--    у которых средний бал не превышает 3.5 балла - отчислены из институтов. 
--    Сделайте все необходимые удаления из БД.
--    Примечание: предварительно "отчисляемых" сохранить в архивационной таблице

begin transaction 

select * from STUDENTS_ARCHIVE
select * from EXAM_MARKS
select * from STUDENTS

insert into STUDENTS_ARCHIVE
select * 
  from STUDENTS st 
 where exists (select STUDENT_ID
                 from EXAM_MARKS em
                where st.ID=em.STUDENT_ID
                group by STUDENT_ID
               having avg(mark)<3.5)

delete from EXAM_MARKS 
 where STUDENT_ID in (select STUDENT_ID
                        from EXAM_MARKS em
                       group by STUDENT_ID
                      having avg(mark)<3.5)

delete from STUDENTS 
 where not exists (select *
                     from EXAM_MARKS em
                    where STUDENTS.ID=em.STUDENT_ID)
                                    
rollback

-- 5. Студентам со средним балом 4.75 начислить 12.5% к стипендии,
--    со средним балом 5 добавить 200 грн.
--    Выполните соответствующие изменения в БД.

begin transaction 

select * 
  from STUDENTS
 where id in (4, 9, 30)

select *
   from STUDENTS
  where stipend = 675

update STUDENTS
   set stipend = (select case 
                           when avg(MARK)=5 then stipend+200 
						   else (select case 
						                  when avg(MARK)=4.75 then stipend+(stipend * 0.125) 
				                          else stipend 
										end
                                   from EXAM_MARKS em
				                  where students.ID=em.STUDENT_ID)  
                          end
                    from EXAM_MARKS em
				   where students.ID=em.STUDENT_ID) 

rollback 

-- 6. Необходимо удалить все предметы, по котором не было получено ни одной оценки.
--    Если таковые отсутствуют, попробуйте смоделировать данную ситуацию.

begin transaction 

select * from SUBJECTS

insert into SUBJECTS (id, name, hours, SEMESTER)
values (8, 'Физкультура', 26, 2),
       (9, 'Материаловедение', 37, 3),
	   (10,'Термодинамика', 33, 1)

delete from SUBJECTS 
 where not exists (select 1 
                     from EXAM_MARKS em 
					where em.SUBJ_ID=SUBJECTS.ID)

rollback 

-- 7. Лектор 3 ушел на пенсию, необходимо корректно удалить о нем данные.

begin transaction 

select * from SUBJ_LECT
select * from LECTURERS

delete from SUBJ_LECT 
 where LECTURER_ID=3

delete from LECTURERS 
 where id=3

rollback 
