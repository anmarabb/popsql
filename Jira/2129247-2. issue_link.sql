SELECT
count(*)
FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id

LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id
;

-- the output is 6097


SELECT
count(*)
FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id
LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id
LEFT JOIN `floranow.floranow_jira.issue_link` AS issue_link ON issue.id = issue_link.issue_id
;
--the output is 6766, there is duplcate 
--let us discover some cases for duplcates

SELECT
issue.id,
    count(issue.id)
FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id
LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue ON issue.parent_issue_id = parent_issue.id
LEFT JOIN `floranow.floranow_jira.issue_link` AS issue_link ON issue.id = issue_link.issue_id
group by issue.id
having count(issue.id)>3
;


--we will take this example issue.id=16197

SELECT
project.name as project,
issue.summary,

issue_link.*,
--issue_link_type.*,
FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id
LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id

LEFT JOIN `floranow.floranow_jira.issue_link` AS issue_link ON issue.id = issue_link.issue_id
LEFT JOIN `floranow.floranow_jira.issue_link_type` AS issue_link_type ON issue_link.issue_link_type_id = issue_link_type.id

LEFT JOIN `floranow.floranow_jira.issue` AS issue_link ON issue_link.issue_link_type_id = issue_link_type.id


issue_link.linked_issue_id = issue_link.id

where issue.id='18935'
;