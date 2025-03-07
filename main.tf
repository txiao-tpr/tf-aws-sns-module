// To get the Caller region Identity
data "aws_caller_identity" "current" {}

//to get the AWS region
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  #for dead letter queue , when we need to pass a existing queue (we can pass a existing queue or create a dead letter queue within the module)
  #if an existing dead letter queue ARN is provided to the module , that queue permissions needs to be taken care of , so SNS can deliver messages , when you create the DL queue inside the module , it will add the necessary permissions.
  dead_letter_queue_arn = lookup(var.sns_subscription, "dead_letter_queue_arn",null) != null ? lookup(var.sns_subscription, "dead_letter_queue_arn")  : (var.create_dl_queue ? aws_sqs_queue.dead_letter[0].arn : null )
  redrive_policy        = local.dead_letter_queue_arn == null ? null : jsonencode({ "deadLetterTargetArn" : "${local.dead_letter_queue_arn}"})
}

# template file resource to generate the deivery policy for topic using http or https endpoints
data "template_file" "this" {
  vars =  {
    endpoint_type                  = var.endpoint_type
    numRetries                     = var.numRetries
    num_nodelay_retries            = var.num_nodelay_retries
    min_delay                      = var.min_delay
    max_delay                      = var.max_delay
    num_min_delay_retries          = var.num_min_delay_retries
    num_max_delay_retries          = var.num_max_delay_retries
    backoff_function               = var.backoff_function
    disable_subscription_overrides = var.disable_subscription_overrides
    max_receives_per_second        = var.max_receives_per_second
  }

   template = file("${path.module}/policy/delivery_policy.json")
}

resource "aws_sns_topic" "this" {
  # trigger to create sns topic , set create_sns_topic to true , module defaults to true
  count                                    = var.create_sns_topic ? 1 : 0
  name                                     = var.topic_name  
  #The display name for the topic
  display_name                             = var.display_name
  #to create a fifo_topic set fifo_topic to true , defaults to false.
  fifo_topic                               = var.fifo_topic
  # Enables content-based deduplication for FIFO topics , defaults to false. #https://docs.aws.amazon.com/sns/latest/dg/fifo-message-dedup.html
  content_based_deduplication              = var.content_based_deduplication
  #delivery policy ,for topic usng http or https endpoints only , set add_delivery_policy to true to add them
  delivery_policy                          = var.add_delivery_policy ? data.template_file.this.rendered : null

  #for sending messages to platform applications
  application_success_feedback_role_arn    = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn
  
  #for sending messages to http or https endpoint
  http_success_feedback_role_arn           = var.http_success_feedback_role_arn
  http_success_feedback_sample_rate        = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn           = var.http_failure_feedback_role_arn
  
  #for invoking lambda functions
  lambda_success_feedback_role_arn         = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate      = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn         = var.lambda_failure_feedback_role_arn
  
  #for sending messages to SQS queues
  sqs_success_feedback_role_arn            = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate         = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn            = var.sqs_failure_feedback_role_arn

  # FIrehose Support to be added :
  firehose_success_feedback_role_arn       = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate    = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn       = var.firehose_failure_feedback_role_arn


  #for SNS  Server side encryption
  kms_master_key_id                        = var.kms_master_key_id
  tags                                     = merge(var.tags,{"Name"= var.topic_name})

}

resource "aws_sns_topic_policy" "this" {
    # to attach resource policy for the SNS set attach_sns_policy to true
    count                  = var.attach_sns_policy && var.create_sns_topic ? 1 : 0
    arn                    = var.sns_topic_arn != null ? var.sns_topic_arn : aws_sns_topic.this[0].arn
    policy                 = var.sns_policy_document != null ? var.sns_policy_document : replace(data.aws_iam_policy_document.this[0].json, "%ARN%", aws_sns_topic.this[0].arn)
}

/** 
below subscription creation resource requires sns_subscription which is a map of protocol, endpoint , principal sample value
var.sns_subscription ={
    protocol   = lambda
    endpoint   = <lambda_arn>
    topic_arn  = <existing_topic_arn>b#not required if the topic and subscription are created in the same module call
    dead_letter_queue_arn = <sqs_arn>  #optional , when we need to provide a existing queue as dead letter queue for SNS , if we need to create the queue from module , ignore this value.
    }
}
**/   ## other values in the below resource are optiona.

