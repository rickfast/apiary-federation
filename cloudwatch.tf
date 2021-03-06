/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_cloudwatch_log_group" "waggledance_ecs" {
  name = "${local.instance_alias}"
  tags = "${var.tags}"
}

resource "aws_cloudwatch_dashboard" "apiary_federation" {
  dashboard_name = "${local.instance_alias}-${var.aws_region}"

  dashboard_body = <<EOF
  {
    "widgets": [
      {
         "type":"metric",
         "width":12,
         "height":6,
         "properties":{
            "metrics":[
               [ "AWS/ECS", "CPUUtilization", "ServiceName", "${local.instance_alias}-service", "ClusterName", "${local.instance_alias}" ]
            ],
            "period":300,
            "stat":"Average",
            "region":"${var.aws_region}",
            "title":"WaggleDance ECS CPU Utilization"
         }
      },
      {
         "type":"metric",
         "width":12,
         "height":6,
         "properties":{
            "metrics":[
               [ "AWS/ECS", "MemoryUtilization", "ServiceName", "${local.instance_alias}-service", "ClusterName", "${local.instance_alias}" ]
            ],
            "period":300,
            "stat":"Average",
            "region":"${var.aws_region}",
            "title":"WaggleDance ECS Memory Utilization"
         }
      }
    ]
  }
EOF
}


locals {
  alerts = [
    {
      alarm_name  = "${local.instance_alias}-cpu"
      namespace   = "AWS/ECS"
      metric_name = "CPUUtilization"
      threshold   = "80"
    },
    {
      alarm_name  = "${local.instance_alias}-memory"
      namespace   = "AWS/ECS"
      metric_name = "MemoryUtilization"
      threshold   = "70"
    }
  ]

  dimensions = [
    {
      ClusterName = "${local.instance_alias}"
      ServiceName = "${local.instance_alias}-service"
    },
    {
      ClusterName = "${local.instance_alias}"
      ServiceName = "${local.instance_alias}-service"
    }
  ]
}


resource "aws_cloudwatch_metric_alarm" "waggledance_alert" {
  count               = "${length(local.alerts)}"
  alarm_name          = "${lookup(local.alerts[count.index],"alarm_name")}"
  comparison_operator = "${lookup(local.alerts[count.index],"comparison_operator","GreaterThanOrEqualToThreshold")}"
  metric_name         = "${lookup(local.alerts[count.index],"metric_name")}"
  namespace           = "${lookup(local.alerts[count.index],"namespace")}"
  period              = "${lookup(local.alerts[count.index],"period","120")}"
  evaluation_periods  = "${lookup(local.alerts[count.index],"evaluation_periods","2")}"
  statistic           = "Average"
  threshold           = "${lookup(local.alerts[count.index],"threshold")}"

  #alarm_description         = ""
  insufficient_data_actions = []
  dimensions                = "${local.dimensions[count.index]}"
  alarm_actions             = ["${aws_sns_topic.apiary_federation_ops_sns.arn}"]
}
