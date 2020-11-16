module "triggered_lambda" {
  source        = "../../../components/aws/lambda-python"
  name_prefix   = local.name_prefix
  resource_tags = var.resource_tags
  environment   = var.environment

  runtime              = "python3.8"
  lambda_source_folder = "${path.module}/lambda"
  upload_to_s3         = false
  upload_to_s3_path    = null

  functions = {
    NotifyMSTeamsWebhook = {
      description = "Send alert notification to MS Teams."
      handler     = "webhook_notify.lambda_handler"
      environment = {
        ALERT_MESSAGE_TEXT = var.alerts_webhook_message
        ALERT_WEBHOOK_URL  = var.alerts_webhook_ms_teams
      }
      secrets     = {}
    }
  }
}
