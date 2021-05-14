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
 Вернуть группы, в которых преподаватель ведет семинары и соответствующие предметы
 */
drop procedure if exists teaching_groups_by_teacher_id(teacher_id_ int);
create or replace procedure teaching_groups_by_teacher_id(teacher_id_ int)
language sql as $$
    drop table if exists university_db.teachers_groups;
    create table university_db.teachers_groups as
        select group_id, discipline_name
        from university_db."Seminars" as S
        where S.teacher_id = teacher_id_;
$$;

call teaching_groups_by_teacher_id(1);
select *
from university_db.teachers_groups;

/*
 Вернуть студенту его предметы и формы их контроля по student_id
 */
drop procedure if exists get_students_disciplines(student_id_ int);
create or replace procedure  get_students_disciplines(student_id_ int)
language sql as $$
    drop table if exists university_db.students_disciplines;
    create table university_db.students_disciplines as
        with group_disciplines
            as (
                select discipline_name
                from university_db."Seminars" as S
                where S.group_id = (select group_id from university_db."Students" as St where St.student_id = student_id_)
            )
        select D.discipline_name, control_form
        from university_db."Disciplines" as D
            inner join group_disciplines as G
                on D.discipline_name = G.discipline_name;
$$;

call get_students_disciplines(26);
select *
from university_db.students_disciplines;