resource "aws_sns_topic_subscription" "this" {
    # to create sns subscription for the topics set create_sns_topic_subscription to true
    # only some type of protocols are supported , sqs, sms, lambda, application are supported fully , http or https are partially supported
    #  and email is not supported in terraform
    #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription

    count                           = var.create_sns_topic_subscription ? 1 : 0
    topic_arn                       = lookup(var.sns_subscription, "topic_arn", aws_sns_topic.this[0].arn)
    protocol                        = lookup(var.sns_subscription, "protocol")     //required
    endpoint                        = lookup(var.sns_subscription, "endpoint")      //required
    endpoint_auto_confirms          = lookup(var.sns_subscription, "endpoint_auto_confirms", true)
    confirmation_timeout_in_minutes = lookup(var.sns_subscription, "confirmation_timeout_in_seconds", null)
    raw_message_delivery            = lookup(var.sns_subscription, "raw_message_delivery", false)
    subscription_role_arn           = lookup(var.sns_subscription, "protocol") == "firehose" ? lookup(var.sns_subscription, "firehose_subscription_role_arn") : null
    # JSON String with the filter policy that will be used in the subscription to filter messages seen by the target resource.
    filter_policy                   = lookup(var.sns_subscription, "filter_policy", "")
    filter_policy_scope             = lookup(var.sns_subscription, "filter_policy_scope", "MessageAttributes")  //Valid Values- MessageAttributes (default) or MessageBody. 
    #JSON String with the delivery policy (retries, backoff, etc.) that will be used in the subscription - this only applies to HTTP/S subscriptions. 
    delivery_policy                 = lookup(var.sns_subscription, "delivery_policy", "")
    # JSON String with the archived message replay policy that will be used in the subscription.
    replay_policy                   = lookup(var.sns_subscription, "replay_policy", "")
    #if dead letter queue needs to be created for SNS subscription
    redrive_policy                  = local.redrive_policy
}

#to create dead letter queue for the SNS topic if needed                                   
resource "aws_sqs_queue" "dead_letter" {
  # FIFO topics need to have FIFO as their DLQ 
  # set create_dl_queue to true to create the dead letter queue
  count                             = var.create_dl_queue ? 1 : 0  
  name                              = var.fifo_topic == true ? "${var.topic_name}-DeadLetterQueue.fifo" : "${var.topic_name}-DeadLetterQueue"
  fifo_queue                        = var.fifo_topic
  max_message_size                  = var.dl_queue_max_message_size
  visibility_timeout_seconds        = var.dl_queue_visibility_timeout
  message_retention_seconds         = var.dl_queue_retention_secs
  #"Specify the arn or alias of a KMS Key or CMK if the messages pushed to the Queue should be encrypted. Providing an ARN value of a KMS key or CMK will automatically enable encryption on the provisioend queue. 
  #Default value will provision a non-encrypted queue.
  kms_master_key_id                 = var.dl_queue_encryption_key
  kms_data_key_reuse_period_seconds = var.dl_queue_kms_reuse_secs
  content_based_deduplication       = var.dl_queue_dedup
  tags                              = merge(var.dl_queue_tags,{"Name"= var.fifo_topic == true ? "${var.topic_name}-DeadLetterQueue.fifo" : "${var.topic_name}-DeadLetterQueue"})
}



#to create platform application for SNS message delivery

resource "aws_sns_platform_application" "this" {
  count                            = var.create_sns_platform_app ? 1 : 0
  name                             = var.platform_app_name
  platform                         = var.app_platform
  platform_credential              = var.platform_credential
  platform_principal               = var.platform_principal

  #SNS Topic triggered when a delivery to any of the platform endpoints associated with your platform application encounters a permanent failure.
  event_delivery_failure_topic_arn = var.event_delivery_failure_topic_arn
  #SNS Topic triggered when a new platform endpoint is added to your platform application.
  event_endpoint_created_topic_arn = var.event_endpoint_created_topic_arn
  #SNS Topic triggered when an existing platform endpoint is changed from your platform application.
  event_endpoint_updated_topic_arn = var.event_endpoint_updated_topic_arn
  # SNS Topic triggered when an existing platform endpoint is deleted from your platform application.
  event_endpoint_deleted_topic_arn = var.event_endpoint_deleted_topic_arn
  #The IAM role permitted to receive failure feedback for this application.
  failure_feedback_role_arn        = var.platform_failure_feedback_role_arn
  #The IAM role permitted to receive success feedback for this application.
  success_feedback_role_arn        = var.platform_success_feedback_role_arn
  #the percentage of success to sample
  success_feedback_sample_rate     = var.platform_success_feedback_sample_rate
}

