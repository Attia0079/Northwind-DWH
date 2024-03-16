DROP FUNCTION IF EXISTS sliver_layer.handle_employee_operations();

CREATE OR REPLACE FUNCTION sliver_layer.handle_employee_operations()
RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO sliver_layer.employees_transformed (employee_id, emplyee_name, title, hire_date, reports_to)
        VALUES (NEW.employee_id, TRIM(LOWER(CONCAT(NEW.first_name, ' ', NEW.last_name))), TRIM(LOWER(NEW.title)), NEW.hire_date, NEW.reports_to);
	ELSIF TG_OP = 'UPDATE' THEN
        UPDATE sliver_layer.employees_transformed
        SET 
			emplyee_name = COALESCE(TRIM(LOWER(CONCAT(NEW.first_name, ' ', NEW.last_name))), emplyee_name),
            title = COALESCE(TRIM(LOWER(NEW.title)), title),
            hire_date = COALESCE(NEW.hire_date, hire_date),
            reports_to = COALESCE(NEW.reports_to, reports_to)
        WHERE employee_id = NEW.employee_id;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO anonymous_deleted_schema.employees_rubbish
        SELECT OLD.*;
    END IF;

    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER handle_employee_operations_trigger
AFTER INSERT OR UPDATE OR DELETE ON bronze_layer.employees_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.handle_employee_operations();

SELECT * FROM bronze_layer.employees_raw;

INSERT INTO bronze_layer.employees_raw (employee_id, last_name, first_name, title, hire_date, reports_to)
VALUES (10, 'Doe', 'John', 'Sales Representitive', '2023-01-01', 5);

UPDATE bronze_layer.employees_raw
SET title = 'Senior Sales Representitive'
WHERE employee_id = 10;

DELETE FROM bronze_layer.employees_raw
WHERE employee_id = 10;

SELECT * FROM sliver_layer.employees_transformed;
SELECT * FROM anonymous_deleted_schema.employees_rubbish