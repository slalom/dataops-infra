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
    SuccessWebhook = {
      description = "Send success notification notification to MS Teams."
      handler     = "webhook_notify.lambda_handler"
      environment = {
        ALERT_MESSAGE_TEXT = var.success_webhook_message
        ALERT_WEBHOOK_URL  = var.success_webhook_url
      }
      secrets = {}
    }
    AlertsWebhook = {
      description = "Send failure alert notification to MS Teams."
      handler     = "webhook_notify.lambda_handler"
      environment = {
        ALERT_MESSAGE_TEXT = var.alerts_webhook_message
        ALERT_WEBHOOK_URL  = var.alerts_webhook_url
      }
      secrets = {}
    }
  }
}
