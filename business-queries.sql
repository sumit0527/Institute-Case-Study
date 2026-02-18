-- 🧩 CATEGORY 1: DATA INTEGRITY (BEFORE TRIGGERS)

-- 1️. Prevent Overpayment Beyond Course Fee
DELIMITER $$ 
CREATE TRIGGER prevent_over_payment  
BEFORE INSERT ON payments 
FOR EACH ROW 
BEGIN 
	DECLARE total_paid INT;
	DECLARE course_fees INT; 

	SELECT IFNULL(SUM(amount), 0) INTO total_paid 
	FROM payments 
	WHERE enrollment_id = NEW.enrollment_id;

	SELECT course_fee INTO course_fees
	FROM courses c 
	JOIN batches b ON c.course_id = b.course_id
	JOIN enrollments e ON b.batch_id = e.batch_id
	WHERE e.enrollment_id = NEW.enrollment_id;

	IF (total_paid + NEW.amount) > course_fees THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = "Over Payment Beyond Course Fee"; 
	END IF; 
END $$ 
DELIMITER ;

-- Testing Over Payment 
INSERT INTO payments VALUES (11, 1, 10000, 'UPI', NOW(), 'success');

-- 2️. Block Enrollment in Inactive Courses
DELIMITER $$ 
CREATE TRIGGER block_inactive_course 
BEFORE INSERT ON enrollments 
FOR EACH ROW 
BEGIN 
	DECLARE course_status VARCHAR(10);
    
	SELECT c.status INTO course_status
	FROM courses c 
	JOIN batches b ON c.course_id = b.course_id
	WHERE b.batch_id = NEW.batch_id; 
    
	IF course_status IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Invalid batch ID';
	END IF;

	IF course_status = 'inactive' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Cannot enroll: Course is inactive';
	END IF;

END $$ 
DELIMITER ;

-- Testing Inactive Course 
-- INSERT INTO courses VALUES (5, 1, "Java Programming", 3, 15000.00, "Core Java with problem solving", "inactive");
-- INSERT INTO users VALUES (9, 3, "Sohil Pinjari", "sohil.student@gmail.com", "student123", "2937493211", "active", NOW());
-- INSERT INTO students VALUES (5, 9, "MTECH", "IIT DELHI", 2024);
-- INSERT INTO enrollments VALUES (5, 5, 2, CURDATE(), 'active');
-- UPDATE courses 
-- SET status = "inactive" 
-- WHERE course_id = 2;

-- 3️. Prevent Duplicate Enrollment in Same Batch
DELIMITER $$ 
CREATE TRIGGER prevent_duplicate_enrollment 
BEFORE INSERT ON enrollments 
FOR EACH ROW 
BEGIN 
	IF EXISTS (
		SELECT 1 
		FROM enrollments e 
		WHERE student_id = NEW.student_id AND batch_id = NEW.batch_id
	) THEN 
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Student already enrolled in this batch';
	END IF;
END $$ 
DELIMITER ;

-- Test Duplicate Enrollment Trigger 
INSERT INTO enrollments VALUES (5, 1, 1, CURDATE(), 'active');

-- 4️. Restrict Trainer Assignment Without Expertise
DELIMITER $$ 
CREATE TRIGGER validate_trainer_expertise 
BEFORE INSERT ON batch_trainers 
FOR EACH ROW 
BEGIN 
	DECLARE trainer_expertise VARCHAR(100); 
    DECLARE course VARCHAR(50); 
    
	SELECT expertise INTO trainer_expertise
	FROM trainers
	WHERE trainer_id = NEW.trainer_id;
    
    SELECT c.course_name INTO course 
	FROM courses c 
	JOIN batches b ON c.course_id = b.course_id
    WHERE batch_id = NEW.batch_id;

	IF trainer_expertise NOT LIKE CONCAT("%", course, "%") THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Trainer Expertise does not match Course.";
	END IF;
END $$ 
DELIMITER ;

/* 🧠 SECTION 1: Revenue & Business Performance */ 

