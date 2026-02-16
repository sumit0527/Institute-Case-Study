# 📘 Institute Case Study

## 🏢 Project Overview:

This repository contains a comprehensive SQL case study based on a real-world training institute model — Datalogger Info Solution.
The project simulates complete institute operations including:
-  Student lifecycle management
-  Course and batch management
-  Trainer allocation
-  Payment processing
-  Attendance monitoring
-  Certificate issuance
-  Lead & enquiry trackin

The objective of this project is to design a structured relational database system and generate business insights using SQL.

## 📊 Business Context:

As the institute expanded, managing operational data manually became inefficient.
Management required answers to critical questions such as:

-  Which courses generate the highest revenue?
-  What is the monthly enrollment growth trend?
-  Are there students at risk due to low attendance?
-  Which trainers are overloaded?
-  What is the lead-to-enrollment conversion rate?
-  How many payments are pending?

To solve this, a structured SQL database was designed to enable data-driven decision-making.

---

## 🧱 Database Architecture

The database models real-world institute operations and includes:

### 🧑‍💼 `roles` Table

Stores different user roles in the system.

**Columns:**
- `role_id` : Unique identifier for the role
- `role_name` : Name of the role (Admin, Trainer, Student, Counselor)

---

### 👤 `users` Table

Stores login and basic profile information for all users.

**Columns:**

- **`user_id`** : Unique ID of the user
- **`role_id`** : Role assigned to the user
- **`full_name`** : Full name of the user
- **`email`** : Email address (unique)
- **`password`** : Encrypted password
- **`phone`** : Contact number
- **`status`** : Account status (active / inactive)
- **`created_at`** : Account creation timestamp

---

### 🎓 `students` Table

Stores additional details specific to students.

**Columns:**

- **`student_id`** : Unique ID of the student
- **`user_id`** : Reference to users table
- **`qualification`** : Highest qualification
- **`college_name`** : College or university name
- **`graduation_year`** : Year of graduation

---

### 🧑‍🏫 `trainers` Table

Stores trainer-specific professional information.

**Columns:**

- **`trainer_id`** : Unique ID of the trainer
- **`user_id`** : Reference to users table
- **`expertise`** : Technologies or subjects handled
- **`experience_years`** : Years of experience

---

### 📚 `course_categories` Table

Defines categories under which courses are grouped.

**Columns:**

- **`category_id`** : Unique ID of the category
- **`category_name`** : Category name (Programming, Data Science, AIML, etc.)

---

### 📘 `courses` Table

Stores details of courses offered by the institute.

**Columns:**

- **`course_id`** : Unique ID of the course
- **`category_id`** : Reference to course category
- **`course_name`** : Name of the course
- **`duration_months`** : Course duration
- **`course_fee`** : Total course fee
- **`description`** : Course overview
- **`status`** : Course status (active / inactive)

---

### 🗓 `batches` Table

Represents individual batches for courses.

**Columns:**

- **`batch_id`** : Unique ID of the batch
- **`course_id`** : Reference to courses table
- **`batch_name`** : Batch identifier
- **`start_date`** : Batch start date
- **`end_date`** : Batch end date
- **`mode`** : Mode of training (Online / Offline / Hybrid)

---

### 🔗 `batch_trainers` Table

Maps trainers to batches (many-to-many relationship).

**Columns:**

- **`batch_id`** : Reference to batches table
- **`trainer_id`** : Reference to trainers table

---

### 📝 `enrollments` Table

Tracks student enrollment in batches.

**Columns:**

- **`enrollment_id`** : Unique ID of the enrollment
- **`student_id`** : Reference to students table
- **`batch_id`** : Reference to batches table
- **`enrollment_date`** : Date of enrollment
- **`status`** : Enrollment status (active, completed, dropped)

---

### 💳 `payments` Table

Stores payment transactions made by students.

**Columns:**

- **`payment_id`** : Unique ID of the payment
- **`enrollment_id`** : Reference to enrollments table
- **`amount`** : Amount paid
- **`payment_mode`** : Mode of payment (UPI, Card, Cash, NetBanking)
- **`payment_date`** : Payment timestamp
- **`payment_status`** : Status (success, pending, failed)

---

### 📅 `attendance` Table

Tracks daily attendance of students.

