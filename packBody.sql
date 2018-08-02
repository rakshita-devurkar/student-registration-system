--Package body
set serveroutput on

-- Package name : studentRegistration
create or replace package body studentRegistration as

-- function to show all tuples of table "students"
function show_students
    return ref_cursor is
    rc ref_cursor;
begin
    open rc for
    select * from students;
    return rc;
end;

--function to show all tuples of table "classes"	
function show_classes
    return ref_cursor is
    rc ref_cursor;
begin
    open rc for
    select * from classes;
    return rc;
end;

--function to show all tuples of table "courses"	
function show_courses
    return ref_cursor is
    rc ref_cursor;
begin
    open rc for
    select * from courses;
    return rc;
end;

--function to show all tuples of table "course_credit"	
function show_course_credit
    return ref_cursor is
    rc ref_cursor;
begin
    open rc for
    select * from course_credit;
    return rc;
end;

--function to show all tuples of table "enrollments"	
function show_enrollments
    return ref_cursor is
    rc ref_cursor;
begin
    open rc for
    select * from enrollments;
    return rc;
end;

--function to show all tuples of table "grades"	
function show_grades
    return ref_cursor is
    rc ref_cursor;
begin
    open rc for
    select * from grades;
    return rc;
end;

--function to show all tuples of table "logs"	
function show_logs
    return ref_cursor is
    rc ref_cursor;
begin
    open rc for
    select * from logs;
    return rc;
end;

--function to show all tuples of table "prerequisites"	
function show_prerequisites
    return ref_cursor is
    rc ref_cursor;
begin
    open rc for
    select * from prerequisites;
    return rc;
end;

