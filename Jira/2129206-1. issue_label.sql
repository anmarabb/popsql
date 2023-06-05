--befor

SELECT

issue_label.*,

FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id

LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id

LEFT JOIN `floranow.floranow_jira.issue_label` AS issue_label ON issue.id = issue_label.issue_id

where issue.id='15884'

;





WITH prepared_labels AS (
  SELECT
    issue_id,
    MAX(CASE WHEN rn = 1 THEN label END) AS label_1,
    MAX(CASE WHEN rn = 2 THEN label END) AS label_2,
    MAX(CASE WHEN rn = 3 THEN label END) AS label_3,
    MAX(CASE WHEN rn = 4 THEN label END) AS label_4
  FROM (
    SELECT 
      issue_id, 
      label, 
      ROW_NUMBER() OVER (PARTITION BY issue_id ORDER BY label) AS rn
    FROM `floranow.floranow_jira.issue_label`
  )
  GROUP BY issue_id
)
SELECT 
  prepared_labels.*,
FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id
LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue ON issue.parent_issue_id = parent_issue.id
LEFT JOIN prepared_labels ON issue.id = prepared_labels.issue_id
where issue.id='15884'

;





SELECT

issue_label.*,
FROM `floranow.floranow_jira.issue_label` AS issue_label 

FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id

LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id

LEFT JOIN `floranow.floranow_jira.issue_label` AS issue_label ON issue.id = issue_label.issue_id