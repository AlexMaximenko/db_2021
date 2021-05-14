/*
    Вывести преподавателей,
    которые прочитали более 3 курсов лекций вместе с количеством этих курсов,
    в порядке убывания этого количества
 */

select surname, name, lectures_num
from university_db."Teachers" as teachers
    inner join (select t.teacher_id, count(*) as lectures_num
                from university_db."Teachers" as t inner join university_db."Lectures" as l
                    on t.teacher_id = l.teacher_id
                group by (t.teacher_id)
                having count(*) > 3
                order by count(*) desc) as temp
        on teachers.teacher_id = temp.teacher_id
order by lectures_num desc;


/*
    Вывести количество студентов на каждом факультете в порядке убывания
*/

select  faculty, count(student_id) as students_at_faculty
from university_db."Students" as students
    inner join (select group_id, faculty
                from university_db."Groups" as groups
                    inner join university_db."Courses" as courses
                        on groups.course_id = courses.course_id) as temp
        on students.group_id = temp.group_id
group by faculty
order by count(student_id) desc;


/*
    Вывести топ-10 преподавателей по количеству студентов в семинарских группах
 */

with students_in_groups
    as (
        select groups.group_id, count(student_id) as students_count
        from university_db."Groups" as groups
            inner join university_db."Students" as students
                on groups.group_id = students.group_id
        group by groups.group_id)
     , teachers_groups
         as (
             select name, surname, group_id
             from university_db."Teachers" as t
                inner join university_db."Seminars" as se
                    on t.teacher_id = se.teacher_id
    )
select  name, surname, sum(students_count)
from teachers_groups
    inner join students_in_groups
        on  teachers_groups.group_id = students_in_groups.group_id
group by (name, surname)
order by sum(students_count) desc limit 10;


/*
 Вывести количество дисциплин,
 преподаваемых каждой кафедрой дисциплин для студентов каждого года выпуска,
 добавить столбец с количеством дисциплин в предыдущий год
 */

select department_name, year_of_graduation, count(faculty) as disciplines_for_this_year,
       lag(cast(count(faculty) as int), 1, 0) over (partition by department_name order by year_of_graduation) as disciplines_for_last_year
from university_db."Teachers" as T
    inner join university_db."Lectures" as L
        on T.teacher_id = L.teacher_id
    inner join "Courses" C on L.course_id = C.course_id
group by (department_name, year_of_graduation);


/*
 Вывести ранжирование общежитий по числу проживающих в них студентов
 */

select dormitory_id, students_count,
       rank() over (order by students_count desc)
from (select D.dormitory_id as dormitory_id, count(student_id) as students_count
      from university_db."Students" as S
        inner join university_db."Dormitories" as D
            on S.dormitory_id = D.dormitory_id
      group by D.dormitory_id) as temp;