--function to get all the classes for a particular student
function get_classes
(sid in enrollments.B#%type)
	return ref_cursor is
    rc ref_cursor;
studentCount number;
enrollCount number;
no_course exception;
no_student exception;
begin
	select count(*) into studentCount from students where students.B# = sid;
    if(studentCount < 1) then /*If sid is not present in the students table raise exception.*/
	raise no_student;
	end if;
	
    select count(*) into enrollCount from enrollments where enrollments.B# = sid;
    if(enrollCount < 1) then /*If student is not enrolled into any courses raise exception.*/
	raise no_course;
	end if;
	
    open rc for
		select s.B#,s.firstname,c.classid,c.dept_code,c.course#,c.sect#,c.semester,g.lgrade,g.ngrade 
		from students s,classes c,enrollments e,grades g 
		where s.B#=sid and e.B#=s.B# and c.classid=e.classid and g.lgrade=e.lgrade;
    return rc;
	
exception /* exception section */
	when no_course then
		raise_application_error(-20001,'The student has not taken any course.');
	when no_student then
		raise_application_error(-20002,'The sid is invalid.');
	when others then
		raise_application_error(-20034,sqlcode || '--' || sqlerrm);
end;

--function to get all the direct and indirect prerequisite courses
function prerequisites_courses
	(dcode in prerequisites.pre_dept_code%type,
     cs# in prerequisites.pre_course#%type)
	return ref_cursor is
    rc ref_cursor;
	course_count number;
	wrong_course exception;

Begin

	select count(*) into course_count from courses where course#=cs# and dept_code=dcode;
	if(course_count <1) then
		raise wrong_course;
	end if;
	
	open rc for
	select dept_code,course#
	from prerequisites 
	START WITH prerequisites.pre_course#=cs# and prerequisites.pre_dept_code=dcode
      connect by pre_course#= PRIOR course# and  pre_dept_code= PRIOR dept_code  ;
	return rc;
	
exception
	when wrong_course then
		raise_application_error(-20003,'The course number and deptname is invalid.');
	when others then
		raise_application_error(-20034,sqlcode || '--' || sqlerrm);
	
end;

--function to get all the students of a class
function student_in_class
(cs_id in classes.classid%type)
return ref_cursor is
    rc ref_cursor;
	class_count number;
	student_count number;
	class_invalid exception;
	no_student exception;
	
Begin

	select count(*) into class_count from classes where classid=cs_id;
	if(class_count <1) then
	 raise class_invalid; /*If classid is not present in the classes table raise exception.*/
	end if;

	select count(*) into student_count from enrollments where classid=cs_id;
	if(student_count <1) then /* If no student is enrolled in the class then raise exception */
	 raise no_student;
	end if;

	open rc for
	SELECT classes.classid,courses.title,students.B#,students.firstname
	from courses
	LEFT JOIN classes
	ON courses.dept_code = classes.dept_code
	LEFT JOIN students
	ON courses.dept_code = students.deptname
	where courses.course# = (select course# from classes where classid = cs_id)
	AND classes.classid in (select classid from classes where classid = cs_id)
	AND students.B# in (select B# from enrollments where classid = cs_id)
	ORDER BY courses.course#;
	return rc;
	
exception
	when class_invalid then
		raise_application_error(-20004,'The classid is invalid.'); 
	when no_student then
		raise_application_error(-20005,'No student has enrolled in the class.');
	when others then
		raise_application_error(-20034,sqlcode || '--' || sqlerrm);
End;

--Procedure to enroll a student in given class
procedure enroll_students(sid in students.B#%type,cs_id in classes.classid%type,numberCourses out number) is 
	student_count number;
	class_count number;
	present_count number;
	full number;
	condition number;
	numberPrerequisite number;
	precount number;
	student_invalid exception;
	class_invalid exception;
	already_present exception;
	class_full exception;
	fourCourses exception;
	prerequisite exception;
begin
	select count(*) into student_count from students where B#=sid;
	if(student_count <1) then
		raise student_invalid;/*if student is not present raise exception*/
	end if;
	
	select count(*) into class_count from classes where classid=cs_id;
	if(class_count <1) then
		raise class_invalid; /*If the class is not valid raise exception*/
	end if;
	
	select count(*) into present_count from enrollments where classid=cs_id and B#=sid;
	if(present_count >0) then
		raise already_present; /*If the student is already in the class raise exception*/
	end if;
	
	select (limit-class_size) into full from classes where classid=cs_id;
	if(full <=0) then
		raise class_full; /* If the class is full*/
	end if;
	
	select count(*) into numberCourses from enrollments e,classes c
	where B#=sid and e.classid=c.classid and
	(semester,year) in(select semester,year from classes where classid=cs_id);  
	if (numberCourses	>= 4) then 
		raise fourCourses;  /* select the number of courses of an student, if number of courses are four raise exception*/
	end if;

	select count(*) into numberPrerequisite from students s where s.B# = sid 
	and exists(select * from classes cs where classid in (select classid from classes where (course#,dept_code) 
	in (select pre_course#,pre_dept_code from classes c,prerequisites p where c.course#=p.course# and c.dept_code = p.dept_code and c.classid = cs_id)) 
	and exists (select * from enrollments e where e.B# = s.B# and e.classid = cs.classid));
	
	if(numberPrerequisite <1) then
		raise prerequisite;
	end if;
	
	select count(lgrade) into condition from enrollments where classid in 
	(select classid from classes where course# in 
	(select pre_course# from prerequisites where course# = 
	(select course# from classes where classid = cs_id))) and B# = sid;
	
	if(condition >0) then
	select count(lgrade) into precount from enrollments where classid in 
	(select classid from classes where course# in 
	(select pre_course# from prerequisites where course# = 
	(select course# from classes where classid = cs_id))) 
	and B# = sid and lgrade in ('C-','D','F','I');
	end if;
	if(precount >0) then
		raise  prerequisite; /*If the student has not cleared prerequisite with a required grade raise exception*/
	end if;
	
	

	insert into enrollments(B#,classid) values (sid,cs_id); -- enrols the student into the class 
	
exception
	when student_invalid then
		raise_application_error(-20013,'The B# is invalid.');
	
	when class_invalid then
		raise_application_error(-20014,'The classid is invalid.');
	
	when already_present then
		raise_application_error(-20015,'The student is already in the class.');
	
	when class_full then
		raise_application_error(-20016,'The class is full');
	
	when fourCourses then
		raise_application_error(-20017,'Students cannot be enrolled in more than four classes in the same semester');
		
	when prerequisite then
		raise_application_error(-20018,'Prerequisite not satisfied');
		
	when others then
		raise_application_error(-20034,sqlcode || '--' || sqlerrm);
end;

-- function to drop an student out of the class
procedure drop_student(sid in students.B#%type,cs_id in classes.classid%type,studentEnrollCount out number,courseEnrollCount out number) is
	student_count number;
	class_count number;
	present number;
	class_dept_code Classes.dept_code%type;
	class_course# Classes.course#%type;
	student_invalid exception;
	class_invalid exception;
	not_present exception;
	prerequisite_course exception;
	
	cursor c1 is
	select pre_dept_code, pre_course# 
	from Enrollments e, Classes c, Prerequisites p
	where e.B# = sid
	and e.classid = c.classid
	and c.dept_code = p.dept_Code
	and c.course# = p.course#;
begin
	select count(*) into student_count from students where B#=sid;
	if(student_count <1) then
		raise student_invalid; /*If the student is not present raise exception*/
	end if;
	
	select count(*) into class_count from classes where classid=cs_id;
	if(class_count <1) then
		raise class_invalid; /*If the class is not present raise exception*/
	end if;
	
	select count(*) into present from enrollments where B#=sid and classid=cs_id;
	if(present	<1) then
		raise not_present; /*If the student is not enrolled in the class*/
	end if;
	
	select dept_code, course# into class_dept_code, class_course# from classes where classid = cs_id;
	
	for c1_record in c1 loop
    if(c1_record.pre_dept_code = class_dept_code and c1_record.pre_course# = class_course#) then
        raise prerequisite_course; /*This course is a prerequisite for another course */
    end if;
    end loop;
	
	-- drop the student out of the class 
	delete from enrollments where B#=sid and classid=cs_id;
	
	
	-- check if the student is enrolled in other classes
	select count(*) into studentEnrollCount from Enrollments where B# = sid;
    if(studentEnrollCount < 1) then dbms_output.put_line('This student is not enrolled in any classes.');
	end if;

	/*Reports if after drop class is empty..*/
    select class_size into courseEnrollCount from Classes where classid = cs_id;
    if(courseEnrollCount < 1) then dbms_output.put_line('The class now has no students.');
	end if;
	
exception
	when student_invalid then
		raise_application_error(-20019,'The B# is invalid.');
	
	when class_invalid then
		raise_application_error(-20020,'The classid is invalid.');
		
	when not_present then
		raise_application_error(-20021,'The student is not enrolled in the class.');

	when prerequisite_course then
		raise_application_error(-20022,'The drop is not permitted because another class uses it as a prerequisite.');
		
	when others then
		raise_application_error(-20034,sqlcode || '--' || sqlerrm);	
end;

-- procedure to delete the students from database
procedure delete_student(sid in students.B#%type) is
	student_count number;
	invalidStudent exception;
begin
	select count(*) into student_count from students where B#=sid;
	if(student_count <1) then
		raise invalidStudent;
	end if;
	
	delete from students where B#=sid;
	
exception
	when invalidStudent then
		raise_application_error(-20023,'The B# is invalid.'); /*If the student is not present*/
		
	when others then
		raise_application_error(-20034,sqlcode || '--' || sqlerrm);
		
end;
end;
/
    show errors