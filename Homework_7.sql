-- 1. Создайте модифицируемое представление для получения сведений обо всех студентах, 
--    круглых отличниках. Используя это представление, напишите запрос обновления, 
--    "расжалующий" их в троечников.

create view v_stud_5
as select st.*, em.MARK
     from STUDENTS st, EXAM_MARKS em
    where exists (select * 
	                from EXAM_MARKS em 
				   where em.STUDENT_ID=st.ID and mark=5) 
      and not exists (select * 
	                    from EXAM_MARKS em1 
   				       where em1.STUDENT_ID=st.ID and mark<5)
       and st.ID=em.STUDENT_ID
select * 
  from v_stud_5

select * 
  from EXAM_MARKS 
 where STUDENT_ID in (4,9,30)

 begin transaction 

update v_stud_5
   set mark = 3

rollback 

-- 2. Создайте представление для получения сведений о количестве студентов 
--    обучающихся в каждом городе.

create view v_CNT_STUDENTS 
    as select un.city, count(*) cnt
         from UNIVERSITIES  un
         left join STUDENTS st on un.ID=st.UNIV_ID 
        group by un.city 

alter view v_CNT_STUDENTS 
    as select un.city, count(st.ID) cnt
         from UNIVERSITIES  un
         left join STUDENTS st on un.ID=st.UNIV_ID 
        group by un.city 

 select * 
   from v_CNT_STUDENTS

-- 3. Создайте представление для получения сведений по каждому студенту: 
--    его ID, фамилию, имя, средний и общий баллы.

create view v_INF_STUDENT  
as select st.id, st.SURNAME, st.NAME, 
   isnull(cast(avg(em.MARK) as varchar),'--') 'avg mark', 
   isnull(cast(sum(em.MARK) as varchar),'--') 'sum mark'
     from STUDENTS st 
     left join EXAM_MARKS em on em.STUDENT_ID=st.ID
    group by st.id, st.SURNAME, st.NAME
     
select *  
  from v_INF_STUDENT

-- 4. Создайте представление для получения сведений о студенте фамилия, 
--    имя, а также количестве экзаменов, которые он сдал успешно, и количество,
--    которое ему еще нужно досдать (с учетом пересдач двоек).

create view v_CNT_STUD as
select st.SURNAME, st.NAME, 
 count (distinct em.subj_id ) 'cnt+', 
 count (*) - count (distinct em.subj_id) 'cnt-'
  from STUDENTS st 
 cross join SUBJECTS sb
  left join EXAM_MARKS em on em.STUDENT_ID=st.ID 
   and sb.ID=em.SUBJ_ID 
   and em.mark>2
 group by st.id, st.SURNAME, st.NAME


-- 5. Какие из представленных ниже представлений являются обновляемыми?


-- A. CREATE VIEW DAILYEXAM AS
--    SELECT DISTINCT STUDENT_ID, SUBJ_ID, MARK, EXAM_DATE
--    FROM EXAM_MARKS

/*Данное представление необновляемо так как присутствует distinct в выборке*/

-- B. CREATE VIEW CUSTALS AS
--    SELECT SUBJECTS.ID, SUM (MARK) AS MARK1
--    FROM SUBJECTS, EXAM_MARKS
--    WHERE SUBJECTS.ID = EXAM_MARKS.SUBJ_ID
--    GROUP BY SUBJECT.ID

/*Данное view необновляемое так как присутствует агрегатная функция и группировка*/

-- C. CREATE VIEW THIRDEXAM
--    AS SELECT *
--    FROM DAILYEXAM
--    WHERE EXAM_DATE = '2012/06/03'

/*Данное view необновляемое так как в выборке представление в котором используется distinct*/

-- D. CREATE VIEW NULLCITIES
--    AS SELECT ID, SURNAME, CITY
--    FROM STUDENTS
--    WHERE CITY IS NULL
--    OR SURNAME BETWEEN 'А' AND 'Д'
--    WITH CHECK OPTION

/*Можно модифицировать только соблюдая условия в разделе where*/

-- 6. Создайте представление таблицы STUDENTS с именем STIP, включающее поля 
--    STIPEND и ID и позволяющее вводить или изменять значение поля 
--    стипендия, но только в пределах от 100 до 500.

create view v_STIP
as select id, stipend--,surname
     from STUDENTS
    where stipend between 100 and 500
with check option 

select * from v_STIP

begin transaction 

insert into v_STIP (id,surname, STIPEND)
values (120, 'pifpaf', 99)

rollback