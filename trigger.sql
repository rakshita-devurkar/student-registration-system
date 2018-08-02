
/*Sequence is created from 1000 to 9999 for logid of Logs table*/
create sequence log_id start with 1000 maxvalue 9999;

/*Log entry is created whenever a student is entered in Students table*/
create or replace trigger insert_student_trigger
after insert on students
for each row
begin
insert into logs values(log_id.nextval, user, sysdate,'students','insert',:new.B#);
end;
/

/*Log entry is created whenever a student is deleted from the Students table*/
create or replace trigger delete_student_trigger
after delete on students
for each row
begin
insert into logs values(log_id.nextval, user, sysdate,'students','delete',:old.B#);
end;
/

/*Log entry is created whenever a student is enrolled in Enrollments table*/
create or replace trigger insert_enrollment_trigger
after insert on enrollments
for each row
begin
insert into logs values(log_id.nextval, user, sysdate,'enrollments','insert',:new.B#);
end;
/

/*Log entry is created whenever a student is dropped from Enrollments table*/
create or replace trigger delete_enrollments_trigger
after delete on enrollments
for each row
begin
insert into logs values(log_id.nextval, user, sysdate,'enrollments','delete',:old.B#);
end;
/

/*Class_size for classid in Classes table increments by 1 when an entry in inserted in Enrollments table for that classid*/
create or replace trigger trig_incrememt_class_size
after insert on enrollments
for each row
begin
   update classes
   set class_size = class_size +1
   where classid = :new.classid;
end;
/

/*Class_size for classid in Classes table decrements by 1 when an entry in deleted from Enrollments table for that classid*/
create or replace trigger trig_decrement_class_size
after delete on enrollments
for each row
begin
   update classes
   set class_size = class_size -1
   where classid = :old.classid;
end;
/

/* When student is deleted from Students table, all its enrollments are also deleted.*/
create or replace trigger trig_delete_student
before delete on students
for each row
begin
	delete from enrollments where B# = :old.B#;
end;
/

show errors
