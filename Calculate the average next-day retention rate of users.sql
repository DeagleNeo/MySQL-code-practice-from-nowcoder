#####  1. Mysql version >= 8.x
# 
# SELECT
# (SELECT SUM(consec_days - 1)
# FROM
#     (SELECT device_id, temp_date, COUNT(1) AS consec_days
#     FROM
#         (
#         SELECT device_id, `date`, rn, DATE_SUB(`date`, INTERVAL rn DAY) AS temp_date
#         FROM
#             (SELECT device_id, `date`,
#             ROW_NUMBER() OVER (PARTITION BY device_id ORDER BY `date`) AS rn
#             FROM
#                 (SELECT DISTINCT device_id, `date`
#                 FROM question_practice_detail) de_dup
#             ) rn_added
#         ) temp
#     GROUP BY temp_date, device_id
#     HAVING consec_days > 1) cons
# ) / (
#     SELECT COUNT(DISTINCT device_id, `date`) FROM question_practice_detail
# ) AS avg_ret


#####  2. Mysql version < 8.x

###    Approach 1.

# SELECT
# (SELECT SUM(two_days_count)
# FROM
#     (
#     SELECT
#     device_id,
#     COUNT(CASE WHEN days_in_range >= 2 THEN 1 END) AS two_days_count
#     FROM
#         (
#         SELECT q1.device_id, q1.date, COUNT(*) AS days_in_range
#         FROM 
#             (
#                 SELECT DISTINCT device_id, `date`
#                 FROM question_practice_detail
#             ) q1
#         LEFT JOIN
#             (
#                 SELECT DISTINCT device_id, `date`
#                 FROM question_practice_detail
#             ) q2
#         ON q1.device_id = q2.device_id
#         AND
#         q2.date BETWEEN DATE_SUB(q1.date, INTERVAL 1 DAY) AND q1.date
#         GROUP BY q1.device_id, q1.date
#         ) dates_in_range
#     GROUP BY device_id
#     ) two_days
# ) / (
#     SELECT COUNT(DISTINCT device_id, date)
#     FROM question_practice_detail
# ) AS avg_ret;


###    Approach 2.
SELECT
    (SELECT SUM(two_day_count)
    FROM
        (
            SELECT device_id, COUNT(CASE WHEN consecutive >= 2 THEN 1 END) AS two_day_count
            FROM
            (
                SELECT
                device_id, `date`,
                @consecutive := IF(
                    @prev_user = device_id AND DATEDIFF(`date`, @prev_date) = 1,
                    @consecutive + 1,
                    1
                ) AS consecutive,
                @prev_user := device_id,
                @prev_date := `date`
                FROM    
                (
                    SELECT DISTINCT device_id, `date`
                    FROM question_practice_detail
                    ORDER BY device_id, `date`
                ) sorted,
                (
                    SELECT @prev_user := NULL, @prev_date := NULL, @consecutive := 0
                ) vars
            ) tmp
        GROUP BY device_id
        ) t
    ) / (
        SELECT COUNT(DISTINCT device_id, `date`)
        FROM question_practice_detail
    ) AS avg_ret;
