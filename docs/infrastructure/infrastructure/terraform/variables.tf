# Variables for Pulse Trading Infrastructure

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Primary domain name for the application"
  type        = string
  default     = "pulse-trading.com"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS management"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for DNS management"
  type        = string
  sensitive   = true
}

variable "cloudfront_price_class" {
  description = "CloudFront price class for cost optimization"
  type        = string
  default     = "PriceClass_100"  # US, Canada, Europe
  validation {
    condition = contains([
      "PriceClass_All",
      "PriceClass_200", 
      "PriceClass_100"
    ], var.cloudfront_price_class)
    error_message = "Valid values are PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "alert_emails" {
  description = "List of email addresses for alerts"
  type        = list(string)
  default     = []
}

variable "enable_waf" {
  description = "Enable AWS WAF for additional security"
  type        = bool
  default     = true
}

variable "s3_force_destroy" {
  description = "Allow Terraform to destroy S3 buckets with content (use with caution)"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days to retain S3 object versions"
  type        = number
  default     = 30
}

variable "log_retention_days" {
  description = "Number of days to retain CloudFront logs"
  type        = number
  default     = 90
}

variable "cache_ttl_default" {
  description = "Default TTL for CloudFront cache (seconds)"
  type        = number
  default     = 86400  # 1 day
}

variable "cache_ttl_assets" {
  description = "TTL for static assets (seconds)"
  type        = number
  default     = 31536000  # 1 year
}

variable "rate_limit_requests" {
  description = "Rate limit for WAF (requests per 5 minutes)"
  type        = number
  default     = 2000
}

variable "enable_ipv6" {
  description = "Enable IPv6 support for CloudFront"
  type        = bool
  default     = true
}

variable "geo_restrictions" {
  description = "List of country codes for geographic restrictions"
  type        = list(string)
  default     = ["US", "CA", "GB", "DE", "FR", "AU", "JP", "SG"]
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins for S3 bucket"
  type        = list(string)
  default     = []
}

variable "custom_error_pages" {
  description = "Custom error page configurations"
  type = map(object({
    error_code         = number
    response_code      = number
    response_page_path = string
  }))
  default = {
    "404" = {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
    "403" = {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    }
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# Cost optimization variables
variable "intelligent_tiering" {
  description = "Enable S3 Intelligent Tiering"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "S3 lifecycle management rules"
  type = object({
    standard_ia_transition_days = number
    glacier_transition_days     = number
    expiration_days            = number
  })
  default = {
    standard_ia_transition_days = 30
    glacier_transition_days     = 90
    expiration_days            = 365
  }
}

# Security variables
variable "enable_access_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail for API logging"
  type        = bool
  default     = true
}

variable "ssl_minimum_protocol_version" {
  description = "Minimum SSL/TLS protocol version for CloudFront"
  type        = string
  default     = "TLSv1.2_2021"
}

# Performance variables
variable "compress_content" {
  description = "Enable CloudFront compression"
  type        = bool
  default     = true
}

variable "http2_support" {
  description = "Enable HTTP/2 support"
  type        = string
  default     = "http2"
}

# Monitoring variables
variable "cloudwatch_metrics_enabled" {
  description = "Enable detailed CloudWatch metrics"
  type        = bool
  default     = true
}

variable "alarm_thresholds" {
  description = "CloudWatch alarm thresholds"
  type = object({
    error_rate_threshold      = number
    cache_hit_rate_threshold  = number
    latency_threshold        = number
  })
  default = {
    error_rate_threshold     = 5
    cache_hit_rate_threshold = 80
    latency_threshold       = 5000
  }
}