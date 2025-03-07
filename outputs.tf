
# outputs

#SNS topic
output "sns_topic_arn" {
  description = "ARN of SNS topic"
  value       = element(concat(aws_sns_topic.this.*.arn, [""]), 0)
}

#SNS subscription
output "sns_subscription_arn" {
  description = "ARN of SNS subscription"
  value       = element(concat(aws_sns_topic_subscription.this.*.arn, [""]), 0)
}

#SNS platform application

output "sns_platform_application_arn" {
  description = "ARN of SNS platform application"
  value       = element(concat(aws_sns_platform_application.this.*.arn, [""]), 0)
}