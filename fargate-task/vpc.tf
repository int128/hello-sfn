data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}
