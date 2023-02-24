use QALight
-- 0. Отобразите для каждого из курсов количество парней и девушек. 

select course, count (case gender 
                        when 'f' then 1 
					  end) 'cnt f',
               count (case gender 
			            when 'm' then 1 
					  end) 'cnt m'
  from STUDENTS
 group by course 

-- 1. Напишите запрос для таблицы EXAM_MARKS, выдающий даты, для которых средний балл 
--    находиться в диапазоне от 4.22 до 4.77. Формат даты для вывода на экран: 
--    день месяць, например, 05 Jun.

 select format(EXAM_DATE, 'dd MMM.')
   from EXAM_MARKS
  group by EXAM_DATE
 having avg(mark) between 4.22 and 4.77
 
  
-- 2. Напишите запрос, который по таблице EXAM_MARKS позволяет найти промежуток времени (*),
--    который занял у студента в течении его сессии, кол-во всех попыток сдачи экзаменов, 
--    а также их максимальные и минимальные оценки. В выборке дожлен присутствовать 
--    идентификатор студента.
--    Примечание: таблица оценок - покрывает одну сессию, (*) промежуток времени -
--    количество дней, которые провел студент на этой сессии - от первого до 
--    последнего экзамена включительно
--    Примечание-2: функция DAY() для решения не подходит! 

select student_id, 
       abs(format(max(EXAM_DATE) - min(EXAM_DATE), 'dd')) days,
       count(*) 'Пересдачи',
	   max(mark) 'Макс. оценка', 
	   min(mark) 'Мин. оценка' 
  from EXAM_MARKS
 group by STUDENT_ID
 
-- 3. Покажите список идентификаторов студентов, которые имеют пересдачи. 

select STUDENT_ID
  from EXAM_MARKS
 group by STUDENT_ID, SUBJ_ID
having count(*)>1
 order by STUDENT_ID asc

-- 4. Напишите запрос, отображающий список предметов обучения, вычитываемых за самый короткий 
--    промежуток времени, отсортированный в порядке убывания семестров. Поле семестра в 
--    выходных данных должно быть первым, за ним должны следовать наименование и 
--    идентификатор предмета обучения.

select SEMESTER, NAME, ID
  from SUBJECTS
 where hours = (select min(hours) from SUBJECTS)
 order by SEMESTER desc

-- 5. Напишите запрос с подзапросом для получения данных обо всех положительных оценках(4, 5) Марины 
--    Шуст (предположим, что ее персональный номер неизвестен), идентификаторов предметов и дат 
--    их сдачи.

select mark, SUBJ_ID, format(EXAM_DATE, 'dd.MM.yyyy')
  from EXAM_MARKS
 where mark>3 and STUDENT_ID in (select id 
                                  from STUDENTS 
								 where surname = 'Шуст'and name = 'Марина') 

-- 6. Покажите сумму баллов для каждой даты сдачи экзаменов, при том, что средний балл не равен 
--    среднему арифметическому между максимальной и минимальной оценкой. Данные расчитать только 
--    для студенток. Результат выведите в порядке убывания сумм баллов, а дату в формате dd/mm/yyyy.

select format(EXAM_DATE, 'dd/MM/yyyy') 'date',
       sum(MARK) summa
  from EXAM_MARKS
 where STUDENT_ID in (select id 
                        from STUDENTS 
					   where gender='f')
 group by EXAM_DATE  
having avg(MARK)<>(max(mark) + min(mark))/2
 order by summa desc 

-- 7. Покажите имена и фамилии всех студентов, у которых средний балл по предметам
--    с идентификаторами 1 и 2 превышает средний балл этого же студента
--    по всем остальным предметам. Используйте вложенные подзапросы, а также конструкцию
--    AVG(case...), либо коррелирующий подзапрос.
--    Примечание: может так оказаться, что по "остальным" предметам (не 1ый и не 2ой) не было
--    получено ни одной оценки, в таком случае принять средний бал за 0 - для этого можно
--    использовать функцию ISNULL().

select name, surname 
  from STUDENTS
 where id in (select STUDENT_ID
                from EXAM_MARKS
               group by STUDENT_ID
              having  avg(case when SUBJ_ID in (1,2) then mark end) > 
			  isnull (avg(case when SUBJ_ID not in (1,2) then mark end),0))

-- 8. Напишите запрос, выполняющий вывод общего суммарного и среднего баллов каждого 
--    экзаменованого второкурсника, его идентификатор и кол-во полученных оценок при условии, 
--    что он успешно сдал 3 и более предметов.

select STUDENT_ID, sum(mark) summa, avg(mark) avgg, count(*) cnt 
  from EXAM_MARKS
 where STUDENT_ID in (select id 
                        from STUDENTS 
					   where course=2) and mark>2
 group by STUDENT_ID
having count(distinct SUBJ_ID)>=3

-- 9. Вывести названия всех предметов, средний балл которых превышает средний балл по всем 
--    предметам университетов г.Днепропетровска. Используйте вложенные подзапросы.

select name 
  from SUBJECTS
 where id in ( select SUBJ_ID--,avg(mark)
                 from EXAM_MARKS
                group by SUBJ_ID
               having avg(mark) > ( select avg(MARK) 
				                     from EXAM_MARKS 
									where STUDENT_ID in (select id  
									                       from STUDENTS  
														  where UNIV_ID in (select id 
														                      from UNIVERSITIES 
																			 where city='днепропетровск'))))
