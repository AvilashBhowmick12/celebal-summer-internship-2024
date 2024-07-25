-- Name : Avilash Bhowmick --
-- Week 05
-----------------------------------------------------------------------------------

-- creating tables, inserting values inside from the given data

-- 1. Create the SubjectAllotments table
CREATE TABLE SubjectAllotments (
    StudentId VARCHAR(10),
    SubjectId VARCHAR(10),
    Is_valid BIT,
    PRIMARY KEY (StudentId, SubjectId)
);

-- Create the SubjectRequest table
CREATE TABLE SubjectRequest (
    StudentId VARCHAR(10),
    SubjectId VARCHAR(10),
    PRIMARY KEY (StudentId, SubjectId)
);

---------------------
-- 2. Insert Data into the Tables

INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_valid)
VALUES
    ('159103036', 'PO1491', 1),
    ('159103036', 'PO1492', 0),
    ('159103036', 'PO1493', 0),
    ('159103036', 'PO1494', 0),
    ('159103036', 'PO1495', 0);

-- Insert data into SubjectRequest
INSERT INTO SubjectRequest (StudentId, SubjectId)
VALUES ('159103036', 'PO1496');

--------------------------------------
-- 3. Implement the Workflow

DELIMITER //

CREATE PROCEDURE UpdateSubjectAllotments(IN requestedStudentId VARCHAR(10), IN requestedSubjectId VARCHAR(10))
BEGIN
    DECLARE currentSubjectId VARCHAR(10);
    DECLARE currentIsValid BIT;

    -- Check if the student exists in SubjectAllotments
    SELECT SubjectId, Is_valid INTO currentSubjectId, currentIsValid
    FROM SubjectAllotments
    WHERE StudentId = requestedStudentId;

    IF currentSubjectId IS NULL THEN
        -- Student doesn't exist, insert the requested subject
        INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_valid)
        VALUES (requestedStudentId, requestedSubjectId, 1);
    ELSE
        IF currentSubjectId <> requestedSubjectId THEN
            -- Update existing records
            UPDATE SubjectAllotments
            SET Is_valid = 0
            WHERE StudentId = requestedStudentId AND Is_valid = 1;

            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_valid)
            VALUES (requestedStudentId, requestedSubjectId, 1);
        END IF;
    END IF;
END //

DELIMITER ;
