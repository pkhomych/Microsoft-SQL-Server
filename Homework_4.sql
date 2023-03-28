 use QALight

-- 1. Напишите запрос с EXISTS, позволяющий вывести данные обо всех студентах, 
--    обучающихся в вузах с рейтингом не попадающим в диапазон от 488 до 571

select *
  from STUDENTS s 
 where exists (select * 
                 from UNIVERSITIES un 
				where s.UNIV_ID=un.ID 
				  and rating not between 488 and 571)

-- 2. Напишите запрос с EXISTS, выбирающий всех студентов, для которых в том же городе, 
--    где живет и учится студент, существуют другие университеты, в которых он не учится.

select *
  from STUDENTS s
 where exists (select * 
                 from UNIVERSITIES un 
				where s.UNIV_ID=un.ID and s.CITY=un.CITY)
   and exists (select * 
                 from UNIVERSITIES un 
			    where s.CITY=un.CITY and s.UNIV_ID<>un.ID)

-- 3. Напишите запрос, выбирающий из таблицы SUBJECTS данные о названиях предметов обучения, 
--    экзамены по которым были хоть как-то сданы более чем 12 студентами, за первые 10 дней сессии. 
--    Используйте EXISTS. Примечание: по возможности выходная выборка должна быть без пересдач.

select name 
  from SUBJECTS s
 where exists (select SUBJ_ID 
                 from EXAM_MARKS em 
				where s.ID=em.SUBJ_ID and EXAM_DATE between (select min(EXAM_DATE) 
				                                               from EXAM_MARKS) 
					 										    and 
					 										(select min(EXAM_DATE) + 9
					 										   from EXAM_MARKS)
			    group by SUBJ_ID 
			   having count(distinct STUDENT_ID)>12) 


-- 4. Напишите запрос EXISTS, выбирающий фамилии всех лекторов, преподающих в университетах
--    с рейтингом, превосходящим рейтинг каждого харьковского универа.

select SURNAME
  from LECTURERS lec
 where exists (select * 
                 from UNIVERSITIES un 
				where lec.UNIV_ID=un.ID 
				  and rating> all (select rating 
				                     from UNIVERSITIES 
									where city='Харьков'))

-- 5. Напишите 2 запроса, использующий ANY и ALL, выполняющий выборку данных о студентах, 
--    у которых в городе их постоянного местожительства нет университета.

 select * 
   from students 
  where city <> all (select city 
  	                   from UNIVERSITIES);

-- 6. Напишите запрос выдающий имена и фамилии студентов, которые получили
--    максимальные оценки в первый и последний день сессии.
--    Подсказка: выборка должна содержать по крайне мере 2х студентов.
  
select name, surname 
  from students st
 where exists (select * 
	               from EXAM_MARKS em 
				  where st.ID=em.STUDENT_ID and EXAM_DATE=(select min(EXAM_DATE) 
				                                             from EXAM_MARKS) and mark=(select max(mark) 
															                              from EXAM_MARKS 
																						 where EXAM_DATE=(select min(EXAM_DATE) 
																						                    from EXAM_MARKS)))

 union all

select name, surname 
  from students st
 where exists (select * 
	             from EXAM_MARKS em 
				where st.ID=em.STUDENT_ID and EXAM_DATE=(select max(EXAM_DATE) 
		                                                   from EXAM_MARKS) and mark=(select max(mark) 
															                            from EXAM_MARKS 
																				       where EXAM_DATE=(select max(EXAM_DATE) 
																						                  from EXAM_MARKS)))

-- 7. Напишите запрос EXISTS, выводящий кол-во студентов каждого курса, которые успешно 
--    сдали экзамены, и при этом не получивших ни одной двойки.

select course, count(*) quantity
  from students st
 where exists (select * 
                 from EXAM_MARKS em 
				where st.ID=em.STUDENT_ID and mark>=3) 
   and not exists (select * 
                     from EXAM_MARKS em 
					where st.id=em.STUDENT_ID and mark=2)
 group by course

