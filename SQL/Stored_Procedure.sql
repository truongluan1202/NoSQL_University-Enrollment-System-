CREATE OR REPLACE PROCEDURE EnrollStudent(p_student_id INT, p_course_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    student_exists BOOLEAN;
    course_exists BOOLEAN;
    current_enrollment INT;
    course_max_capacity INT; 
BEGIN
    -- Verify if the student with p_student_id exists in the Students table.
    -- student_exists = TRUE if student exists, otherwise FALSE.
    SELECT EXISTS (SELECT 1 FROM Students WHERE student_id = p_student_id) INTO student_exists;

    -- If student_exists is FALSE, raise an exception "Student does not exist."
    IF NOT student_exists THEN
        RAISE EXCEPTION 'Student does not exist';
    END IF;

    -- Check if the course with p_course_id exists in the Courses table.
    -- course_exists = TRUE if course exists, otherwise FALSE.
    SELECT EXISTS (SELECT 1 FROM Courses WHERE course_id = p_course_id) INTO course_exists;

    -- If course_exists is FALSE, raise an exception "Course does not exist."
    IF NOT course_exists THEN
        RAISE EXCEPTION 'Course does not exist';
    END IF;

    /* Course Capacity Check:
    current_enrollment: the number of students currently enrolled in the specified course, 
    					 counted by matching p_course_id in the Enrollments table. 
    course_max_capacity: the course’s maximum capacity, retrieved from the Courses table.
	*/
    SELECT COUNT(e.enrollment_id), c.max_capacity INTO current_enrollment, course_max_capacity
    FROM Enrollments e
    JOIN Courses c ON e.course_id = c.course_id
    WHERE e.course_id = p_course_id
    GROUP BY c.max_capacity;

    /* If current_enrollment exceeds or equals course_max_capacity, raise an exception
    stating "Course is full." */
    IF current_enrollment >= course_max_capacity THEN
        RAISE EXCEPTION 'Course is full';
    END IF;

    /* Enroll the student if not already enrolled:
    If the student is not already enrolled in the course, insert a new entry
    into the Enrollments table for p_student_id and p_course_id. */ 
    IF NOT EXISTS (SELECT 1 FROM Enrollments WHERE student_id = p_student_id AND course_id = p_course_id) THEN
        INSERT INTO Enrollments (student_id, course_id) VALUES (p_student_id, p_course_id);
    ELSE
        /* If the student is already enrolled, raise a notice stating "Student is already enrolled 
        in this course," without inserting a new record. */
        RAISE EXCEPTION 'Student is already enrolled in this course';
    END IF;
END;
$$;
