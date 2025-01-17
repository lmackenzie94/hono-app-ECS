# --------------------------------------
# ACM Certificate
# 1. Creates an ACM certificate for the specified subdomain
# 2. Creates a DNS validation record for the certificate
# 3. Validates the certificate
# 4. Creates an A record for the subdomain pointing to the ALB
# --------------------------------------

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.subdomain_name}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.app_name}-cert"
    Environment = var.environment
  }
}

# DNS Validation record
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# Certificate Validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Get existing Route 53 zone
data "aws_route53_zone" "main" {
  name = var.domain_name
}

# A record for subdomain pointing to ALB
resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.subdomain_name}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}