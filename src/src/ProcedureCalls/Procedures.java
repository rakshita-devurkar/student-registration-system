/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ProcedureCalls;
public class Procedures {
    String disp_Student = "begin ? := studentRegistration.show_students(); end;";
    String disp_Classes = "begin ? := studentRegistration.show_classes(); end;";
    String dispCourse_Credit = "begin ? := studentRegistration.show_course_credit(); end;";
    String disp_Courses = "begin ? := studentRegistration.show_courses(); end;";
    String disp_Enrollments = "begin ? := studentRegistration.show_enrollments(); end;";
    String disp_Grades = "begin ? := studentRegistration.show_grades(); end;";
    String disp_Logs = "begin ? := studentRegistration.show_logs(); end;";
    String disp_PreReq = "begin ? := studentRegistration.show_prerequisites(); end;";
    String ThirdQuery = "begin ? := studentRegistration.get_classes(?); end;";
    String FifthQuery = "begin ? := studentRegistration.student_in_class(?); end;";
    String ListPrerequisite = "begin ? := studentRegistration.prerequisites_courses(?,?); end;";
    String EnrollStudent = "begin studentRegistration.enroll_students(?,?,?); end;";
    String DropStudent = "begin studentRegistration.drop_student(?,?,?,?); end;";
    String DeleteStudent = "begin studentRegistration.delete_student(?); end;";
    
    public String getDisplayStudents(){
        return disp_Student;
    }
    
    //returns all entries in classes DB
    public String getDisplayClasses(){
        return disp_Classes;
    }
    
    //returns all entries in course_credit DB
    public String getDisplayCourseCredit(){
        return dispCourse_Credit;
    }
    
     //returns all entries in courses DB
    public String getDisplayCourses(){
        return disp_Courses;
    }
    
    //returns all entries in enrollments DB
    public String getDisplayEnrollments(){
        return disp_Enrollments;
    }
    
    //returns all entries in grades DB
    public String getDisplayGrades(){
        return disp_Grades;
    }
    
    //returns all entries in logs DB
    public String getDisplayLogs(){
        return disp_Logs;
    }
    
    //returns all entries in prerequisite DB
    public String getDisplayPreRequisite(){
        return disp_PreReq;
    }
    
    //3rd query
    public String Third(){
        return ThirdQuery;
    }
    
    //5th query
    public String Fifth(){
        return FifthQuery;
    }
    
    //4th query
    public String Fourth(){
        return ListPrerequisite;
    }
    
    //4th query
    public String Sixth(){
        return EnrollStudent;
    }
    
    public String Seventh(){
        return DropStudent;
    }
    
    public String Eight(){
        return DeleteStudent;
    }
}
