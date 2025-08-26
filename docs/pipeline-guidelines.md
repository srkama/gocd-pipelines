# Pipeline Configuration Guidelines

## Naming Conventions

- **Pipelines:** Use lowercase with hyphens (e.g., `deploy-frontend`)
- **Stages:** Use descriptive names (e.g., `build`, `test`, `deploy`)
- **Jobs:** Use action-oriented names (e.g., `package-app`, `deploy-to-server`)

## Structure Requirements

- All files must end with `.gocd.yaml`
- Use `format_version: 10` for compatibility
- Always include meaningful labels and descriptions
- Use environment variables for configuration

## Best Practices

1. **Security:** Use secure variables for sensitive data
2. **Artifacts:** Define clear artifact dependencies
3. **Resources:** Tag agents with appropriate resources
4. **Approval:** Use manual approval for production deployments
5. **Cleanup:** Enable workspace cleanup where appropriate

## Testing

Always validate configurations before committing:
```bash
./scripts/validate-pipelines.sh
```
