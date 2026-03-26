rule "terraform_required_providers" {
  enabled = true

  # defaults
  source = false  # will be handled in the module
  version = false # will be handled in the module
}

rule "terraform_standard_module_structure" {
  enabled = false # need to check how well we align with it and if the whole standard is enforced or just having a main.tf
}

rule "terraform_naming_convention" {
  enabled = false # Needs refactoring
}

rule "terraform_required_version" {
  enabled = false # Constraint implicitly given via atlantis
}

rule "terraform_typed_variables" {
  enabled = false # Needs refactoring or specific excludes
}

rule "terraform_workspace_remote" {
  enabled = false #
}