#cloudwatch log group for success and failure logging

#to create a new log group for topic message delivery logging for various endpoints/subscriptions
resource "aws_cloudwatch_log_group" "success"  {
   #when enabling feedback logging for SQS , platform applicatio n , lambda , firehose ,  http endpoints set create_log_group to true
    count                                 =  var.create_log_group ? 1:0
    name                                  =  "sns/${local.region}/${local.account_id}/${var.topic_name}"
    retention_in_days                     =  var.cloudwatch_logs_retention_in_days
    kms_key_id                            =  var.cloudwatch_logs_kms_key_id
    tags                                  =  merge(var.log_group_tags,{"Name"="sns/${local.region}/${local.account_id}/${var.topic_name}"})
}

resource "aws_cloudwatch_log_group" "failure"  {
  #when enabling feedback logging for SQS , platform applicatio n , lambda , firehose ,  http endpoints set create_log_group to true
    count                                 =  var.create_log_group ? 1:0
    name                                  =  "sns/${local.region}/${local.account_id}/${var.topic_name}/Failure"
    retention_in_days                     =  var.cloudwatch_logs_retention_in_days
    kms_key_id                            =  var.cloudwatch_logs_kms_key_id
    tags                                  =  merge(var.log_group_tags,{"Name" = "sns/${local.region}/${local.account_id}/${var.topic_name}/Failure"})
}

#SNS message preference resource , Provides a way to set SNS SMS preferences.

resource "aws_sns_sms_preferences" "this" {
#to set SMS preference set create_sms_preference to true , defaults to false
  count                                   =  var.create_sms_preference ? 1 : 0
  monthly_spend_limit                     =  var.sms_monthly_spend_limit
  delivery_status_iam_role_arn            =  var.sms_delivery_status_iam_role_arn
  delivery_status_success_sampling_rate   =  var.sms_delivery_status_success_sampling_rate
  default_sender_id                       =  var.sms_default_sender_id
  default_sms_type                        =  var.sms_default_sms_type
  usage_report_s3_bucket                  =  var.sms_usage_report_s3_bucket

}

# optional Resource policy constructor for the SNS topic
data "aws_iam_policy_document" "this" {
  count        = var.attach_sns_policy && var.create_policy_json && var.create_sns_topic ? 1 : 0
  version      = "2012-10-17"
  policy_id           = "sns-policy"
 dynamic  "statement" {
   for_each    = var.sns_topic_policy
   iterator    = i
   content {
    sid       = lookup(i.value,"sid",null)
    effect    = lookup(i.value,"effect","Allow")
    actions   = lookup(i.value,"action") 
    dynamic "principals" {
      for_each      =  lookup(i.value,"principal_type") != null ? [true] : []
      content {
        type        = lookup(i.value,"principal_type") 
        identifiers = lookup(i.value,"identifiers") 
      }
    }
    resources     =  lookup(i.value,"resources",["%ARN%"])  
    # condition blocks in the resource policy are optional
    dynamic "condition" {
      for_each    = lookup(i.value,"conditions",{}) 
      content {
        test      = lookup(condition.value, "test")
        variable  = lookup(condition.value, "variable")
        values    = lookup(condition.value, "values")                       ## provide value as list of string
      }
    }
   }
  }
}

#to add policy for the SQS Dead letter queue , to accept messages from this topic , 

data "aws_iam_policy_document" "dead_letter" {
  count              = var.create_dl_queue  && var.create_sns_topic ? 1 : 0
  version             = "2012-10-17"
  policy_id           = "sns-sqs-deadletterqueue-policy"
  statement {
    sid       = "SQSdeadletterpolicy"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    principals {
        type        = "Service" 
        identifiers = ["sns.amazonaws.com"]
    }
    resources     =  ["${aws_sqs_queue.dead_letter[0].arn}"]
    condition {
       test       = "ArnEquals"
       variable   = "aws:SourceArn"
       values     = ["${aws_sns_topic.this[0].arn}"]
      }
  }
  depends_on = [
    aws_sqs_queue.dead_letter , aws_sns_topic.this , aws_sns_topic_subscription.this
  ]
}

#add the generated poliy to the Dead letter queue
resource "aws_sqs_queue_policy" "dead_letter" {
  count                            = var.create_dl_queue && var.create_sns_topic ? 1 : 0
  queue_url                        = aws_sqs_queue.dead_letter[0].id
  policy                           = data.aws_iam_policy_document.dead_letter[0].json
}