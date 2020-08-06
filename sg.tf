
resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = "${local.name}-airflow-sg"
  description = "Security group for Airflow Nodes"

  vpc_id = var.vpc_id == "" ? data.aws_vpc.default.id : var.vpc_id

  tags = var.tags
}

locals {
  ssh_cidr = var.ssh_ips == null ? ["0.0.0.0/0"] : [for i in var.ssh_ips : "${i}/32"]
}

resource "aws_security_group_rule" "open_ingress" {
  count = var.create_security_group ? length(var.open_ports) : 0

  description       = "Open ${count.index} port"
  from_port         = var.open_ports[count.index]
  to_port           = var.open_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.this.*.id)
  type              = "ingress"
}

resource "aws_security_group_rule" "egress" {
  count = var.create_security_group ? 1 : 0

  description       = "Egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.this.*.id)
  type              = "egress"
}