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
issue.summary as issue,


linked_issue.summary as linked_issue,
linked_issue_project.name as linked_issue_project,

FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id
LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id

LEFT JOIN `floranow.floranow_jira.issue_link` AS issue_link ON issue.id = issue_link.issue_id
LEFT JOIN `floranow.floranow_jira.issue_link_type` AS issue_link_type ON issue_link.issue_link_type_id = issue_link_type.id

LEFT JOIN `floranow.floranow_jira.issue` AS linked_issue ON linked_issue.id = issue_link.linked_issue_id
LEFT JOIN `floranow.floranow_jira.project` AS linked_issue_project ON linked_issue.project_id = linked_issue_project.id


where issue.id='18935'
;





WITH aggregated_labels AS (
  SELECT
    issue_id,
    STRING_AGG(label) as labels
  FROM `floranow.floranow_jira.issue_label`
  GROUP BY issue_id
)
SELECT
issue.id as issue_id,
issue.created,
project.name as project,
issue.issue_type_name as issue_type,
issue.summary as issue,
issue.description,

parent_issue.summary as parent_issue,
parent_issue.description as parent_description,


issue.status_name,
issue.custom_epic_name,
issue.key as issue_key,
assignee_account.display_name as  assignee_to,
creator_account.display_name as created_by,
concat ('https://floranow.atlassian.net/browse/',issue.key) as issue_link,

aggregated_labels.labels,

linked_issue.summary as linked_issue,
linked_issue_project.name as linked_issue_project,

FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id
LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id

LEFT JOIN `floranow.floranow_jira.issue_link` AS issue_link ON issue.id = issue_link.issue_id
LEFT JOIN `floranow.floranow_jira.issue_link_type` AS issue_link_type ON issue_link.issue_link_type_id = issue_link_type.id

LEFT JOIN `floranow.floranow_jira.issue` AS linked_issue ON linked_issue.id = issue_link.linked_issue_id
LEFT JOIN `floranow.floranow_jira.project` AS linked_issue_project ON linked_issue.project_id = linked_issue_project.id

LEFT JOIN aggregated_labels ON issue.id = aggregated_labels.issue_id

;


WITH aggregated_labels AS (
  SELECT
    issue_id,
    STRING_AGG(label) as labels
  FROM `floranow.floranow_jira.issue_label`
  GROUP BY issue_id
),
aggregated_issue_link AS (

  SELECT
    issue_link.issue_id,
    STRING_AGG(linked_issue.summary) as linked_issue_id
  FROM `floranow.floranow_jira.issue_link` as issue_link
  LEFT JOIN `floranow.floranow_jira.issue_link_type` AS issue_link_type ON issue_link.issue_link_type_id = issue_link_type.id 
  LEFT JOIN `floranow.floranow_jira.issue` AS linked_issue ON linked_issue.id = issue_link.linked_issue_id
  LEFT JOIN `floranow.floranow_jira.project` AS linked_issue_project ON linked_issue.project_id = linked_issue_project.id

  GROUP BY 1


)

SELECT
issue.id as issue_id,
issue.created,
project.name as project,
issue.issue_type_name as issue_type,
issue.summary as issue,
issue.description,

parent_issue.summary as parent_issue,
parent_issue.description as parent_description,


issue.status_name,
issue.custom_epic_name,
issue.key as issue_key,
assignee_account.display_name as  assignee_to,
creator_account.display_name as created_by,
concat ('https://floranow.atlassian.net/browse/',issue.key) as issue_link,

aggregated_labels.labels,

linked_issue.summary as linked_issue,
linked_issue_project.name as linked_issue_project,

FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id
LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id

LEFT JOIN `floranow.floranow_jira.issue_link` AS issue_link ON issue.id = issue_link.issue_id
LEFT JOIN `floranow.floranow_jira.issue_link_type` AS issue_link_type ON issue_link.issue_link_type_id = issue_link_type.id

LEFT JOIN `floranow.floranow_jira.issue` AS linked_issue ON linked_issue.id = issue_link.linked_issue_id
LEFT JOIN `floranow.floranow_jira.project` AS linked_issue_project ON linked_issue.project_id = linked_issue_project.id

LEFT JOIN aggregated_labels ON issue.id = aggregated_labels.issue_id

;