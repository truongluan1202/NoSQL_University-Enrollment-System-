CREATE TABLE Students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    major VARCHAR(50) );


CREATE TABLE Courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(50),
    department VARCHAR(50),
    max_capacity INT );

CREATE TABLE Enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES Students(student_id),
    course_id INT REFERENCES Courses(course_id),
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP );

