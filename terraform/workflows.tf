resource google_workflows_workflow toggl_to_pixela {
  name = "toggl_to_pixela_workflow"
  description = "toggl to pixela workflow"
  region = local.region
  service_account = google_service_account.workflow_invoker.id
  source_contents = file("toggl-to-pixela.workflow.yml")
}
