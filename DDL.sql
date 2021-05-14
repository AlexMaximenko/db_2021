create schema university_db;

create table if not exists university_db."Departments"
(
	department_name varchar(50) not null
		constraint departments_pk
			primary key,
	contact_email varchar(50) not null,
	contact_office varchar(50) not null
);

create unique index departments_department_name_uindex
    on university_db."Departments" (department_name);

create table if not exists university_db."Courses"
(
	course_id serial not null
		constraint courses_pk
			primary key,
	faculty varchar(30) not null,
	year_of_graduation integer not null
);

create unique index courses_course_id_uindex
    on university_db."Courses" (course_id);

create table if not exists university_db."Groups"
(
	group_id integer not null
		constraint groups_pk
			primary key,
	course_id integer not null
        constraint course_id
            references university_db."Courses"
);

create unique index groups_group_id_uindex on university_db."Groups" (group_id);

create table if not exists university_db."Disciplines"
(
	discipline_name varchar(100) not null
		constraint disciplines_pk
			primary key,
	academic_hours integer not null,
	control_form varchar(30) not null
		constraint "Disciplines_control_form_check"
			check ((control_form)::text = ANY ((ARRAY['Дифференцированный зачет'::character varying, 'Недифференцированный зачет'::character varying, 'Экзамен'::character varying])::text[])),
	department_name varchar(50) not null
		constraint department_name
			references university_db."Departments"
);

create unique index disciplines_discipline_name
    on university_db."Disciplines" (discipline_name);

create table if not exists university_db."Dormitories"
(
	dormitory_id integer not null
		constraint dormitory_pk
			primary key,
	postal_code integer default 141701 not null,
	street varchar(50) not null,
	building varchar(30)
);

create unique index dormitories_dormitory_id_uindex on university_db."Dormitories" (dormitory_id);

create table if not exists university_db."Students"
(
	student_id integer not null
		constraint students_pk
			primary key,
	name varchar(30) not null,
	surname varchar(30) not null,
	home_city varchar(30),
	group_id integer not null
		constraint group_id
			references university_db."Groups",
	dormitory_id integer
		constraint dormitory_id
			references university_db."Dormitories",
	email varchar(30)
);

create unique index if not exists students_student_id_uindex
	on university_db."Students" (student_id);

create index if not exists students_group_id_uindex
    on university_db."Students" (group_id);

create table if not exists university_db."Teachers"
(
	teacher_id integer not null
		constraint teachers_pk
			primary key,
	name varchar(30) not null,
	surname varchar(30) not null,
	dormitory_id integer
		constraint dormitory_id
			references university_db."Dormitories",
	email varchar(50),
	department_name varchar(50) not null
		constraint department_name
			references university_db."Departments"
);

create unique index teachers_teacher_id_uindex
    on university_db."Teachers" (teacher_id);

create table if not exists university_db."Seminars"
(
	group_id integer not null
		constraint group_id
			references university_db."Groups",
	discipline_name varchar(100) not null,
	teacher_id integer not null
		constraint teacher_id
			references university_db."Teachers"
);

create index seminars_group_id_uindex
    on university_db."Seminars" (group_id);

create index seminars_teacher_id_uindex
    on university_db."Seminars" (teacher_id);

create table if not exists university_db."Lectures"
(
	course_id integer not null
		constraint course_id
			references university_db."Courses",
	discipline_name varchar(100) not null
		constraint discipline_name
			references university_db."Disciplines",
	teacher_id integer not null
		constraint teacher_id
			references university_db."Teachers"
);

create index lectures_teacher_id_uindex
    on university_db."Lectures" (teacher_id);

create index lectures_course_id_uindex
    on university_db."Lectures" (course_id);

