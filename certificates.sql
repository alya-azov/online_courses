create table certificates(
    certificate_id INT primary key,
    student_id INT NOT null,
    course_id INT NOT null,
    issue_date DATE NOT null,
    certificate_code VARCHAR(50) not null,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
); 

INSERT INTO certificates (certificate_id, student_id, course_id, issue_date, certificate_code) VALUES
(1, 1, 1, '2023-04-20', 'CERT-001'),
(2, 2, 2, '2023-05-25', 'CERT-002'),
(3, 3, 3, '2023-06-30', 'CERT-003'),
(4, 4, 4, '2023-07-05', 'CERT-004'),
(5, 5, 5, '2023-08-15', 'CERT-005'),
(6, 6, 6, '2023-09-20', 'CERT-006'),
(7, 7, 7, '2023-10-25', 'CERT-007'),
(8, 11, 11, '2024-02-20', 'CERT-008'),
(9, 13, 13, '2024-04-05', 'CERT-009'),
(10, 15, 15, '2024-06-15', 'CERT-010'),
(11, 16, 16, '2024-07-20', 'CERT-011'),
(12, 19, 2, '2025-01-05', 'CERT-012'),
(13, 23, 6, '2025-01-25', 'CERT-013'),
(14, 25, 8, '2025-02-05', 'CERT-014'),
(15, 26, 9, '2025-02-10', 'CERT-015'),
(16, 28, 11, '2025-02-20', 'CERT-016'),
(17, 29, 12, '2025-02-25', 'CERT-017'),
(18, 30, 13, '2025-03-30', 'CERT-018'),
(19, 5, 5, '2025-03-10', 'CERT-019'),
(20, 9, 9, '2025-04-30', 'CERT-020'),
(21, 23, 2, '2025-06-01', 'CERT-021');