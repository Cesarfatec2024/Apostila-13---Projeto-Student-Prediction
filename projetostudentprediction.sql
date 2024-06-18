-- Active: 1718629280013@@127.0.0.1@5432@Projeto Student Prediction
-- 1.2
CREATE TABLE tb_student_prediction(
	cod_student_prediction SERIAL PRIMARY KEY,
	age INT,
	gender VARCHAR(100),
	salary VARCHAR(100),
	prep_exam VARCHAR(200),
	notes VARCHAR(100),
	grade VARCHAR(100)
);

SELECT * FROM tb_student_prediction;


-- 1.4.1
CREATE OR REPLACE PROCEDURE teste_contagem_maiores_idade()
LANGUAGE plpgsql
AS $$
DECLARE
    total_maiores_idade INT := 0;
    idade_atual INT;
BEGIN
    FOR idade_atual IN SELECT age FROM tb_student_prediction LOOP
        IF idade_atual >= 18 THENtb_student_prediction
            total_maiores_idade := total_maiores_idade + 1;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'O número de estudantes maiores de idade é %', total_maiores_idade;
END;
$$;

CALL teste_contagem_maiores_idade();

      
--1.4.2
CREATE OR REPLACE PROCEDURE percentage_students_by_gender()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Male: %', (SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM student_performance)) FROM student_performance WHERE gender = 'Male');
    RAISE NOTICE 'Female: %', (SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM student_performance)) FROM student_performance WHERE gender = 'Female');
END;
$$;

-- Bloco anônimo de teste:
DO $$
BEGIN
    CALL percentage_students_by_gender();
END;
$$;


-- 1.4.3
CREATE OR REPLACE PROCEDURE percentage_grades_by_gender(gender IN VARCHAR(10), grade_A OUT FLOAT, grade_B OUT FLOAT, grade_C OUT FLOAT, grade_D OUT FLOAT, grade_F OUT FLOAT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM student_performance WHERE gender = gender))
    INTO grade_A
    FROM student_performance
    WHERE gender = gender AND grade = 'A';
    
    SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM student_performance WHERE gender = gender))
    INTO grade_B
    FROM student_performance
    WHERE gender = gender AND grade = 'B';
    
    SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM student_performance WHERE gender = gender))
    INTO grade_C
    FROM student_performance
    WHERE gender = gender AND grade = 'C';
    
    SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM student_performance WHERE gender = gender))
    INTO grade_D
    FROM student_performance
    WHERE gender = gender AND grade = 'D';
    
    SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM student_performance WHERE gender = gender))
    INTO grade_F
    FROM student_performance
    WHERE gender = gender AND grade = 'F';
END;
$$;

-- Bloco anônimo de teste:
DO $$
DECLARE
    grade_A FLOAT;
    grade_B FLOAT;
    grade_C FLOAT;
    grade_D FLOAT;
    grade_F FLOAT;
BEGIN
    CALL percentage_grades_by_gender('Male', grade_A, grade_B, grade_C, grade_D, grade_F);
    RAISE NOTICE 'Grades for Male - A: %, B: %, C: %, D: %, F: %', grade_A, grade_B, grade_C, grade_D, grade_F;
END;
$$;


-- 1.5.1

CREATE OR REPLACE FUNCTION all_students_above_income_approved() RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    result BOOLEAN;
BEGIN
    SELECT CASE WHEN COUNT(*) = 0 THEN TRUE ELSE FALSE END
    INTO result
    FROM student_performance
    WHERE income > 410 AND grade <= 0;
    
    RETURN result;
END;
$$;

-- Bloco anônimo de teste:
DO $$
DECLARE
    result BOOLEAN;
BEGIN
    result := all_students_above_income_approved();
    RAISE NOTICE 'All students above income 410 approved: %', result;
END;
$$;


-- 1.5.2

CREATE OR REPLACE FUNCTION students_with_notes_approved() RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    total_students INTEGER;
    approved_students INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students FROM student_performance WHERE notes IS NOT NULL;
    SELECT COUNT(*) INTO approved_students FROM student_performance WHERE notes IS NOT NULL AND grade > 0;
    
    RETURN (approved_students * 100.0 / total_students) >= 70;
END;
$$;

-- Bloco anônimo de teste:
DO $$
DECLARE
    result BOOLEAN;
BEGIN
    result := students_with_notes_approved();
    RAISE NOTICE 'At least 70%% of students with notes approved: %', result;
END;
$$;


-- 1.5.3

CREATE OR REPLACE FUNCTION percentage_students_prepared_midterm_approved() RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    total_students INTEGER;
    approved_students INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students FROM student_performance WHERE midterm_preparation IS NOT NULL;
    SELECT COUNT(*) INTO approved_students FROM student_performance WHERE midterm_preparation IS NOT NULL AND grade > 0;
    
    RETURN (approved_students * 100.0 / total_students);
END;
$$;

-- Bloco anônimo de teste:
DO $$
DECLARE
    result FLOAT;
BEGIN
    result := percentage_students_prepared_midterm_approved();
    RAISE NOTICE 'Percentage of students prepared for midterm and approved: %', result;
END;
$$;
