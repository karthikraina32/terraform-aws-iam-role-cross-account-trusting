data "aws_caller_identity" "current" {
}

module "iam_policy_document" {
  source         = "./iam-policy-document-abstraction"
  principal_arns = var.principal_arns
  require_mfa    = var.require_mfa
}

resource "aws_iam_role" "cross_account_assume_role" {
  name                 = var.role_name
  assume_role_policy   = module.iam_policy_document.iam_policy_json
  max_session_duration = var.max_session_duration
  path                 = "/CustomerManaged/"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/BasicRole_Boundary"
}

resource "aws_iam_role_policy_attachment" "cross_account_assume_role" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.cross_account_assume_role.name
  policy_arn = element(var.policy_arns, count.index)
}

