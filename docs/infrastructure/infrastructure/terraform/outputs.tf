# Outputs for Pulse Trading Infrastructure

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "s3_bucket_name" {
  description = "S3 bucket name for static website"
  value       = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_website_endpoint" {
  description = "S3 bucket website endpoint"
  value       = aws_s3_bucket_website_configuration.main.website_endpoint
}

output "s3_logs_bucket_name" {
  description = "S3 bucket name for logs"
  value       = aws_s3_bucket.logs.id
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.main.arn
}

output "certificate_status" {
  description = "ACM certificate validation status"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].id : null
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

# URLs and endpoints
output "website_url" {
  description = "Primary website URL"
  value       = "https://${var.domain_name}"
}

output "www_website_url" {
  description = "WWW website URL"
  value       = "https://www.${var.domain_name}"
}

output "api_gateway_url" {
  description = "API Gateway URL (if created)"
  value       = null  # Placeholder for future API Gateway integration
}

# Security and monitoring
output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = "/aws/cloudfront/${aws_cloudfront_distribution.main.id}"
}

output "security_headers_policy_id" {
  description = "CloudFront security headers policy ID"
  value       = aws_cloudfront_response_headers_policy.security_headers.id
}

# Cost optimization
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value = {
    cloudfront_requests = "~$0.0075 per 10,000 requests"
    cloudfront_data_out = "~$0.085 per GB"
    s3_storage         = "~$0.023 per GB/month"
    route53           = "$0.50 per hosted zone"
    acm_certificate   = "Free for public certificates"
    waf              = "~$1.00 per web ACL + $0.60 per million requests"
  }
}

# Performance metrics
output "cache_behaviors" {
  description = "CloudFront cache behavior configuration"
  value = {
    default = {
      path_pattern = "Default (*)"
      ttl_min     = 0
      ttl_default = var.cache_ttl_default
      ttl_max     = 31536000
    }
    assets = {
      path_pattern = "/assets/*"
      ttl_min     = var.cache_ttl_assets
      ttl_default = var.cache_ttl_assets
      ttl_max     = var.cache_ttl_assets
    }
  }
}

# Deployment information
output "deployment_info" {
  description = "Deployment information for CI/CD"
  value = {
    s3_bucket_name     = aws_s3_bucket.main.id
    cloudfront_dist_id = aws_cloudfront_distribution.main.id
    aws_region         = var.aws_region
    environment        = var.environment
  }
  sensitive = false
}

# DNS information
output "dns_records" {
  description = "DNS record configuration"
  value = {
    root_domain = {
      name  = var.domain_name
      type  = "CNAME"
      value = aws_cloudfront_distribution.main.domain_name
    }
    www_domain = {
      name  = "www.${var.domain_name}"
      type  = "CNAME"
      value = aws_cloudfront_distribution.main.domain_name
    }
  }
}

# Monitoring dashboards
output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=PulseTrading-${var.environment}"
}

output "waf_dashboard_url" {
  description = "WAF dashboard URL"
  value       = var.enable_waf ? "https://console.aws.amazon.com/wafv2/homev2/web-acl/details/${aws_wafv2_web_acl.main[0].id}" : null
}

# Backup and disaster recovery
output "backup_configuration" {
  description = "Backup and disaster recovery configuration"
  value = {
    s3_versioning_enabled = true
    lifecycle_policy     = "Enabled with ${var.backup_retention_days} days retention"
    cross_region_replication = "Disabled (single region deployment)"
    point_in_time_recovery  = "S3 versioning provides file-level recovery"
  }
}

# SSL/TLS information
output "ssl_configuration" {
  description = "SSL/TLS configuration details"
  value = {
    certificate_arn    = aws_acm_certificate.main.arn
    minimum_tls_version = var.ssl_minimum_protocol_version
    sni_enabled       = true
    hsts_enabled      = true
    hsts_max_age      = 31536000
  }
}

# Integration endpoints
output "integration_endpoints" {
  description = "Integration endpoints for external services"
  value = {
    webhook_url    = "https://${var.domain_name}/api/webhooks"
    health_check   = "https://${var.domain_name}/health"
    metrics_endpoint = "https://${var.domain_name}/metrics"
  }
}