CREATE OR REPLACE FUNCTION add_certificate_on_finished()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем, изменился ли статус на 'finished'
    IF OLD.status = 'active' AND NEW.status = 'finished' THEN
        -- Генерируем уникальный код сертификата
        DECLARE
            cert_code VARCHAR(50);
        BEGIN
            cert_code := 'CERT-' || LPAD((COALESCE((SELECT MAX(certificate_id) FROM certificates), 0) + 1)::TEXT, 3, '0');
            
            -- Вставляем новую запись в таблицу certificates
            INSERT INTO certificates (certificate_id, student_id, course_id, issue_date, certificate_code)
            VALUES (
                (SELECT COALESCE(MAX(certificate_id), 0) + 1 FROM certificates), -- Автоматически генерируем certificate_id
                NEW.student_id,
                NEW.course_id,
                NOW(),
                cert_code
            );
        END;
    END IF;
    -- Возвращаем новую строку (NEW) для обновления
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_add_certificate
AFTER UPDATE ON course_enrollments
FOR EACH ROW
EXECUTE FUNCTION add_certificate_on_finished();


--trigger2
--если ученик выполнил все задания, то статус автоматически становится finished
CREATE OR REPLACE FUNCTION check_course_completion()
RETURNS TRIGGER AS $$
DECLARE
    total_assignments INTEGER;
    completed_assignments INTEGER;
    course_id_val INTEGER;
BEGIN
    -- Получаем ID курса для этого задания
    SELECT m.course_id INTO course_id_val
    FROM modules m
    JOIN assignments a ON m.module_id = a.module_id
    WHERE a.assignment_id = NEW.assignment_id;
    
    -- Считаем общее количество заданий в курсе
    SELECT COUNT(*) INTO total_assignments
    FROM assignments a
    JOIN modules m ON a.module_id = m.module_id
    WHERE m.course_id = course_id_val;
    
    -- Считаем количество выполненных заданий этим студентом
    SELECT COUNT(*) INTO completed_assignments
    FROM submissions sub
    JOIN assignments a ON sub.assignment_id = a.id
    JOIN modules m ON a.module_id = m.id
    WHERE sub.student_id = NEW.student_id
    AND m.course_id = course_id_val;
    
    -- Если все задания выполнены, обновляем статус
    IF completed_assignments >= total_assignments THEN
        UPDATE enrollments
        SET status = 'finished',
            completion_date = CURRENT_DATE
        WHERE student_id = NEW.student_id
        AND course_id = course_id_val;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер, который срабатывает после вставки или обновления сдачи задания
CREATE OR REPLACE TRIGGER trigger_update_course_status
AFTER INSERT OR UPDATE ON submissions
FOR EACH ROW
EXECUTE FUNCTION check_course_completion();

-- триггер 3
-- когда добавляется новая версия курса, старая автоматически становится неактивной
CREATE OR REPLACE FUNCTION deactivate_previous_versions()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE course_versions
    SET is_active = FALSE
    WHERE course_id = NEW.course_id
    AND version_id != NEW.version_id
    AND is_active = TRUE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER deactivate_previous_versions_trigger
AFTER INSERT ON course_versions
FOR EACH ROW
WHEN (NEW.is_active = TRUE)
EXECUTE FUNCTION deactivate_previous_versions();