-- Case 1: Overall Business Health
-- Management wants to understand how much total revenue the institute has generated so far from successful payments.
SELECT SUM(amount) as total_revenue 
FROM payments
WHERE payment_status = "success";

-- Case 2️: Revenue Trend Analysis
-- The finance team wants to track revenue growth over time to identify peak admission months. 
CREATE VIEW monthly_revenue_report AS
SELECT 
	DATE_FORMAT(payment_date, '%Y-%m') as `month`,
    SUM(amount) as revenue
FROM payments
WHERE payment_status = "success"
GROUP BY `month` 
ORDER BY `month`;

-- Case 3️: Course Profitability
-- Not all courses perform equally. Management wants to know which courses contribute the most to revenue.
CREATE VIEW revenue_per_course AS 
SELECT 
	c.course_name,
    COALESCE(SUM(p.amount), 0) as revenue
FROM payments p 
JOIN enrollments e ON p.enrollment_id = e.enrollment_id
JOIN batches b ON e.batch_id = b.batch_id
RIGHT JOIN courses c ON b.course_id = c.course_id
GROUP BY c.course_name
ORDER BY revenue DESC;

/* 🎓 SECTION 2: Student Enrollment Insights */ 

-- Case 4️: Course Popularity
-- The academic team wants to know which courses are attracting the most students.
WITH students_per_course AS (
	SELECT 
		c.course_name, 
		COUNT(DISTINCT s.student_id) as total_students
	FROM students s 
	JOIN enrollments e ON s.student_id = e.student_id 
	JOIN batches b ON e.batch_id = b.batch_id 
	JOIN courses c ON b.course_id = c.course_id
	GROUP BY c.course_name
	ORDER BY total_students DESC
)
SELECT * FROM students_per_course;

-- Case 5️: Student Lifecycle Status
-- To improve retention, management wants a snapshot of how many students are currently active, completed, or dropped.	
SELECT 
	status, 
    COUNT(*) as student_count
FROM enrollments
GROUP BY status;

-- Case 6️: Upskilling Behavior
-- Some students enroll in multiple courses. Identifying them helps in targeted marketing. 
WITH students_with_multiple_courses AS (
SELECT 
	s.student_id,
	u.full_name, 
    COUNT(e.enrollment_id) as course_enrollments_count
FROM users u 
JOIN students s ON u.user_id = s.user_id
JOIN enrollments e ON s.student_id = e.student_id
JOIN batches b ON e.batch_id = b.batch_id 
JOIN courses c ON b.course_id = c.course_id
GROUP BY s.student_id, u.full_name
HAVING COUNT(e.enrollment_id) > 1
)
SELECT * FROM students_with_multiple_courses;

/* 🧑‍🏫 SECTION 3: Trainer & Batch Performance */

-- Case 7️: Trainer Workload
-- Management wants to ensure trainers are not overloaded or underutilized.
WITH trainer_workload AS (
	SELECT 
		u.full_name as trainer,
		COUNT(bt.batch_id) as total_batches
	FROM users u 
	JOIN trainers t ON u.user_id = t.user_id
	JOIN batch_trainers bt ON t.trainer_id = bt.trainer_id
	GROUP BY bt.trainer_id, u.full_name
)
SELECT * FROM trainer_workload;

-- Case 8️: Trainer Impact
-- Which trainers are handling the most students across all their batches?
WITH TrainerStudentCount AS (
	SELECT 
		u.full_name,
        COUNT(DISTINCT e.student_id) AS student_count
	FROM batch_trainers bt
	JOIN batches b ON bt.batch_id = b.batch_id
	JOIN enrollments e ON b.batch_id = e.batch_id
	JOIN trainers t ON bt.trainer_id = t.trainer_id
	JOIN users u ON u.user_id = t.user_id
GROUP BY u.full_name
)
SELECT * FROM TrainerStudentCount;
    

/* 🗓 SECTION 4: Attendance & Engagement */

