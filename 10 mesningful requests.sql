--запрос1
--список активных курсов с количеством записавшихся студентов
SELECT 
    c.course_id, 
    c.title, 
    COUNT(z.student_id) AS amount_of_students
FROM 
    courses c
LEFT JOIN 
    course_enrollments z ON c.course_id = z.course_id AND z.status = 'active'
GROUP BY 
    c.course_id, c.title
HAVING 
    COUNT(z.student_id) > 0
ORDER BY 
    amount_of_students DESC;

--запрос2
--количество преподавателей у каждого курса
SELECT 
    c.course_id AS id_курса,
    c.title AS название,
    COUNT(t.teacher_id) AS количество_преподавателей
FROM 
    courses c
JOIN 
    teacher t ON c.course_id = t.course_id
GROUP BY 
    c.course_id, c.title
ORDER BY 
    количество_преподавателей DESC, название;

--запрос3
--студенты с лучшими оценками по курсу
WITH средние_оценки AS (
    SELECT
        c.course_id AS course_id,
        c.title AS курс,
        s.first_name || ' ' || s.second_name AS студент,
        AVG(sub.grade) AS средняя_оценка,
        RANK() OVER (PARTITION BY c.course_id ORDER BY AVG(sub.grade) DESC) AS ранг
    FROM 
        students s
    JOIN 
        submissions sub ON s.student_id = sub.student_id
    JOIN 
        assignments a ON sub.assignment_id = a.assignment_id
    JOIN 
        modules m ON a.module_id = m.module_id
    JOIN 
        courses c ON m.course_id = c.course_id
    GROUP BY 
        c.course_id, c.title, s.student_id, s.first_name, s.second_name
)
SELECT
    курс,
    course_id,
    студент,
    ROUND(средняя_оценка, 2) AS лучшая_средняя_оценка
FROM
    средние_оценки
WHERE
    ранг = 1
ORDER by
    лучшая_средняя_оценка DESC;

--запрос 4
--студенты не сдавшие ни 1 задания
SELECT 
    c.course_id AS course_id,
    c.title AS course_name,
    s.student_id AS student_id,
    s.first_name || ' ' || s.second_name AS student_name
FROM 
    course_enrollments e
JOIN 
    courses c ON e.course_id = c.course_id
JOIN 
    students s ON e.student_id = s.student_id
LEFT JOIN 
    submissions sub ON sub.student_id = s.student_id
                    AND sub.assignment_id IN (
                        SELECT a.assignment_id 
                        FROM assignments a
                        JOIN modules m ON a.module_id = m.module_id
                        WHERE m.course_id = c.course_id
                    )
WHERE 
    sub.submission_id IS NULL
    AND e.status = 'active'
ORDER BY 
    c.title, s.second_name, s.first_name;

--запрос5
--количество модулей и заданий для каждого курса
SELECT 
    c.title,
    (SELECT COUNT(*) FROM modules WHERE course_id = c.course_id) AS количество_модулей,
    (SELECT COUNT(*) FROM assignments a JOIN modules m ON a.module_id = m.module_id WHERE m.course_id = c.course_id) AS количество_заданий
FROM 
    courses c
ORDER BY 
    количество_модулей DESC, количество_заданий DESC;

--запрос6
--курсы с самым высоким процентом завершения
SELECT 
    c.course_id,
    c.title,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.status = 'finished' THEN e.student_id END) / 
          COUNT(DISTINCT e.student_id), 2) AS completion_rate
FROM 
    courses c
LEFT JOIN 
    course_enrollments e ON c.course_id = e.course_id
GROUP BY 
    c.course_id, c.title
ORDER BY 
    completion_rate desc
limit 5;

--запрос7
--количество новых людей в месяц
SELECT
    DATE_TRUNC('month', registration_date) AS месяц,
    COUNT(*) AS количество_новых_учеников
FROM
    students
GROUP BY
    DATE_TRUNC('month', registration_date)
ORDER BY
    месяц;

--запрос8
--количество общих студентов у курсов
SELECT 
    c1.title AS курс_1,
    c2.title AS курс_2,
    COUNT(DISTINCT e1.student_id) AS общие_студенты
FROM 
    course_enrollments e1
JOIN 
    courses c1 ON e1.course_id = c1.course_id
JOIN 
    course_enrollments e2 ON e1.student_id = e2.student_id AND e1.course_id < e2.course_id
JOIN 
    courses c2 ON e2.course_id = c2.course_id
GROUP BY 
    c1.course_id, c1.title, c2.course_id, c2.title
HAVING 
    COUNT(DISTINCT e1.student_id) > 1
ORDER BY 
    общие_студенты DESC;

--запрос9
--средний балл,колчество сданых заданий и количество сдававших учеников по курсу
SELECT 
    c.course_id AS course_id,
    c.title AS course_name,
    ROUND(AVG(sub.grade), 2) AS average_grade,
    COUNT(DISTINCT sub.student_id) AS students_with_grades,
    COUNT(sub.submission_id) AS submissions_count
FROM 
    courses c
JOIN 
    modules m ON c.course_id = m.course_id
JOIN 
    assignments a ON m.module_id = a.module_id
JOIN 
    submissions sub ON a.assignment_id = sub.assignment_id
GROUP BY 
    c.course_id, c.title
ORDER BY 
    average_grade DESC;

--запрос10
--наконец
--10 это мало сделаю за час...
--язык мне оторвать
--время выполнения на задание и среднее по курсу
SELECT 
    c.title AS курс,
    m.title AS модуль,
    a.title AS задание,
    a.due_date,
    AVG(a.due_date) OVER (PARTITION BY c.course_id) AS среднее_по_курсу
FROM 
    assignments a
JOIN 
    modules m ON a.module_id = m.module_id
JOIN 
    courses c ON m.course_id = c.course_id
ORDER BY 
    c.title, m.title;
