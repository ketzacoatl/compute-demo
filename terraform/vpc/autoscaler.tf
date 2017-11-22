## This file contains the IAM user, policy documents, and other resources
## associated with running the autoscaler (ladder). That component needs
## access to scale autoscaling groups (ASGs). Note that the permissions here
## should be limited to a specific ASG, but unfortunately AWS does not support
## ARNs for autoscaling groups yet so you must use "*" as the resource.

## More info: http://docs.aws.amazon.com/autoscaling/latest/userguide/IAM.html#UsingWithAutoScaling_Actions



# IAM policy for an autoscaler to change parameters on ASG clusters (all)
data "aws_iam_policy_document" "autoscaler" { 
  statement {
    sid = "1"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "cloudwatch:GetMetricStatistics",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "autoscaler" {
  name = "${var.name}-autoscaler"
  policy = "${data.aws_iam_policy_document.autoscaler.json}"
}