-- Case 9: Student Engagement
-- Regular attendance is critical for course completion.
WITH StudentRegularAttendance AS (
SELECT 
	s.student_id, 
    ROUND(COUNT(s.student_id) * 100 / SUM(COUNT(a.status = "present")) OVER (), 2) as total_regular_attendance 
FROM students s 
JOIN enrollments e ON s.student_id = e.student_id 
JOIN attendance a ON e.enrollment_id = a.enrollment_id
GROUP BY s.student_id
)
SELECT * FROM StudentRegularAttendance;

-- Case 10: At-Risk Students
-- Students with attendance below 75% are at risk of dropping out.
WITH StudentsWithLowAttendance  AS (
	SELECT 
		s.student_id, 
		COUNT(s.student_id) * 100 / SUM(COUNT(a.status = "present")) OVER () as attendance_percentage 
	FROM students s 
	JOIN enrollments e ON s.student_id = e.student_id 
	JOIN attendance a ON e.enrollment_id = a.enrollment_id
	GROUP BY s.student_id
)
SELECT * FROM StudentsWithLowAttendance 
WHERE attendance_percentage < 75;

/* 💳 SECTION 5: Payments & Financial Risk */

-- Case 1️1: Outstanding Dues
-- The accounts team wants to identify students who have not fully paid their course fees.
WITH StudentsWithPendingFees AS (
SELECT 
    u.full_name,
    e.batch_id,
    p.payment_status,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN users u ON s.user_id = u.user_id
LEFT JOIN payments p ON e.enrollment_id = p.enrollment_id
WHERE p.payment_status = "pending"
GROUP BY u.full_name , e.batch_id, p.payment_status
HAVING total_paid = (SELECT course_fee
					 FROM courses c
					 JOIN batches b ON c.course_id = b.course_id
					 WHERE b.batch_id = e.batch_id)
)
SELECT * FROM StudentsWithPendingFees;

-- Case 1️2: Installment Patterns
-- Many students prefer installment payments. Management wants to analyze this trend.
WITH StudentsOnInstallmentPlan AS (
SELECT u.*
FROM users u 
JOIN students s ON u.user_id = s.user_id
WHERE s.student_id IN (
	SELECT e.student_id
	FROM enrollments e 
    JOIN payments p ON e.enrollment_id = p.enrollment_id
	GROUP BY e.enrollment_id
	HAVING COUNT(p.payment_id) > 1
))
SELECT * FROM StudentsOnInstallmentPlan ;

/* 📜 SECTION 6: Certification & Completion */

-- Case 1️3: Certification Gaps
-- Some students have completed courses but haven’t received certificates yet.
WITH StudentsAwaitingCertificates AS (
	SELECT u.full_name 
	FROM enrollments e 
	JOIN batches b ON e.batch_id = b.batch_id
	JOIN courses c ON b.course_id = c.course_id
	LEFT JOIN certificates ct ON e.enrollment_id = ct.enrollment_id
	JOIN students s ON e.student_id = s.student_id
	JOIN users u ON s.user_id = u.user_id
	WHERE ct.enrollment_id IS NULL
)
SELECT * FROM StudentsAwaitingCertificates;

/* 📞 SECTION 7: Marketing & Lead Analysis */

-- Case 1️4: Lead Conversion Effectiveness
-- Marketing wants to measure how effective enquiries are turning into enrollments.
WITH EnquiryConversionRate AS (
SELECT 
	COUNT(CASE WHEN status = "converted" THEN 1 END) AS conversions, 
	COUNT(*) AS total_enquires
FROM enquiries  
)
SELECT 
	conversions, 
    total_enquires,
	ROUND((conversions / total_enquires) * 100, 2) as conversion_percentage
FROM EnquiryConversionRate;

-- Case 1️5: Demand Forecasting
-- To plan future batches, management wants to know which courses receive the most enquiries.
SELECT c.course_name
FROM enrollments e 
JOIN batches b ON e.batch_id = b.batch_id 
JOIN courses c ON c.course_id = b.course_id
GROUP BY c.course_name
ORDER BY COUNT(e.batch_id) DESC 
LIMIT 1; 

/* BONUS (INTERVIEW GOLD) */

