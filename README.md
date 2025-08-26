# GoCD Pipeline Configurations

This repository contains all GoCD pipeline configurations managed as code.

## Structure

- `pipelines/` - Individual pipeline definitions
- `environments/` - Environment configurations
- `templates/` - Reusable pipeline templates
- `scripts/` - Shared deployment and utility scripts
- `docs/` - Documentation

## Usage

1. Make changes to pipeline configurations
2. Validate with: `./scripts/validate-pipelines.sh`
3. Commit and push changes
4. GoCD will automatically sync configurations

## Guidelines

- All pipeline files must end with `.gocd.yaml`
- Use meaningful names for pipelines and stages
- Follow the established naming conventions
- Always validate before committing
