# Workflowを実行するサービスアカウント
resource google_service_account workflow_invoker {
  project      = local.project
  account_id   = "workflow-invoker-sa"
  display_name = "Workflow Invoker Service Account"
}

locals {
  sa_roles = [
    "roles/iam.serviceAccountTokenCreator",
    "roles/workflows.invoker",
    "roles/cloudscheduler.jobRunner",
    "roles/cloudfunctions.serviceAgent",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
  ]
}

resource google_project_iam_member service_account_role {
  count  = length(local.sa_roles)
  role   = element(local.sa_roles, count.index)
  member = "serviceAccount:${google_service_account.workflow_invoker.email}"
}