**Columns:**

- **`attendance_id`** : Unique ID of attendance record
- **`enrollment_id`** : Reference to enrollments table
- **`attendance_date`** : Date of attendance
- **`status`** : Attendance status (present / absent)

---

### 📜 `certificates` Table

Stores certificate issuance details.

**Columns:**

- **`certificate_id`** : Unique ID of certificate
- **`enrollment_id`** : Reference to enrollments table
- **`issue_date`** : Certificate issue date
- **`certificate_url`** : Certificate file path or URL

---

### 📞 `enquiries` Table

Captures leads and enquiries from potential students.

**Columns:**

- **`enquiry_id`** : Unique ID of enquiry
- **`name`** : Name of the enquirer
- **`email`** : Email address
- **`phone`** : Contact number
- **`interested_course`** : Course of interest
- **`enquiry_date`** : Date of enquiry
- **`status`** : Enquiry status (new, contacted, converted, lost)

--- 

## 📈 Business Case Study Questions Solved

## 🧠 SECTION 1: Revenue & Business Performance

### Case 1: Overall Business Health

#### Question:
Management wants to understand how much total revenue the institute has generated so far from successful payments.


### Case 2: Revenue Trend Analysis

#### Question:
The finance team wants to track revenue growth over time to identify peak admission months.


### Case 3: Course Profitability

#### Question:
Not all courses perform equally. Management wants to know which courses contribute the most to revenue.

## 🎓 SECTION 2: Student Enrollment Insights

### Case 4: Course Popularity

#### Question:
The academic team wants to know which courses are attracting the most students.


### Case 5: Student Lifecycle Status

#### Question:
To improve retention, management wants a snapshot of how many students are currently active, completed, or dropped.


### Case 6: Upskilling Behavior

#### Question:
Some students enroll in multiple courses. Identifying them helps in targeted marketing.

## 🧑‍🏫 SECTION 3: Trainer & Batch Performance

### Case 7: Trainer Workload

#### Question:
Management wants to ensure trainers are not overloaded or underutilized.


### Case 8: Trainer Impact

#### Question:
Which trainers are handling the most students across all their batches?

## SECTION 4: Attendance & Engagement

### Case 9: Student Engagement

#### Question:
Regular attendance is critical for course completion.


### Case 10: At-Risk Students

#### Question:
Students with attendance below 75% are at risk of dropping out.

## 💳 SECTION 5: Payments & Financial Risk

### Case 11: Outstanding Dues

#### Question:
The accounts team wants to identify students who have not fully paid their course fees.


### Case 12: Installment Patterns

#### Question:
Many students prefer installment payments. Management wants to analyze this trend.

## 📜 SECTION 6: Certification & Completion

### Case 13: Certification Gaps

#### Question:
Some students have completed courses but haven’t received certificates yet.

## 📞 SECTION 7: Marketing & Lead Analysis

### Case 14: Lead Conversion Effectiveness

#### Question:
Marketing wants to measure how effective enquiries are turning into enrollments.

### Case 15: Demand Forecasting

#### Question:
To plan future batches, management wants to know which courses receive the most enquiries.

## ⭐ SECTION 8: Strategic Decisions (Advanced)

### Case 16: Revenue Focus Strategy

#### Question:
Management wants to focus marketing and trainer allocation on top-performing courses.

--- 

## 🛠️ How to Use
-  Run the provided SQL script (when available) in your favorite RDBMS (PostgreSQL, MySQL, etc.).
-  Review each problem statement.
-  Write and run SQL queries to find answers.
-  Cross-check with the solution script for learning and validation.

---

## 🎯 Outcomes & Insights

Using this database system, management can:

-  Monitor revenue and financial performance
-  Identify popular courses
-  Track enrollment growth
-  Detect inactive courses
-  Ensure data accuracy automatically
-  Prevent duplicate or invalid enrollments

The system ensures both operational control and analytical visibility.

---

## 🛠 Technologies Used

-  MySQL
-  SQL (DDL, DML, Joins, Aggregations)
-  Triggers
-  Constraints (Primary Key, Foreign Key, Unique)

---

## 👨‍💻 Author
Sumit Patil

This project demonstrates practical database design, business logic implementation, and analytical SQL problem-solving skills.