-- 8. Напишите запрос EXISTS на выдачу названий предметов обучения, 
--    по которым было получено максимальное кол-во оценок.

select name 
  from SUBJECTS s
 where exists (select SUBJ_ID, count(mark)
                 from EXAM_MARKS em
                where s.ID=em.SUBJ_ID
                group by SUBJ_ID 
               having count(mark) = (select max(x.cnt) 
			                          from (select count(mark) cnt
                                       from EXAM_MARKS
                                      group by SUBJ_ID) x))
									
-- 9. Напишите команду, которая выдает список фамилий студентов по алфавиту, 
--    с колонкой комментарием: 'успевает' у студентов , имеющих все положительные оценки, 
--    'не успевает' для сдававших экзамены, но имеющих хотя бы одну 
--    неудовлетворительную оценку, и комментарием 'не сдавал' – для всех остальных.
--    Примечание: по возможности воспользуйтесь операторами ALL и ANY.

select surname, 'успевает' успеваемость
  from STUDENTS st
 where exists (select * 
                 from EXAM_MARKS em 
				where st.ID=em.STUDENT_ID and mark>=3 
   and not exists (select * 
                     from EXAM_MARKS em 
					where st.ID=em.STUDENT_ID and mark=2)) 

 union all

select surname, 'не успевает'
  from STUDENTS st
 where exists (select * 
                 from EXAM_MARKS em 
				where st.ID=em.STUDENT_ID and mark=2) 

 union all

select surname, 'не сдавал'
  from STUDENTS st
 where not exists (select * 
                 from EXAM_MARKS em 
				where st.ID=em.STUDENT_ID)
order by surname asc 

-------С использованием оператора Any

select surname , 'успевает' успеваемость
  from STUDENTS st
 where exists (select *
                 from EXAM_MARKS em 
				where st.ID=em.STUDENT_ID and mark>=3
   and not exists (select * 
                     from EXAM_MARKS em 
					where st.ID=em.STUDENT_ID and mark=2)) 

 union all

select surname, 'не успевает'
  from STUDENTS st
 where id = any (select STUDENT_ID
                 from EXAM_MARKS em 
				where mark=2) 

 union all

select surname, 'не сдавал'
  from STUDENTS st
 where not id = any (select STUDENT_ID 
                 from EXAM_MARKS em 
				where st.ID=em.STUDENT_ID)


-- 10. Создайте объединение двух запросов, которые выдают значения полей 
--     NAME, CITY, RATING для всех университетов. Те из них, у которых рейтинг 
--     равен или выше 500, должны иметь комментарий 'Высокий', все остальные – 'Низкий'.

select name, city, rating, 'Высокий' new
  from UNIVERSITIES
 where rating>=500

union all

select name, city, rating, 'Низкий'
  from UNIVERSITIES
 where rating<500

-- 11. Напишите UNION запрос на выдачу списка фамилий студентов 4-5 курсов в виде 3х полей выборки:
--     SURNAME, 'студент <значение поля COURSE> курса', STIPEND
--     включив в список преподавателей в виде
--     SURNAME, 'преподаватель из <значение поля CITY>', <значение зарплаты в зависимости от города проживания (придумать самим)>
--     отсортировать по фамилии
--     Примечание: достаточно учесть 4-5 городов.

select surname, concat('студент ',course,' курса') info, stipend 'stipend/salary'
  from STUDENTS
 where course in (4,5)

 union all

select surname, 'преподаватель из города ' + city, case city 
                                                     when 'Киев' then 14700
                                                     when 'Харьков' then 14400
                                                     when 'Днепропетровск' then 13900
                                                     when 'Одесса' then 14600
                                                     when 'Львов' then 14500
                                                     when 'Херсон' then 14100
												     else '' 
												   end
                                                          
  from LECTURERS
 where city in ('Киев', 'Харьков', 'Днепропетровск', 'Одесса', 'Львов', 'Херсон')
 order by SURNAME
