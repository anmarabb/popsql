SELECT 
user_id,
user_name,
CAST (activity date AS DATE) AS activity_date,
SUM(CASE WHEN activity_type = 'created' AND post_type = 'question' THEN 1 ELSE 0 END) AS question_created,
SUM(CASE WHEN activity_type = 'created' AND post_type = 'answer' THEN 1 ELSE 0 END) AS answer_created,
SUM(CASE WHEN activity_type = 'edited' AND post_type = 'question' THEN 1 ELSE 0 END) AS question _edited,
SUM(CASE WHEN activity_type = 'edited' AND post_type = 'answer' THEN 1 ELSE 0 END) AS answer_edited,
SUM(CASE WHEN activity_type = 'created' THEN 1 ELSE 0 END) AS posts_created,
SUM(CASE WHEN past type = 'question' THEN 1 ELSE 0 END) AS total_questions,
SUM(CASE WHEN post type = 'answer' THEN 1 ELSE 0 END) AS total_answers,
SUM(CASE WHEN activity_type = 'created' AND post_type = 'answer' THEN 1 ELSE 8 END) /
SUM(CASE WHEN activity type = 'created' AND post_type = 'question' THEN 1 ELSE & END) * 1.0 AS answer_to _question_ratio
FROM
SELECT id AS post_id,
'question' AS post_type,
pa.user_id,|
pa.user_name,
pa.activity_date,
pa.activity_type
FROM posts_questions g
INNER JOIN (
SELECT ph.post_id,
ph.user_id,
u.display_name AS user_name,
ph.creation_date AS activity_date,
CASE WHEN ph.post_history_type_id IN (1,2,3) THEN 'created"
WHEN ph.post_history_type_id IN (4,5,6) THEN 'edited"
END AS activity_ type
FROM post_history ph
INNER JOIN users u on u.id = ph.user_id
WHERE
TRUE
AND ph.post_history_type_id BETWEEN 1 AND 6
AND user id > 0 - exclude automated processes
AND user_id IS NOT NULL -exclude deleted accounts
GROUP BY
1,2,3,4,5
ORDER BY
activity_date