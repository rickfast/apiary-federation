resource "aws_alb" "waggledance_lb" {
  name               = "waggledance-lb"
  subnets            = ["${var.subnets}"]
  internal           = true
  load_balancer_type = "network"
}

resource "aws_alb_target_group" "waggledance_lb_target_group" {
  name        = "waggledance-target-group"
  port        = 48869
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  stickiness {
    enabled = false
    type = "lb_cookie"
  }
}

resource "aws_alb_listener" "waggledance_lb_listener" {
  load_balancer_arn = "${aws_alb.waggledance_lb.id}"
  port              = 48869
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.waggledance_lb_target_group.id}"
    type             = "forward"
  }
}
