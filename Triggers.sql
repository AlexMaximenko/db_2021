create or replace function teachers_departure() returns trigger as
$$
begin
        update university_db."Seminars"  as S
            set teacher_id = (select teacher_id from university_db."Teachers" as T where T.teacher_id <> old.teacher_id and T.department_name = old.department_name limit 1)
        where S.teacher_id = old.teacher_id;
        update university_db."Lectures"  as L
            set teacher_id = (select teacher_id from university_db."Teachers" as T where T.teacher_id <> old.teacher_id and T.department_name = old.department_name limit 1)
        where L.teacher_id = old.teacher_id;
        return new;
end;
$$ language plpgsql;


create or replace function remove_students_duplicates() returns trigger as $$
begin
    delete from university_db."Students" where name = new.name and surname = new.name;
    return new;
end;
$$ language plpgsql;

/*
 Триггер для удаления дупликатов студентов при вставке
 */
drop trigger if exists insert_update_students on university_db."Students";
create trigger insert_update_students
    before insert or update on university_db."Students"
    for each row
    execute procedure remove_students_duplicates();

insert into university_db."Students" (student_id, name, surname, home_city, group_id, dormitory_id, email)
values (999, 'Даниил', 'Прокопенко', 'Павлодар', 773, 12, 'dprokopenko@phystech.edu');

/*
 Триггер, который назначает группам удаленного преподавателя нового преподавателя с той же кафедры, что и удаленный
 */
drop trigger if exists teacher_deleting_trigger on university_db."Teachers";
create trigger teacher_deleting_trigger
    before delete on university_db."Teachers"
    for each row
    execute procedure teachers_departure();

delete from university_db."Teachers" where teacher_id = 36;
