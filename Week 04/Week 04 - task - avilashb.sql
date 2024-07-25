-- Name : Avilash Bhowmick --
-- Week 04
-----------------------------------------------------------------------------------

-- creating tables, inserting values inside from the given data

--Create the Students table:
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    Name VARCHAR(255),
    details VARCHAR(255)
);

-- Insert Data into the Students Table:
INSERT INTO Students (student_id, Name, details)
VALUES
    (159103036, 'Mohit Agarwal', '8.9 CCE A'),
    (159103037, 'Rohit Agarwal', '5.2 CCE A'),
    (159103038, 'Shohit Garg', '7.1 CCE B'),
    (159103039, 'Mrinal Malhotra', '7.9 CCE A'),
    (159103040, 'Mehreet Singh', '5.6 CCE A'),
    (159103041, 'Arjun Tehlan', '9.2 CCE B');

-- Create the SubjectDetails table (I’m assuming this is the same as the Subject table):
CREATE TABLE SubjectDetails (
    Sub_id INT PRIMARY KEY,
    name VARCHAR(255),
    MaxSeats INT,
    RemainingSeats INT
);

-- Insert Data into the SubjectDetails Table:
INSERT INTO SubjectDetails (Sub_id, name, MaxSeats, RemainingSeats)
VALUES
    ('PO1491', 'Basics of Political Science', 60, 2),
    ('PO1492', 'Basics of Accounting', 120, 119),
    ('PO1493', 'Basics of Financial Markets', 90, 90),
    ('PO1494', 'Eco philosophy', 60, 50),
    ('PO1495', 'Automotive Trends', 60, 60);

-- Create the StudentPreference table (I’m assuming this is the same as the StudentRecords table):
CREATE TABLE StudentPreference (
    StudentId INT,
    SubjectId INT,
    Preference INT,
    FOREIGN KEY (StudentId) REFERENCES Students(student_id),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(Sub_id),
    PRIMARY KEY (StudentId, SubjectId)
);

-- Insert Data into the StudentPreference Table:
INSERT INTO StudentPreference (StudentId, SubjectId, Preference)
VALUES
    (159103036, 'PO1491', 1),
    (159103036, 'PO1492', 2),
    (159103036, 'PO1493', 3),
    (159103036, 'PO1494', 4),
    (159103036, 'PO1495', 5);

-- Create the Allotments table:
CREATE TABLE Allotments (
    SubjectId INT,
    StudentId INT,
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(Sub_id),
    FOREIGN KEY (StudentId) REFERENCES Students(student_id),
    PRIMARY KEY (SubjectId, StudentId)
);

-- Create the UnallotedStudents table:
CREATE TABLE UnallotedStudents (
    StudentId INT PRIMARY KEY,
    FOREIGN KEY (StudentId) REFERENCES Students(student_id)
);

------------------------------------------------------------
	
-- Main task : Create the Stored Procedure for Allocation:

DELIMITER //

CREATE PROCEDURE AllocateElectiveSubjects()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE studentId INT;
    DECLARE subjectId VARCHAR(10);
    DECLARE preference INT;
    DECLARE gpa DECIMAL(4, 2);
    DECLARE remainingSeats INT;
    DECLARE priorityScore DECIMAL(6, 4);

    -- Cursor to fetch student preferences
    DECLARE cur CURSOR FOR
        SELECT sp.StudentId, sp.SubjectId, sp.Preference, sd.GPA, sd.Branch
        FROM StudentPreference sp
        JOIN StudentDetails sd ON sp.StudentId = sd.StudentId;

    -- Error handling
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Create temporary table to store allocations
    CREATE TEMPORARY TABLE TempAllocations (
        SubjectId VARCHAR(10),
        StudentId INT
    );

    -- Open cursor
    OPEN cur;

    -- Loop through student preferences
    read_loop: LOOP
        FETCH cur INTO studentId, subjectId, preference, gpa;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Calculate priority score (higher GPA = higher priority)
        SET priorityScore = gpa * 1000 + preference;

        -- Check subject availability
        SELECT RemainingSeats INTO remainingSeats
        FROM SubjectDetails
        WHERE SubjectId = subjectId;

        IF remainingSeats > 0 THEN
            -- Allocate subject to student
            INSERT INTO TempAllocations (SubjectId, StudentId)
            VALUES (subjectId, studentId);
            UPDATE SubjectDetails SET RemainingSeats = RemainingSeats - 1 WHERE SubjectId = subjectId;
        END IF;
    END LOOP;

    -- Close cursor
    CLOSE cur;

    -- Mark unallocated students
    INSERT INTO UnallotedStudents (StudentId)
    SELECT DISTINCT StudentId FROM StudentPreference
    WHERE StudentId NOT IN (SELECT StudentId FROM TempAllocations);

    -- Final allocation results
    INSERT INTO Allotments (SubjectId, StudentId)
    SELECT * FROM TempAllocations;

    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS TempAllocations;
END //

DELIMITER ;
