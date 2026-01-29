-- поиск проверенных работ
create index idx_submissions_grade on submissions (grade) where grade is not null;

EXPLAIN analyze
SELECT * FROM submissions 
ORDER BY grade DESC
LIMIT 100;

-- оиск по фамилии студента
CREATE INDEX idx_students_name ON students (first_name, second_name);

EXPLAIN ANALYZE
SELECT * FROM students
WHERE first_name = 'Милена' AND second_name = 'Евлахова';