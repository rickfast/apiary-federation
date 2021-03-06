/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_ecs_cluster" "waggledance" {
  name = "${local.instance_alias}"
  tags = "${var.tags}"
}

resource "aws_ecs_service" "waggledance_service" {
  name            = "${local.instance_alias}-service"
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.waggledance.id}"
  task_definition = "${aws_ecs_task_definition.waggledance.arn}"
  desired_count   = "${var.wd_ecs_task_count}"

  network_configuration {
    security_groups = ["${aws_security_group.wd_sg.id}"]
    subnets         = ["${var.subnets}"]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.metastore_proxy.arn}"
  }
}

resource "aws_ecs_task_definition" "waggledance" {
  family                   = "${local.instance_alias}"
  task_role_arn            = "${aws_iam_role.waggledance_task.arn}"
  execution_role_arn       = "${aws_iam_role.waggledance_task_exec.arn}"
  network_mode             = "awsvpc"
  memory                   = "${var.memory}"
  cpu                      = "${var.cpu}"
  requires_compatibilities = ["EC2", "FARGATE"]
  container_definitions    = "${data.template_file.waggledance.rendered}"
  tags                     = "${var.tags}"
}
