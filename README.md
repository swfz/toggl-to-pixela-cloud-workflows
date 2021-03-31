# toggl-to-pixela-cloud-workflows

Togglの特定プロジェクトの特定期間の作業時間総計をPixelaにプロットするためのworkflow

## シークレット

下記の名前で用意する(SecretManagerへ登録する)

- TOGGL_API_TOKEN
- PIXELA_API_TOKEN

参考程度にgcloudコマンドで登録する方法

```shell
$ echo $API_TOKEN | gcloud secrets create sample-secret --replication-policy=automatic --data-file=-
```

## Pixela

事前にグラフを作成する(数値はfloat)

## 環境構築

### CloudFunctions

```shell
$ cd functions
$ gcloud functions deploy datetime --project=sample-project-111111 --runtime=ruby27 --trigger-http --entry-point=datetime --region=us-central1
```

### Terraform

- default.tfvars

default.tfvars.sampleをもとに次の項目を`default.tfvars`ファイルに記入する

- GCPのリージョンとプロジェクトID
- Toggl上の集計したいプロジェクトのworkspace_idとproject_id
- PixelaのユーザーIDとグラフIDを

```yaml
region  = "us-central1"
project = "sample-project-111111"
pixela = {
  user = "test"
  graph_id = "test"
}
toggl = {
  workspace_id = 3913543
  project_id = 156548296
}
```

Workflows自体は一部リージョンしか設定できないので注意が必要

```
$ terraform plan -var-file=default.tfvars
$ terraform apply -var-file=default.tfvars
```

### 留意事項

2021-04-01現在

provider "registry.terraform.io/hashicorp/google": "3.61.0" において特定条件でエラーが発生する

- 条件
    - workflowの設定ファイルを更新してapplyするとき

```
Error: Provider produced inconsistent final plan

When expanding the plan for google_cloud_scheduler_job.workflow_job to include                                                                                                                  new values learned so far during apply, provider
"registry.terraform.io/hashicorp/google" produced an invalid new value for                                                                                                                      .http_target[0].uri: was
cty.StringVal("https://workflowexecutions.googleapis.com/v1/toggl_to_pixela_workflow/executions"),
but now
cty.StringVal("https://workflowexecutions.googleapis.com/v1/projects/${project_id}/locations/${region}/workflows/toggl_to_pixela_workflow/executions").

This is a bug in the provider, which should be reported in the provider's own
issue tracker.
```

エラーは出るが設定ファイル自体は更新される