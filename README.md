# toggl-to-pixela-cloud-workflows

Togglの特定プロジェクトの特定期間の作業時間総計をPixelaにプロットするためのworkflow

## シークレット

下記の名前で用意する(SecretManagerへ登録する)

- TOGGL_API_TOKEN
- PIXELA_API_TOKEN

参考程度にgcloudコマンドで登録する方法

```shell
$ echo -n $TOGGL_API_TOKEN | gcloud secrets create TOGGL_API_TOKEN --replication-policy=automatic --data-file=-
$ echo -n $PIXELA_API_TOKEN | gcloud secrets create PIXELA_API_TOKEN --replication-policy=automatic --data-file=-
```

## Pixela

事前にグラフを作成する(数値はfloat)

## 環境構築

- リージョンについて

2021-04-01現在Workflowsを使えるリージョンが3つのみなので今の所`us-central`で統一するのが良さそう

### APIの有効化

必要なAPIの有効化を行う

```shell
gcloud services enable iam.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable workflows.googleapis.com
gcloud services enable secretmanager.googleapis.com
```

- app engineの有効化

Cloud SchedulerはAppEngineを設定しないと使用できないので使用できるよう設定する

```shell
$ gcloud app create --region=us-central
```

### CloudFunctions

```shell
$ cd functions
$ gcloud functions deploy datetime --project=sample-project-111111 --runtime=ruby27 --trigger-http --entry-point=datetime --region=us-central1
```

### Terraform

- default.tfvars

`default.tfvars.sample`をもとに次の項目を`default.tfvars`ファイルに記入する

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
  workspace_id = 0
  project_id = 0
}
```

Workflows自体は一部リージョンしか設定できないので注意が必要

- tfstate

事前に適当なtfstate用のバケットを作成する

- e.g.)

```
gsutil mb gs://xxx-terraform-tfstate
```

bucket,prefixは適宜変更する

```shell
$ cat backend-config.tfvars
bucket = "xxx-terraform-tfstate"
prefix = "toggl-to-pixela-workflow.tfstate"
```

```
$ terraform init -backend-config=backend-config.tfvars
$ terraform plan -var-file=default.tfvars
$ terraform apply -var-file=default.tfvars
```

