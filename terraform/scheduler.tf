data "google_cloudfunctions_function" "datetime" {
  name = "datetime"
}

locals {
  hoge = {
    foo = 1
    bar = "baz"
  }
  workflow_params = {
    user         = local.pixela.user
    graph_id     = local.pixela.graph_id
    workspace_id = local.toggl.workspace_id
    project_id   = local.toggl.project_id
    url          = data.google_cloudfunctions_function.datetime.https_trigger_url
  }
  request_params = {
    argument = jsonencode(local.workflow_params)
  }
}

resource "google_cloud_scheduler_job" "workflow_job" {
  name             = "toggl-to-pixela-workflow-scheduler"
  description      = "Kick Toggl To Pixela Workflow"
  schedule         = "0 10 * * *"
  time_zone        = "Asia/Tokyo"
  attempt_deadline = "320s"
  project          = local.project
  region           = local.region

  retry_config {
    retry_count          = 1
    max_backoff_duration = "3600s"
    max_doublings        = 5
    max_retry_duration   = "0s"
    min_backoff_duration = "5s"
  }

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.toggl_to_pixela.name}/executions"
    body        = base64encode(jsonencode(local.request_params))

    oauth_token {
      service_account_email = google_service_account.workflow_invoker.email
    }
  }
}
