##-----------------------------------------------------------------------------
## Variables
##-----------------------------------------------------------------------------
variable "waf_enabled" {
  type        = bool
  default     = true
  description = "to Enable WAF on Front door and application gateway"
}