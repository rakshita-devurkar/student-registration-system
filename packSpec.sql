-- package specification
-- package name : studentRegistration
create or replace package studentRegistration as
type ref_cursor is ref cursor;

-- function to show all tuples of table "students"
function show_students
return ref_cursor;

--function to show all tuples of table "classes"	
function show_classes
return ref_cursor;

--function to show all tuples of table "courses"	
function show_courses
return ref_cursor;

--function to show all tuples of table "course_credit"	
function show_course_credit
return ref_cursor;

--function to show all tuples of table "enrollments"	
function show_enrollments
return ref_cursor;

--function to show all tuples of table "grades"	
function show_grades
return ref_cursor;

--function to show all tuples of table "logs"	
function show_logs
return ref_cursor;

--function to show all tuples of table "prerequisites"	
function show_prerequisites
return ref_cursor;

--function to get all the classes for a particular student
function get_classes
(sid in enrollments.B#%type)
return ref_cursor;

--function to get all the direct and indirect prerequisite courses
function prerequisites_courses
(dcode in prerequisites.pre_dept_code%type,
cs# in prerequisites.pre_course#%type)
return ref_cursor;

--function to get all the students of a class
function student_in_class
(cs_id in classes.classid%type)
return ref_cursor;

--Procedure to enroll a student in given class
procedure enroll_students(sid in students.B#%type,cs_id in classes.classid%type,numberCourses out number);

-- function to drop an student out of the class
procedure drop_student(sid in students.B#%type,cs_id in classes.classid%type,studentEnrollCount out number,courseEnrollCount out number);

-- procedure to delete the students from database
procedure delete_student(sid in students.B#%type);

end;
/
show errors