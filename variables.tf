## variables

variable "create_sns_topic" {
  description = "Whether to create the SNS topic"
  type        = bool
  default     = true
}

variable "topic_name" {
  description = "The name of the SNS topic to create"
  type        = string
  default     = null
}

variable "display_name" {
  description = "The display name for the SNS topic"
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "boolen whether to create a fifo topic or not"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO topics."
  type        = bool
  default     = false
}

variable "policy" {
  description = "The fully-formed AWS policy as JSON"
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "The SNS delivery policy"
  type        = any
  default     = null
}

### delivery policy variables

variable "add_delivery_policy" {
  description = "whether to add delivery policy for HTTP/S endpoint"
  type        =  bool
  default     =  false
}

variable "endpoint_type" {
  description = "The endpoint type whether its http or https"
  type        = string
  default     =  "http"
}

variable "numRetries" {
  description = " The total number of retries, including immediate, pre-backoff, backoff, and post-backoff retries."
  type        = number
  default     =  3
}

variable "num_nodelay_retries" {
  description = " The number of retries to be done immediately, with no delay between them."
  type        = number
  default     =  0
}

variable "min_delay" {
  description = " The minimum delay for a retry."
  type        = number
  default     =  20
}
variable "max_delay" {
  description = " The maximum delay for a retry."
  type        = number
  default     =  20
}
variable "num_min_delay_retries" {
  description = " The number of retries in the pre-backoff phase, with the specified minimum delay between them."
  type        = number
  default     =  0
}
variable "num_max_delay_retries" {
  description = " TThe number of retries in the post-backoff phase, with the maximum delay between them.."
  type        = number
  default     =  0
}

variable "backoff_function" {
  description = " The model for backoff between retries."
  type        = string
  default     =  "linear"
}

variable "disable_subscription_overrides" {
  description = "whether this policy overirides the subscription policy"
  type        = bool
  default     =  true
}

variable "max_receives_per_second" {
  description = " The maximum number of deliveries per second, per subscription."
  type        = number
  default     =  30
}



 #############################

variable "application_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "application_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = string
  default     = null
}

variable "application_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
  default     = null
}

variable "http_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "http_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = string
  default     = null
}

variable "http_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
 default     = null

}
variable "lambda_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "lambda_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = string
  default     = null
}

variable "lambda_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
  default     = null
}

variable "firehose_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "firehose_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = string
  default     = null
}

variable "firehose_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
  default     = null
}

variable "sqs_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "sqs_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = string
  default     = null
}

variable "sqs_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
  default     = null
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "attach_sns_policy" {
  description = "Boolean to see if sns policy is attached separately"
  type        = bool
  default     = true
}

variable "create_policy_json" {
  description = "whether to create the policy json using the policy constructor to be added to the SNS topic"
  type        = bool
  default     = false
}

variable "sns_policy_document" {
  description = "the json document for the SNS policy"
  type        =  any
  default     =  null
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to attach the policy"
  type        = string
  default     = null
}

variable "sns_topic_policy" {
  description = "declaration to construct the SNS policy"
  type        = any
  default     = []
}

variable "create_sns_topic_subscription" {
  description = "Boolean to see if sns topic subscription needs to be created"
  type        = bool
  default     = false
}

variable "sns_subscription" {
  description = "map of  sns topic subscription details"
  type        = map(any)
  default     = {}
}

## dead letter queue variables



variable "create_dl_queue" {
  description = " whether we need to create the sqs dead letter queue"
  type        = bool
  default     = false
}

variable "dl_queue_max_message_size" {
  description = "Specify the max size in bytes of a message allowed to be put into the dl Queue. Valid ranges are from 1KiB to 256KiB"
  type        = number
  default     = 262144
}

variable "dl_queue_encryption_key" {
  description = "Specify the arn or alias of a KMS Key or CMK if the messages pushed to the Queue should be encrypted. Providing an ARN value of a KMS key or CMK will automatically enable encryption on the provisioend queue. Default value will provision a non-encrypted queue."
  type        = string
  default     = ""
}

variable "dl_queue_visibility_timeout" {
  description = "Specify the duration in seconds (0 to 43200 - 12 hours) of that a consumed message will be placed into in-flight status, and not seen by other consumers before returned to the active message queuefor the dlq."
  type        = number
  default     = 30
}


variable "dl_queue_dedup" {
  description = "whether content deduplication should be enabled in queue"
  type        = bool
  default     = false
}

