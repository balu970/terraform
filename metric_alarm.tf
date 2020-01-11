resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "my_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "900" # this is in seconds#
  statistic                 = "Average"
  threshold                 = "80"  # this is percentage#
  alarm_description         = "This metric monitors ec2 cpu utilization"


      dimensions = {
        InstanceId = "${aws_instance.web.id}"
      }
}
    

