-- student course 
-- Drop the view if it already exists
DROP VIEW IF EXISTS StudentCourseView;

CREATE VIEW StudentCourseView AS
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name, -- combine first name and last name 
    c.course_name,
    e.enrollment_date
FROM Students s
-- ensuring that only students who are enrolled in courses are selected.
JOIN Enrollments e ON s.student_id = e.student_id 
-- linking each enrollment to the corresponding course.
JOIN Courses c ON e.course_id = c.course_id; 

-- course capacity 
-- Drop the view if it already exists
DROP VIEW IF EXISTS CourseCapacityView;

CREATE VIEW CourseCapacityView AS
SELECT 
    c.course_id,
    c.course_name,
    c.department,
    COUNT(e.enrollment_id) AS current_enrollment, 
    c.max_capacity - COUNT(e.enrollment_id) AS remaining_capacity
FROM Courses c
LEFT JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id;



