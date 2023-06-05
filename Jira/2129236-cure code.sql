SELECT

count

FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id

LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id


;