-- Case 1️6: Revenue Focus Strategy
-- Management wants to focus marketing and trainer allocation on top-performing courses.
DELIMITER $$
CREATE PROCEDURE GetTopCoursesByRevenue  (IN n INT)
BEGIN 
	WITH top_n_course AS (
		SELECT 
			c.course_name as course,
			SUM(p.amount) as revenue,
			DENSE_RANK() OVER (ORDER BY SUM(p.amount) DESC) as rnk
		FROM courses c 
		JOIN batches b ON c.course_id = b.course_id
		JOIN enrollments e ON b.batch_id = e.batch_id
		JOIN payments p ON e.enrollment_id = p.enrollment_id
		GROUP BY c.course_name
	)
	SELECT 
		course,
        revenue 
	FROM top_n_course
	WHERE rnk <= n; 
END $$
DELIMITER ;

CALL GetTopCoursesByRevenue(2);

-- CATEGORY 2 — AUTOMATION (AFTER TRIGGERS)
-- 5️. Auto-Activate Enrollment After Full Payment
DELIMITER $$ 
CREATE TRIGGER auto_active_enrollment 
AFTER INSERT ON paymentS 
FOR EACH ROW 
BEGIN 
	DECLARE total_paid INT;
    DECLARE course_fees INT;

	SELECT SUM(p.amount) INTO total_paid
	FROM payments
	WHERE enrollment_id = NEW.enrollment_id AND p.status = "success"; 

	SELECT c.course_fee INTO course_fees 
	FROM enrollments e 
	JOIN batches b ON e.batch_id = b.batch_id
	JOIN courses c ON b.course_id = c.course_id
	WHERE e.enrollment_id = NEW.enrollment_id;

	IF total_paid = course_fees THEN 
		UPDATE enrollments 
		SET status = "active" 
		WHERE enrollment_id = NEW.enrollment_id;
	END IF;
END $$
DELIMITER ;

-- 6️. Auto-Generate Certificate on Completion
DELIMITER $$
CREATE TRIGGER auto_generate_certificate 
AFTER UPDATE ON enrollments 
FOR EACH ROW 
BEGIN 
	DECLARE name VARCHAR(50);

	SELECT LOWER(SUBSTRING(u.full_name, 1, POSITION(" " IN u.full_name))) INTO name
    FROM users u 
    JOIN students s ON u.user_id = s.user_id 
    JOIN enrollments e ON s.student_id = e.student_id 
    WHERE e.enrollment_id = OLD.enrollment_id ;
    
	IF OLD.status <> NEW.status AND NEW.status = "completed" THEN 
		INSERT INTO certificates (enrollment_id, issue_date, certificate_url) 
        VALUES (OLD.enrollment_id, CURDATE(), CONCAT("certificates/fs_", name,'.pdf'));
	END IF;
END $$ 
DELIMITER ;

-- 7️. Auto-Flag At-Risk Students (Attendance < 75%) 
DELIMITER $$ 
CREATE TRIGGER auto_flag_risk_student 
AFTER INSERT ON attendance 
FOR EACH ROW 
BEGIN 
	DECLARE att_perc INT;
    DECLARE total_classes INT;
    
	WITH student_attendence_percentage AS (
	SELECT 
		enrollment_id, 
		(SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) * 100) / COUNT(*) OVER () as attendence_percentage,
        COUNT(*) OVER () as total_clases 
	FROM attendance
	GROUP BY enrollment_id
	)
	SELECT 
		attendence_percentage,
        total_clases 
        INTO att_perc, total_classes
	FROM student_attendence_percentage
	WHERE enrollment_id = NEW.enrollment_id; 

	IF total_classes > 0 AND att_perc < 75 THEN 
		UPDATE enrollments 
        SET status = "at_risk" 
        WHERE enrollment_id = NEW.enrollment_id;
	END IF;

END $$
DELIMITER ;

-- 🔹 CATEGORY 3 — DELETE AUDIT

-- 8️. Log Deleted Students
DELIMITER $$ 
CREATE TRIGGER before_delete_student 
BEFORE DELETE ON students 
FOR EACH ROW 
BEGIN 
	DECLARE name VARCHAR(30) ;
    
	SELECT u.full_name INTO name
    FROM students s 
    JOIN users u ON s.user_id = u.user_id 
    WHERE s.student_id = OLD.student_id;

	INSERT INTO deleted_student_log (student_id, name, deleted_at) VALUES (OLD.student_id, name, NOW()); 
