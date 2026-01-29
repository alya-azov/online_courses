create or replace view student_progress as
select 
    s.student_id as student_id,
    s.first_name || ' ' || s.second_name as student_name,
    c.title as course_name,
    count(a.assignment_id) as total_assignments,
    count(sub.submission_id) as completed_assignments,
    round(count(sub.submission_id) * 100.0 / count(a.assignment_id), 2) as completion_percentage
from 
    students s
join 
    course_enrollments e on s.student_id = e.student_id
join 
    courses c on e.course_id = c.course_id
left join 
    modules m on c.course_id = m.course_id
left join
    assignments a on m.module_id = a.module_id
left join 
    submissions sub on (a.assignment_id = sub.assignment_id AND sub.student_id = s.student_id)
WHERE 
    e.status IN ('active', 'finished')
group by
    s.student_id, c.course_id;

select * from student_progress where student_id = 3;


create or replace view certificates_issued as
select 
    cert.certificate_id as certificate_id,
    cert.issue_date,
    cert.certificate_code,
    s.first_name || ' ' || s.second_name as student_name,
    c.title as course_name,
    c.duration
from 
    certificates cert
join 
    students s on cert.student_id = s.student_id
join 
    courses c on cert.course_id = c.course_id;

select * from certificates_issued where course_name like '%ЕГЭ%';