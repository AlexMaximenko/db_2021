create or replace function hide_control_form(inText text)
returns text as $$
declare
    result text := '';
begin
    if inText = 'Экзамен' then result := 'Экзамен';
    else result = 'Зачет';
    end if;
    return result;
end;
$$ language plpgsql;

create or replace function hide_email(inText text)
returns text as $$
declare
    result text := '';
    flag boolean := true;
    n int := 0;
begin
    n = position('@' in inText);
    for i in 1 .. n-1 by 1
        loop
        result = concat(result, '#');
        end loop;
    result = concat(result, right(inText, char_length(inText) - n + 1));
    return result;
end;
$$ language plpgsql;

/*
 Делаем невозможным узнать дифференцированный зачет или нет
 (чтобы студенты не забивали на предмет)
 */
create or replace view disciplines_for_students as
    select discipline_name, hide_text(control_form), department_name
    from university_db."Disciplines";

select *
from disciplines_for_students;

/*
 Маскируем почту преподавателей чтобы студенты ходили на пары, а не писали письма
 */
create or replace view teachers_for_students as
    select name, surname, hide_email(email), department_name
    from university_db."Teachers";

select *
from teachers_for_students;

/*
 Информация о том, на скольки потоках преподаватели читают лекции и у скольких групп ведут семинары
 */
create or replace view classes_num as
    with teacher_lectures
        as(
            select T.teacher_id, coalesce(count(course_id), 0) as lectures_num
            from university_db."Teachers" as T
                left join university_db."Lectures" as L
                    on T.teacher_id = L.teacher_id
            group by (T.teacher_id)
        ), teacher_seminars as (
           select T.teacher_id, coalesce(count(group_id), 0) as seminars_num
            from university_db."Teachers" as T
                left join university_db."Seminars" as S
                    on T.teacher_id = S.teacher_id
            group by (T.teacher_id)
        )
    select name, surname, lectures_num, seminars_num
    from university_db."Teachers" as teachers
        inner join teacher_lectures on teachers.teacher_id = teacher_lectures.teacher_id
        inner join teacher_seminars on teacher_seminars.teacher_id = teachers.teacher_id;

select *
from classes_num;

/*
 Информация о том, у какого потока какие предметы и формы контроля
 */
 create or replace view course_disciplines as
    select faculty, year_of_graduation, D.discipline_name, hide_text(control_form)
    from university_db."Courses" as C
    inner join university_db."Lectures" as L on C.course_id = L.course_id
    inner join "Disciplines" D on D.discipline_name = L.discipline_name

select *
from course_disciplines;