END $$ 
DELIMITER ;

-- 9️. Log Deleted Trainers
DELIMITER $$ 
CREATE TRIGGER before_delete_trainer 
BEFORE DELETE ON trainers 
FOR EACH ROW 
BEGIN 
	DECLARE name VARCHAR(30) ;
    
	SELECT u.full_name INTO name
    FROM trainers t 
    JOIN users u ON t.user_id = u.user_id 
    WHERE t.trainer_id = OLD.trainer_id;

	INSERT INTO deleted_trainer_log (trainer_id, name, deleted_at) VALUES (OLD.trainer_id, name, NOW()); 
END $$ 
DELIMITER ;

-- 10 Log Deleted Users
DELIMITER $$ 
CREATE TRIGGER log_deleted_users 
AFTER DELETE ON users 
FOR EACH ROW 
BEGIN 
    DECLARE role_name VARCHAR(15); 
    
    SELECT role_name INTO role_name
    FROM roles
    WHERE role_id = OLD.role_id;
    
    INSERT INTO deleted_users_log (user_id, full_name, email, phone_number, role, deleted_at) VALUES
    (OLD.user_id, OLD.full_name, OLD.email, OLD.phone, role_name, NOW());   
END $$ 
DELIMITER ;

-- 🔹 CATEGORY 4 — UPDATE AUDIT

-- 1️1. Track Role Changes
DELIMITER $$ 
CREATE TRIGGER role_changes_log 
AFTER UPDATE ON users 
FOR EACH ROW 
BEGIN 
	DECLARE old_role_name VARCHAR(50);
    DECLARE new_role_name VARCHAR(50);
    
    SELECT role_name INTO old_role_name 
    FROM roles 
    WHERE role_id = OLD.role_id; 
    
    SELECT role_name INTO new_role_name 
    FROM roles 
    WHERE role_id = NEW.role_id;         
    
    IF OLD.role_id <> NEW.role_id THEN 
		INSERT INTO role_changes_log (user_id, old_role_id, new_role_id, old_role_name, new_role_name, changed_at) VALUES 
		(OLD.user_id, OLD.role_id, NEW.role_id, old_role_name, new_role_name, NOW());
    END IF;
END $$ 
DELIMITER ;

-- 1️2. Track Student Profile Updates
DELIMITER $$ 
CREATE TRIGGER track_student_profile_updates 
AFTER UPDATE ON students 
FOR EACH ROW 
BEGIN 
	IF OLD.qualification <> NEW.qualification OR OLD.college_name <> NEW.college_name OR OLD.graduation_year <> NEW.graduation_year THEN 
		INSERT INTO student_profile_updates_log
        (student_id, old_qualification, new_qualification, old_collage_name, new_collage_name, old_graduation_year, new_graduation_year, updated_at) 
        VALUES
        (OLD.student_id, OLD.qualification, NEW.qualification, OLD.college_name, NEW.college_name, OLD.graduation_year, NEW.graduation_year, NOW()); 
	END IF;
END $$ 
DELIMITER ;

-- ⭐ FINAL INTERVIEW GOLD MASTER TRIGGER

-- 13. Maintain Real-Time Batch Strength
ALTER TABLE batches 
ADD COLUMN current_strength INT DEFAULT 0;

DELIMITER $$ 
CREATE TRIGGER update_batch_strength 
AFTER INSERT ON enrollments 
FOR EACH ROW 
BEGIN 
	UPDATE batches 
    SET current_strength = current_strength + 1
    WHERE batch_id = NEW.batch_id;
END $$ 
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER reduce_batch_strength 
AFTER DELETE ON enrollments 
FOR EACH ROW 
BEGIN 
	UPDATE batches 
    SET current_strength = current_strength - 1
    WHERE batch_id = OLD.batch_id;
END $$ 
DELIMITER ;





























