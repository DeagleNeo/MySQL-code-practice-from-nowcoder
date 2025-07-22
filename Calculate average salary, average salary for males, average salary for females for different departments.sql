WITH
    join_table AS (
        SELECT DISTINCT
            i.staff_gender,
            i.department,
            s.normal_salary,
            s.dock_salary
        FROM
            staff_tb i
            INNER JOIN salary_tb s ON i.staff_id = s.staff_id
    ),
    t1 AS (
        SELECT
            department,
            ROUND(AVG(normal_salary - dock_salary), 2) AS average_actual_salary,
            CAST(ROUND(COALESCE(
                AVG(
                    IF(
                        staff_gender = 'male',
                        normal_salary - dock_salary,
                        NULL
                    )
                ),
                0
            ), 2) AS DECIMAL(10,2)) AS average_actual_salary_male,
            CAST(ROUND(COALESCE(
                AVG(
                    IF(
                        staff_gender = 'female',
                        normal_salary - dock_salary,
                        NULL
                    )
                ),
                0
            ), 2) AS DECIMAL(10,2)) AS average_actual_salary_female
        FROM
            join_table
        GROUP BY
            department
    )

SELECT * FROM t1
ORDER BY average_actual_salary DESC
