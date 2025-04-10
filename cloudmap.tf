resource "aws_service_discovery_private_dns_namespace" "auth_ns" {
  name        = "local"
  description = "Service discovery for internal ECS services"
  vpc         = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "auth_service_discovery" {
  name = "auth-server"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.auth_ns.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

