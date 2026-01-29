-- процедура для записи студента на курс
CREATE OR REPLACE PROCEDURE enroll_student(
    p_student_id INTEGER,
    p_course_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_next_id INTEGER;
BEGIN
    -- Проверка существования студента
    IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = p_student_id) THEN
        RAISE EXCEPTION 'Студент не найден';
    END IF;
    
    -- Проверка существования курса
    IF NOT EXISTS (SELECT 1 FROM courses WHERE course_id = p_course_id) THEN
        RAISE EXCEPTION 'Курс не найден';
    END IF;
    
    -- Проверка дублирования записи
    IF EXISTS (SELECT 1 FROM course_enrollments 
              WHERE student_id = p_student_id AND course_id = p_course_id) THEN
        RAISE EXCEPTION 'Студент уже записан на этот курс';
    END IF;
    
    -- Получение следующего ID
    SELECT COALESCE(MAX(enrollment_id), 0) + 1 INTO v_next_id
    FROM course_enrollments;
    
    -- Вставка записи
    INSERT INTO course_enrollments 
    (enrollment_id, student_id, course_id, enrollment_date, status)
    VALUES 
    (v_next_id, p_student_id, p_course_id, CURRENT_DATE, 'active');
END;
$$;

CALL enroll_student(12, 4);

--рассчет средней оценки по курсу
CREATE OR REPLACE FUNCTION get_course_avg_grade(
    p_course_id INTEGER
)
RETURNS DECIMAL(5,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_avg_grade DECIMAL(6,2);
BEGIN
    SELECT AVG(s.grade) INTO v_avg_grade
    FROM submissions s
    JOIN assignments a ON s.assignment_id = a.assignment_id
    JOIN modules m ON a.module_id = m.module_id
    WHERE m.course_id = p_course_id
    AND s.grade IS NOT NULL;
    
    RETURN COALESCE(v_avg_grade, 0);
END;
$$;

SELECT get_course_avg_grade(5);

-- список студентов по номеру курса
CREATE OR REPLACE FUNCTION get_course_students(
    p_course_id INTEGER
)
RETURNS TABLE (
    student_id INTEGER,
    student_name TEXT,
    enrollment_date DATE,
    status VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.student_id,
        s.first_name || ' ' || s.second_name AS student_name,
        e.enrollment_date,
        e.status
    FROM 
        students s
    JOIN 
        course_enrollments e ON s.student_id = e.student_id
    WHERE 
        e.course_id = p_course_id;
END;
$$;

SELECT * FROM get_course_students(3);