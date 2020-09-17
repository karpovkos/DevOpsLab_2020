Datadog lab
============
1. Change `project` in `variables.tf`
2. Export the GCP environment variables (credentials):
    * export GOOGLE_CLOUD_KEYFILE_JSON=/path/file
3. Export the Datadog environment variables (credentials):
    * export DD_APP_KEY=app_key
    * export DD_API_KEY=api_key
4. Run `terraform apply -var api_key=$DD_API_KEY` (or `terraform apply` api_key will be requested).


## Terraform just created Datadob infrastructure
![screen](screenshots/Main.png)
![screen](screenshots/Main_2.png)

## Metric explorer : network.http.responce_time
![screen](screenshots/Metric_explorer.png)

## Log explorer, list view
![screen](screenshots/Log_explorer_list.png)
## Log explorer, detailed view
![screen](screenshots/Log_explorer_detail.png)
## Log explorer, pattern view
![screen](screenshots/Log_explorer_pattern.png)

## Monitoring
![screen](screenshots/Monitor_manage.png)
## Test email notification
![screen](screenshots/Email_send.png)