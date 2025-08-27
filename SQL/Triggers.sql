-- Initiate 
ALTER TABLE Courses DROP COLUMN IF EXISTS course_capacity;
DO $$
BEGIN
    -- Check if the `course_capacity` column exists in the `Courses` table
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'courses' AND column_name = 'course_capacity'
    ) THEN
        -- Add `course_capacity` column and set default to 0
        ALTER TABLE Courses ADD COLUMN course_capacity INT DEFAULT 0;

        -- Add a check constraint to ensure `course_capacity` is between 0 and `max_capacity`
        ALTER TABLE Courses
        ADD CONSTRAINT check_capacity_range
        CHECK (course_capacity >= 0 AND course_capacity <= max_capacity);
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS EnrollmentLog (
    log_id SERIAL PRIMARY KEY,         -- Primary key for the log entries
    student_id INT NOT NULL,           -- The ID of the student
    course_id INT NOT NULL,            -- The ID of the course
    action VARCHAR(10) NOT NULL,       -- 'enroll' or 'drop'
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Time of action
);


-- Step 1: Update course capacity whenever a student enrolls or drops a course

-- Function to update the course_capacity when a student enrolls or drops a course
CREATE OR REPLACE FUNCTION update_course_capacity()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- Decrement course_capacity when a student enrolls
        UPDATE Courses
        SET course_capacity = course_capacity + 1
        WHERE course_id = NEW.course_id;
    ELSIF (TG_OP = 'DELETE') THEN
        -- Increment course_capacity when a student drops the course
        UPDATE Courses
        SET course_capacity = course_capacity - 1
        WHERE course_id = OLD.course_id;
    END IF;

    RETURN NULL; -- Return NULL as we don’t need to modify the row itself
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_capacity_trigger ON Enrollments;

-- Create new trigger to update course_capacity when students enroll or drop a course
CREATE TRIGGER update_capacity_trigger
AFTER INSERT OR DELETE ON Enrollments
FOR EACH ROW
EXECUTE FUNCTION update_course_capacity();

-- Step 2: Log enrollment events (enroll and drop actions) in EnrollmentLog

-- Function to log enrollment events (enroll and drop actions)
CREATE OR REPLACE FUNCTION log_enrollment_event()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- Log enrollment event
        INSERT INTO EnrollmentLog (student_id, course_id, action)
        VALUES (NEW.student_id, NEW.course_id, 'enroll');
    ELSIF (TG_OP = 'DELETE') THEN
        -- Log drop event
        INSERT INTO EnrollmentLog (student_id, course_id, action)
        VALUES (OLD.student_id, OLD.course_id, 'drop');
    END IF;

    RETURN NULL; -- No need to modify the row itself
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS enrollment_log_trigger ON Enrollments;

-- Create trigger for logging enrollment events (enroll and drop actions)
CREATE TRIGGER enrollment_log_trigger
AFTER INSERT OR DELETE ON Enrollments
FOR EACH ROW
EXECUTE FUNCTION log_enrollment_event();