variable "dl_queue_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "dl_queue_retention_secs" {
  description = "Specify the duration in seconds that messages put into the dead letter queue will be available until they are automatically deleted by SQS even if un-processed. Valid range is 60 to 1209600 (14 days), default value is set to 345600 or 4 days."
  type        = number
  default     = 345600
}


variable "dl_queue_kms_reuse_secs" {
  description = "Specify the duration in seconds that dead letter SQS will be allowed to reuse a data key to encrypt or decrypt messages before calling KMS again for reauth. Valid values are between 60 and 86400 (24 hours), default value is set to 300 (5 minutes) if encryption is enabled."
  type        = number
  default     = 300
}  

#sns platform application variables

variable "create_sns_platform_app" {
  description = "whether to create a SNS platform app"
  type        = bool
  default     = false
}

variable "platform_app_name" {
  description = "The friendly name for the SNS platform application"
  type        = string
  default     = ""
}

variable "app_platform" {
  description = "The platform that the app is registered with. See https://docs.aws.amazon.com/sns/latest/dg/mobile-push-send-register.html for supported platforms."
  type        = string
  default     = ""
}

variable "platform_credential" {
  description = "Application Platform credential. See https://docs.aws.amazon.com/sns/latest/dg/mobile-push-send-register.html for type of credential required for each platform"
  type        = string
  default     = ""
}

variable "platform_principal" {
  description = "Application Platform principal. See https://docs.aws.amazon.com/sns/latest/api/API_CreatePlatformApplication.html for type of principal required for platform. The value of this attribute when stored into the Terraform state is only a hash of the real value, so therefore it is not practical to use this as an attribute for other resources."
  type        = string
  default     = ""
}

variable "event_delivery_failure_topic_arn" {
  description = "SNS Topic triggered when a delivery to any of the platform endpoints associated with your platform application encounters a permanent failure."
  type        = string
  default     = ""
}

variable "event_endpoint_created_topic_arn" {
  description = "SNS Topic triggered when a new platform endpoint is added to your platform application"
  type        = string
  default     = ""
}

variable "event_endpoint_updated_topic_arn" {
  description = "SNS Topic triggered when an existing platform endpoint is changed from your platform application."
  type        = string
  default     = ""
}

variable "event_endpoint_deleted_topic_arn" {
  description = "SNS Topic triggered when an existing platform endpoint is deleted from your platform application."
  type        = string
  default     = ""
}

variable "platform_failure_feedback_role_arn" {
  description = "The IAM role permitted to receive failure feedback for this application."
  type        = string
  default     = ""
}

variable "platform_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this application."
  type        = string
  default     = ""
}

variable "platform_success_feedback_sample_rate" {
  description  = "the success feedback sample rate"
  type         =  number
  default      = null
}

#log group variables

variable "create_log_group" {
  description = "whether to create cloudwatch log group for logging"
  type        = bool
  default     = false
}

variable "cloudwatch_logs_retention_in_days" {
    description = "cloudwatch log retention "
    type        =  number
    default     = 14
}

variable "cloudwatch_logs_kms_key_id" {
    description = "KMS id to be used for cloudwatch logs"
    type        = string
    default     = ""
}

variable "log_group_tags" {
  description = "tags for the cloudwatch log group resource"
  type        = map(any)
  default     = {}
}

#SNS SMS prefernce


variable "create_sms_preference" {
  description  = "whether to create SMS preference for SNS topic"
  type         = bool
  default      = false
}
variable "sms_monthly_spend_limit" {
  description = "The maximum amount in USD that you are willing to spend each month to send SMS messagese"
  type        = number
  default     = null
}

variable "sms_delivery_status_iam_role_arn" {
  description = "The ARN of the IAM role that allows Amazon SNS to write logs about SMS deliveries in CloudWatch Logs."
  type        = string
  default     = null
}

variable "sms_delivery_status_success_sampling_rate" {
  description = "The percentage of successful SMS deliveries for which Amazon SNS will write logs in CloudWatch Logs. The value must be between 0 and 100."
  type        = number
  default     = null
}

variable "sms_default_sender_id" {
  description = "A string, such as your business brand, that is displayed as the sender on the receiving device."
  type        = string
  default     = null
}

variable "sms_default_sms_type" {
  description = "The type of SMS message that you will send by default. Possible values are: Promotional, Transactional"
  type        = string
  default     = null
}

variable "sms_usage_report_s3_bucket" {
  description = "The name of the Amazon S3 bucket to receive daily SMS usage reports from Amazon SNS."
  type        = string
  default     = null
}