plugin "aws" {
  enabled = true
  version = "0.34.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Enforce variable descriptions
rule "terraform_documented_variables" {
  enabled = true
}

# Enforce output descriptions
rule "terraform_documented_outputs" {
  enabled = true
}

# Warn on deprecated interpolation syntax
rule "terraform_deprecated_interpolation" {
  enabled = true
}

# Enforce naming convention (snake_case)
rule "terraform_naming_convention" {
  enabled = true

  variable {
    format = "snake_case"
  }

  output {
    format = "snake_case"
  }

  local {
    format = "snake_case"
  }
}

# Disallow // comments (use # instead)
rule "terraform_comment_syntax" {
  enabled = true
}

# Require providers to be pinned in versions.tf
rule "terraform_required_providers" {
  enabled = true
}

# Require terraform version constraint
rule "terraform_required_version" {
  enabled = true
}
