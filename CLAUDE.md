# Claude Code Instructions

This repo uses **Claude Code** with its built-in **Terraform skill** as the primary development tool.

**How the two layers work together:**

| Layer | What it provides |
|-------|-----------------|
| Claude Code — Terraform skill | Terraform syntax, AWS provider knowledge, HCL best practices, module design patterns |
| This `CLAUDE.md` | Project-specific conventions, CI setup, provider pinning rules, commit style — the things that are unique to *this* repo |

Claude Code reads this file at the start of every session, so the project context is always loaded without re-explaining.

---

## Repo Purpose

Production-grade, reusable Terraform modules for AWS, structured for multi-region /
multi-environment deployments. The repo is also used as a portfolio project to demonstrate
infrastructure engineering and AI-assisted DevOps practices.

---

## Structure Rules

```
modules/<name>/          # Reusable building blocks — no provider blocks, no backend
resources/<region>/<env>/  # Root modules — provider + backend config lives here only
```

- Modules contain only: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`
- No `examples/` subdirectories inside modules — real usage examples live in `resources/`
- Every module must have a `versions.tf` that pins minimum Terraform and provider versions
- Only `staging` and `production` environments per region — no `dev`

---

## Provider Version Pinning

**Always use explicit upper bounds, never open-ended `>= X.0`.**

```hcl
# WRONG — resolves to 6.x which has breaking changes
version = ">= 5.0"

# CORRECT
version = ">= 5.0, < 6.0"
```

The same applies to `tls` (`>= 4.0, < 5.0`) and `random` (`>= 3.0, < 4.0`).

Environments require `>= 1.10.0` for native S3 state locking (`use_lockfile = true`).

---

## CI Workflows

`.github/workflows/terraform-checks.yml` — runs on every push/PR:
- `fmt` — `terraform fmt -check -recursive` (must be clean before committing)
- `validate-modules` — matrix over all 8 modules with Terraform 1.9.0
- `validate-envs` — matrix over all 4 environments with Terraform **1.10.0** (not 1.9.0)
- `tflint` — AWS ruleset, recursive

`.github/workflows/security-scan.yml` — push/PR + weekly Monday cron:
- `trivy` — installs via apt, `--exit-code 0` (informational), uploads SARIF
- `checkov` — `soft_fail: true`, uploads SARIF to GitHub Security tab

Both are non-blocking by design; findings are visible in the Security tab.

---

## Local Validation Workflow

```bash
# Format everything first
terraform fmt -recursive

# Validate a module
terraform -chdir=modules/<name> init -backend=false && terraform -chdir=modules/<name> validate

# Validate an environment
terraform -chdir=resources/us-east-1/staging init -backend=false && \
  terraform -chdir=resources/us-east-1/staging validate
```

**If validate fails with a cached provider version mismatch**, delete the stale state:

```bash
find . -name ".terraform.lock.hcl" -not -path "*/.terraform/*" -exec rm -f {} \;
find . -name ".terraform" -type d -not -path "*/.terraform/*" -exec rm -rf {} \;
```

---

## Commit Style

- No `Co-Authored-By: Claude` lines in commit messages
- Commit messages explain *why*, not just *what*
- Stage specific files — avoid `git add -A` to prevent accidentally committing state files

---

## Module Checklist (when adding a new module)

- [ ] `main.tf` — resources only, no `provider {}` block
- [ ] `variables.tf` — every variable has a `description`
- [ ] `outputs.tf` — every output has a `description`
- [ ] `versions.tf` — `required_version` and `required_providers` with explicit upper bounds
- [ ] `README.md` — usage example, inputs table, outputs table, requirements
- [ ] Add to `validate-modules` matrix in `.github/workflows/terraform-checks.yml`
- [ ] Add entry to the module table in `README.MD`
