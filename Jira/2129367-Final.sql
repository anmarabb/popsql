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
    max(issue.key) as parent_issue_key,
    max(issue.summary) as parent_issue,
      max(project.name) as parent_project,
max(project.name) as parent_project,
      parent_issue.summary as parent_issue,
    --STRING_AGG(linked_issue_id, '\n\n') as linked_issue_ids,
    STRING_AGG(linked_issue.summary, '\n\n') as linked_issues,
    STRING_AGG(linked_issue.key, '\n\n') as linked_issue_keys,

     
  FROM `floranow.floranow_jira.issue_link` as issue_link
  LEFT JOIN `floranow.floranow_jira.issue_link_type` AS issue_link_type ON issue_link.issue_link_type_id = issue_link_type.id 
  LEFT JOIN `floranow.floranow_jira.issue` AS linked_issue ON linked_issue.id = issue_link.linked_issue_id
  LEFT JOIN `floranow.floranow_jira.project` AS linked_issue_project ON linked_issue.project_id = linked_issue_project.id

  LEFT JOIN `floranow.floranow_jira.issue` AS issue ON issue.id = issue_link.issue_id
  LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id

  LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id


where issue_link.issue_id ='18935'
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

aggregated_issue_link.linked_issues,
aggregated_issue_link.linked_issue_keys,

FROM `floranow.floranow_jira.issue` AS issue 
LEFT JOIN `floranow.floranow_jira.project` AS project ON issue.project_id = project.id
LEFT JOIN `floranow.floranow_jira.user` AS assignee_account ON issue.assignee_account_id = assignee_account.account_id
LEFT JOIN `floranow.floranow_jira.user` AS creator_account ON issue.creator_account_id = creator_account.account_id
LEFT JOIN `floranow.floranow_jira.issue` AS parent_issue on  issue.parent_issue_id = parent_issue.id

LEFT JOIN aggregated_labels ON issue.id = aggregated_labels.issue_id
LEFT JOIN aggregated_issue_link ON issue.id = aggregated_issue_link.issue_id