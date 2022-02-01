module "ws" {
  count  = local.ws == null ? 0 : 1
  source = "./ws"

  prefix                = local.prefix
  log_retention_in_days = local.logging.retention_in_days

  domain                = local.domain_ws
  hosted_zone_id        = one(data.aws_route53_zone.domain[*].zone_id)
  auth_module           = one(module.auth)
  allow_unauthenticated = local.ws.allow_unauthenticated

  rpc = lookup(local.ws, "rpc", null) == null ? null : merge(local.ws.rpc, {
    environment = merge(
      local.ws.rpc.environment == null ? {} : local.ws.rpc.environment,
      length(module.auth) == 0 ? {} : {
        FUN_AUTH_COGNITO_USER_POOL_ID = module.auth[0].user_pool.id
      }
    )
  })

  event_authorizer = lookup(local.ws, "event_authorizer", null) == null ? null : merge(local.ws.event_authorizer, {
    environment = merge(
      local.ws.event_authorizer.environment == null ? {} : local.ws.event_authorizer.environment,
      length(module.auth) == 0 ? {} : {
        FUN_AUTH_COGNITO_USER_POOL_ID = module.auth[0].user_pool.id
      }
    )
  })

  providers = {
    aws = aws
  }
}

resource "aws_iam_role_policy_attachment" "lambda_ws_rpc_auth_get_info" {
  count      = length(module.auth) > 0 && length(module.ws) > 0 ? (module.ws[0].rpc_role != null ? 1 : 0) : 0
  role       = module.ws[0].rpc_role.name
  policy_arn = module.auth[0].get_info_policy_arn
}

resource "aws_iam_role_policy_attachment" "lambda_ws_event_authorizer_auth_get_info" {
  count      = length(module.auth) > 0 && length(module.ws) > 0 ? (module.ws[0].event_authorizer_role != null ? 1 : 0) : 0
  role       = module.ws[0].event_authorizer_role.name
  policy_arn = module.auth[0].get_info_policy_arn
}
