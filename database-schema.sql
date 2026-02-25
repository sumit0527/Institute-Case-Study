-- Create Database
CREATE DATABASE datalogger_training_db;

-- Use that database
USE datalogger_training_db;

-- Roles Table 
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

-- Users Table (Login System)
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    phone VARCHAR(15),
    status ENUM('active','inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- Students Table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE,
    qualification VARCHAR(100),
    college_name VARCHAR(150),
    graduation_year YEAR,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Trainers Table
CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE,
    expertise VARCHAR(200),
    experience_years INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
	
-- Course Categories
CREATE TABLE course_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) UNIQUE
);

-- Courses Table
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    course_name VARCHAR(150),
    duration_months INT,
    course_fee DECIMAL(10,2),
    description TEXT,
    status ENUM('active','inactive') DEFAULT 'active',
    FOREIGN KEY (category_id) REFERENCES course_categories(category_id)
);

-- Batches Table
CREATE TABLE batches (
    batch_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT,
    batch_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    mode ENUM('Online','Offline','Hybrid'),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Batch Trainers (Many-to-Many)
CREATE TABLE batch_trainers (
    batch_id INT,
    trainer_id INT,
    PRIMARY KEY (batch_id, trainer_id),
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

-- Enrollments Table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    batch_id INT,
	enrollment_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('active','completed','dropped') DEFAULT 'active',
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
);

-- Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT,
    amount DECIMAL(10,2),
    payment_mode ENUM('UPI','Card','Cash','NetBanking'),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('success','pending','failed'),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

-- Attendance Table
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT,
    attendance_date DATE,
    status ENUM('present','absent'),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

-- Certificates Table
CREATE TABLE certificates (
    certificate_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT UNIQUE,
    issue_date DATE,
    certificate_url VARCHAR(255),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

-- Enquiries / Leads Table
CREATE TABLE enquiries (
    enquiry_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15),
    interested_course VARCHAR(150),
    enquiry_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('new', 'contacted', 'converted', 'lost') DEFAULT 'new'
);

-- Students Logs
CREATE TABLE deleted_student_log 
(
	  log_id INT PRIMARY KEY AUTO_INCREMENT
	, student_id INT 
    , name VARCHAR(50) 
    , deleted_at DATETIME DEFAULT NOW() 
);

-- Trainers Logs
CREATE TABLE deleted_trainers_log 
(
	  log_id INT PRIMARY KEY AUTO_INCREMENT
	, trainer_id INT 
    , name VARCHAR(50) 
    , deleted_at DATETIME DEFAULT NOW() 
);

-- Users Logs
CREATE TABLE deleted_users_log 
(
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone_number VARCHAR(15),
    role ENUM('Student', 'Trainer', 'Admin', 'Counselor'),
    deleted_at DATETIME DEFAULT NOW()
);
 
-- Roles Logs
CREATE TABLE role_changes_log 
(
      log_id INT PRIMARY KEY AUTO_INCREMENT
    , user_id INT
    , old_role_id INT
    , new_role_id INT
    , old_role_name VARCHAR(20)
    , new_role_name VARCHAR(20)
    , changed_at DATETIME DEFAULT NOW()
    , FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Student Profile Logs
CREATE TABLE student_profile_updates_log 
(
      log_id INT PRIMARY KEY AUTO_INCREMENT
    , student_id INT
    , old_qualification VARCHAR(100)
    , new_qualification VARCHAR(100)
    , old_college_name VARCHAR(100)
    , new_college_name VARCHAR(100)
    , old_graduation_year INT
    , new_graduation_year INT
    , updated_at DATETIME DEFAULT NOW()
    , FOREIGN KEY (student_id) REFERENCES students(student_id)
);


-- Insert Database Data

-- Roles
INSERT INTO roles (role_name) VALUES
('Admin'),
('Trainer'),
('Student'),
('Counselor');

-- Users
INSERT INTO users (role_id, full_name, email, password, phone) VALUES
(1, 'Institute Admin', 'admin@datalogger.com', 'admin123', '9999999999'),
(2, 'Rahul Sharma', 'rahul.trainer@datalogger.com', 'trainer123', '9876543210'),
(2, 'Neha Verma', 'neha.trainer@datalogger.com', 'trainer123', '9876543222'),
(3, 'Amit Patil', 'amit.student@gmail.com', 'student123', '9123456780'),
(3, 'Sneha Kulkarni', 'sneha.student@gmail.com', 'student123', '9123456781'),
(3, 'Rohit Singh', 'rohit.student@gmail.com', 'student123', '9123456782'),
(3, 'Pooja Mehta', 'pooja.student@gmail.com', 'student123', '9123456783'),
(4, 'Anjali Counselor', 'anjali@datalogger.com', 'counselor123', '9012345678');

-- Students
INSERT INTO students (user_id, qualification, college_name, graduation_year) VALUES
(4, 'B.Sc Computer Science', 'Mumbai University', 2023),
(5, 'BCA', 'Pune University', 2022),
(6, 'B.Tech IT', 'Delhi University', 2024),
(7, 'MBA', 'Symbiosis Institute', 2021);


-- Trainers
INSERT INTO trainers (user_id, expertise, experience_years) VALUES
(2, 'Python, Data Science, SQL', 6),
(3, 'Web Development, PHP, MySQL', 5);

-- Course Categories
INSERT INTO course_categories (category_name) VALUES
('Programming'),
('Data Science'),
('AIML'),
('Web Development');

-- Courses
INSERT INTO courses (category_id, course_name, duration_months, course_fee, description) VALUES
(1, 'Python Programming', 3, 15000, 'Core Python with problem solving'),
(2, 'Data Science with Python', 6, 45000, 'Data analysis, visualization, ML'),
(3, 'AI & Machine Learning', 6, 55000, 'ML algorithms and real projects'),
(4, 'Full Stack Web Development', 6, 50000, 'HTML, CSS, JS, PHP, MySQL');

-- Batches
INSERT INTO batches (course_id, batch_name, start_date, end_date, mode) VALUES
(1, 'PY_JAN_2025', '2025-01-10', '2025-04-10', 'Offline'),
(2, 'DS_FEB_2025', '2025-02-01', '2025-08-01', 'Hybrid'),
(4, 'FS_MAR_2025', '2025-03-05', '2025-09-05', 'Offline');

-- Batch Trainers
INSERT INTO batch_trainers (batch_id, trainer_id) VALUES
(1, 1),
(2, 1),
(3, 2);

-- Enrollments
INSERT INTO enrollments (student_id, batch_id, enrollment_date, status) VALUES
(1, 1, '2025-01-05', 'active'),
(2, 2, '2025-01-20', 'active'),
(3, 2, '2025-01-22', 'active'),
(4, 3, '2025-02-25', 'completed');

-- Payments
INSERT INTO payments (enrollment_id, amount, payment_mode, payment_status) VALUES
(1, 15000, 'UPI', 'success'),
(2, 20000, 'Card', 'success'),
(2, 25000, 'UPI', 'success'),
(3, 45000, 'NetBanking', 'success'),
(4, 50000, 'Cash', 'success');

-- Attendance
INSERT INTO attendance (enrollment_id, attendance_date, status) VALUES
(1, '2025-01-12', 'present'),
(1, '2025-01-13', 'present'),
(1, '2025-01-14', 'absent'),
(2, '2025-02-05', 'present'),
(2, '2025-02-06', 'present'),
(3, '2025-02-05', 'absent'),
(3, '2025-02-06', 'present');

-- Certificates
INSERT INTO certificates (enrollment_id, issue_date, certificate_url) VALUES
(4, '2025-09-10', 'certificates/fs_rohit.pdf');

-- Enquiries
INSERT INTO enquiries (name, email, phone, interested_course, status) VALUES
('Karan Joshi', 'karan@gmail.com', '9000011111', 'Data Science with Python', 'new'),
('Riya Shah', 'riya@gmail.com', '9000022222', 'Full Stack Web Development', 'contacted'),
('Manish Gupta', 'manish@gmail.com', '9000033333', 'AI & Machine Learning', 'converted');

SELECT * FROM attendance;
SELECT * FROM batch_trainers;
SELECT * FROM batches;
SELECT * FROM certificates;
SELECT * FROM course_categories;
SELECT * FROM courses;
SELECT * FROM enquiries;
SELECT * FROM enrollments;
SELECT * FROM payments;
SELECT * FROM roles;
SELECT * FROM students; 
SELECT * FROM trainers;
SELECT * FROM users;
SELECT * FROM deleted_student_log;
SELECT * FROM deleted_trainers_log;
SELECT * FROM deleted_users_log;
SELECT * FROM role_changes_log;
SELECT * FROM student_profile_updates_log;
















 
































