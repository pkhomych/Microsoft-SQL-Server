use QALight
-- 1. Напишите запрос, выдающий список фамилий преподавателей английского
--    языка с названиями университетов, в которых они преподают.
--    Отсортируйте запрос по городу, где расположен университ, а
--    затем по фамилии лектора.

select lc.SURNAME, un.NAME
  from LECTURERS lc 
  join UNIVERSITIES un on un.ID=lc.UNIV_ID 
  join SUBJ_LECT sl on sl.LECTURER_ID=lc.ID 
  join SUBJECTS sb on sb.ID=sl.SUBJ_ID and sb.NAME='Английский'
 order by un.CITY, lc.SURNAME;

select lc.SURNAME, un.NAME
  from universities un join lecturers lc 
    on un.ID=lc.UNIV_ID 
   and lc.SURNAME in
   (select surname 
      from LECTURERS lc
     where exists 
	   (select LECTURER_ID 
          from SUBJ_LECT sl 
    	 where lc.ID=sl.LECTURER_ID and exists 
		  (select sub.ID 
             from SUBJECTS sub                   
			where sub.ID=sl.SUBJ_ID 
			  and name='Английский')
			  and exists (select name 
				            from UNIVERSITIES un 
				           where un.ID=lc.UNIV_ID)))
order by un.CITY, lc.SURNAME;
	  
-- 2. Напишите запрос, который выполняет вывод данных о фамилиях, сдававших экзамены 
--    студентов, учащихся в Б.Церкви, вместе с наименованием каждого сданного ими               предмета, оценкой и датой сдачи.

select s.SURNAME, sb.NAME, em.MARK, 
format (em.EXAM_DATE, 'dd.MM.yyyy') DATE
  from students s 
  join EXAM_MARKS em on s.ID=em.STUDENT_ID 
  join SUBJECTS sb on sb.ID=em.SUBJ_ID
  join UNIVERSITIES un on un.ID=s.UNIV_ID 
   and un.ID=(select id
                from UNIVERSITIES 
               where city='Белая церковь');

-- 3. Используя оператор JOIN, выведите объединенный список городов с указанием количеств
--    учащихся в них студентов и преподающих там же преподавателей.

select un.CITY, 
 count (distinct st.ID), 
 count (distinct lc.id)
  from UNIVERSITIES un 
  left join STUDENTS st on un.ID=st.UNIV_ID
  left join LECTURERS lc on un.ID=lc.UNIV_ID
 group by un.CITY

-- 4. Напишите запрос который выдает фамилии всех преподавателей и наименование предметов,
--    которые они читают в КПИ

select lc. surname, sb.name 
  from SUBJECTS sb 
  join SUBJ_LECT sbl on sb.ID=sbl.SUBJ_ID
  join LECTURERS lc on sbl.LECTURER_ID=lc.ID
  join UNIVERSITIES un on lc.UNIV_ID=un.ID 
   and un.NAME='КПИ'

-- 5. Покажите всех студентов-двоешников, кто получил только неудовлетворительные оценки(2) 
--    и по каким предметам, а также тех кто не сдал ни одного экзамена. 
--    В выходных данных должны быть приведены фамилии студентов, названия предметов и 
--    оценка, если оценки нет, заменить ее на прочерк.
		
select s.SURNAME, 
       isnull(sb.NAME, '-'),
       isnull(cast(em.MARK as varchar), '-')
  from STUDENTS s 
  left join EXAM_MARKS em on em.STUDENT_ID=s.ID
  left join SUBJECTS sb on sb.ID=em.SUBJ_ID
 where not exists (select * from EXAM_MARKS em2 where em2.STUDENT_ID=s.id and em2.MARK>2)

-- 6. Напишите запрос, который выполняет вывод списка университетов с рейтингом, 
--    превышающим 490, вместе со значением максимального размера стипендии, 
--    получаемой студентами в этих университетах.

select un.name, max(st.STIPEND) max_st
  from UNIVERSITIES un 
  join STUDENTS st on un.ID=st.UNIV_ID
 where un.RATING>490
 group by un.NAME, un.ID

-- 7. Расчитать средний бал по оценкам студентов для каждого университета, 
--    умноженный на 100, округленный до целого, и вычислить разницу с текущим значением
--    рейтинга университета.

select un.NAME, cast(avg(em.MARK)*100 as decimal)xx, 
       un.RATING - cast(avg(em.MARK)*100 as decimal)xxx
  from STUDENTS st join EXAM_MARKS em on st.ID=em.STUDENT_ID 
  join UNIVERSITIES un on st.UNIV_ID=un.ID
 group by un.NAME, un.RATING, un.ID

-- 8. Написать запрос, выдающий список всех фамилий лекторов из Киева попарно. 
--    При этом не включать в список комбинации фамилий самих с собой,
--    то есть комбинацию типа "Коцюба-Коцюба", а также комбинации фамилий, 
--    отличающиеся порядком следования, т.е. включать лишь одну из двух 
--    комбинаций типа "Хижна-Коцюба" или "Коцюба-Хижна".

select l.SURNAME + ' - ' + lc.SURNAME pairs
  from lecturers l 
 cross join LECTURERS lc
 where l.SURNAME <> lc.SURNAME 
   and l.city='киев' 
   and lc.CITY='киев' 
   and l.ID<lc.ID

-- 9. Выдать информацию о всех университетах, всех предметах и фамилиях преподавателей, 
--    если в университете для конкретного предмета преподаватель отсутствует, то его фамилию
--    вывести на экр ан как прочерк '-' (воспользуйтесь ф-ей isnull)

select un.name 'univ.name', sb.name 'sub. name', 
       isnull(lc.SURNAME, '-') 'lec. surname'
  from UNIVERSITIES un 
 cross join SUBJECTS sb
  left join (select lc.SURNAME, sbl.SUBJ_ID, lc.UNIV_ID
               from SUBJ_LECT sbl 
	  		   join LECTURERS lc on sbl.LECTURER_ID=lc.ID) lc 
    on un.ID=lc.UNIV_ID
   and sb.ID=lc.SUBJ_ID

-- 10. Кто из преподавателей и сколько поставил пятерок за свой предмет?

select lc.SURNAME, count(*)
  from EXAM_MARKS em 
  join STUDENTS st on em.STUDENT_ID=st.ID
  join SUBJ_LECT sbl on sbl.SUBJ_ID=em.SUBJ_ID
  join LECTURERS lc on lc.ID=sbl.LECTURER_ID
 where em.MARK=5 
   and lc.UNIV_ID=st.UNIV_ID
 group by lc.SURNAME


-- 11. Добавка для уверенных в себе студентов: показать кому из студентов какие экзамены
--     еще досдать.
  
select st.id, st.SURNAME, st.NAME, sb.NAME, em.MARK
  from STUDENTS st 
 cross join SUBJECTS sb
  left join EXAM_MARKS em on st.ID=em.STUDENT_ID and sb.ID=em.SUBJ_ID