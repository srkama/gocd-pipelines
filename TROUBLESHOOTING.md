# GoCD Pipeline as Code Troubleshooting

## Common Issues and Solutions

### Issue: NullPointerException - rootMap is null
**Error Message:**
```
The plugin sent a response that could not be understood by Go. Plugin returned with code '500' and the following response: '{"target_version":1,"environments":[],"pipelines":[],"errors":[{"location":"YAML config plugin","message":"java.lang.NullPointerException: Cannot invoke \"java.util.Map.entrySet()\" because \"rootMap\" is null"}]}'
```

**Root Cause:**
A `.gocd.yaml` file contains only comments or has no valid YAML structure. The GoCD plugin tries to parse all files matching `**/*.gocd.yaml` pattern and expects them to have a valid YAML root structure.

**Solution:**
1. **Check for comment-only files:** Remove or rename files that contain only comments
2. **Add valid YAML structure:** Ensure all `.gocd.yaml` files have proper format
3. **Rename documentation files:** Use `.md` extension for documentation

#### Example Fix:
```bash
# Rename comment-only files
mv templates/my-template.gocd.yaml templates/my-template-DOCUMENTATION.md

# Or add valid YAML structure
echo "format_version: 10" > templates/my-template.gocd.yaml
echo "# This file is intentionally minimal" >> templates/my-template.gocd.yaml
```

### Issue: Templates Error
**Error Message:**
```
The plugin sent a response that could not be understood by Go. Plugin returned with code '500' and the following response: '{"target_version":1,"environments":[],"pipelines":[],"errors":[{"location":"YAML config plugin","message":"cd.go.plugin.config.yaml.YamlConfigException: templates is invalid, expected format_version, pipelines, environments, or common"}]}'
```

**Root Cause:**
The GoCD YAML Configuration Plugin doesn't support standalone template files with a `templates:` root key.

**Solution:**
Use YAML anchors and references within pipeline files instead. Here's how:

#### ❌ Wrong Way (Standalone Template File):
```yaml
# templates/my-template.gocd.yaml
format_version: 10
templates:
  deploy-template:
    # This will cause the error
```

#### ✅ Correct Way (YAML Anchors in Pipeline File):
```yaml
# pipelines/my-app.gocd.yaml
format_version: 10

common:
  deploy-job: &deploy-job
    resources:
      - docker
    tasks:
      - exec:
          command: /bin/bash
          arguments: ["-c", "./scripts/deploy.sh"]

pipelines:
  my-app:
    group: deployment
    materials:
      git:
        git: https://github.com/your-org/your-app.git
    stages:
      - deploy:
          jobs:
            deploy-to-server:
              <<: *deploy-job
```

### Issue: Configuration Not Loading
**Problem:** GoCD doesn't pick up configuration changes

**Solutions:**
1. **Check file patterns:** Ensure files end with `.gocd.yaml`
2. **Validate syntax:** Run `./scripts/validate-pipelines.sh`
3. **Force refresh:** Run `./scripts/sync-to-gocd.sh`
4. **Check GoCD logs:** Look for parsing errors in GoCD server logs

### Issue: Environment Variables Not Working
**Problem:** Variables not substituting in pipeline

**Solutions:**
1. **Check syntax:** Use `$VARIABLE_NAME` not `${VARIABLE_NAME}`
2. **Secure variables:** Use GoCD UI for sensitive data
3. **Inheritance:** Environment variables inherit from environment to pipeline to stage to job

### Issue: Pipeline Not Appearing
**Problem:** Pipeline defined but not visible in GoCD

**Solutions:**
1. **Check group:** Ensure pipeline group exists
2. **Check materials:** Verify Git repository access
3. **Check permissions:** Ensure GoCD can access the config repository
4. **Check for duplicates:** Pipeline names must be unique

## Validation Checklist

Before committing changes:

- [ ] Run `./scripts/validate-pipelines.sh`
- [ ] Check file naming: `*.gocd.yaml`
- [ ] Verify YAML syntax with `yq eval '.' file.gocd.yaml`
- [ ] Test locally if possible
- [ ] Check GoCD UI after commit

## Debugging Steps

### 1. Check Configuration Repository Status
```bash
# In GoCD UI: Admin → Config Repositories
# Look for errors or last update time
```

### 2. Validate Individual Files
```bash
# Check specific file
yq eval '.' pipelines/my-pipeline.gocd.yaml

# Check for required fields
yq eval '.format_version' pipelines/my-pipeline.gocd.yaml
yq eval '.pipelines | keys' pipelines/my-pipeline.gocd.yaml
```

### 3. Force Configuration Sync
```bash
# From your config repository
./scripts/sync-to-gocd.sh

# Or via API
curl -X POST -u admin:admin123 \
  http://localhost:8153/go/api/admin/config_repos/refresh \
  -H "Accept: application/vnd.go.cd.v1+json"
```

### 4. Check GoCD Server Logs
```bash
# Check Docker logs
docker logs gocd-server --tail 100 | grep -i error

# Look for YAML parsing errors
docker logs gocd-server --tail 100 | grep -i yaml
```

## File Structure Best Practices

### Recommended Structure
```
gocd-pipelines/
├── pipelines/
│   ├── frontend.gocd.yaml      # Single app pipeline
│   ├── backend.gocd.yaml       # Another app pipeline
│   └── shared-templates.gocd.yaml  # Common templates using anchors
├── environments/
│   ├── staging.gocd.yaml
│   └── production.gocd.yaml
└── scripts/
    ├── validate-pipelines.sh
    └── sync-to-gocd.sh
```

### File Naming Rules
- Must end with `.gocd.yaml`
- Use descriptive names
- Group related pipelines
- Avoid special characters

## Common YAML Mistakes

### 1. Indentation Errors
```yaml
# Wrong
pipelines:
my-app:
  group: deployment

# Correct
pipelines:
  my-app:
    group: deployment
```

### 2. Missing Format Version
```yaml
# Always include at the top
format_version: 10
```

### 3. Invalid Resource References
```yaml
# Wrong
resources:
- docker-agent

# Correct (must match actual agent resources)
resources:
- docker
```

## Recovery Procedures

### If GoCD Won't Start Due to Config Error
1. Access GoCD UI → Admin → Config XML
2. Temporarily disable config repository
3. Fix the configuration in Git
4. Re-enable config repository

### If Pipelines Disappear
1. Check config repository connection
2. Verify file syntax
3. Force refresh configurations
4. Check for duplicate pipeline names

### Rollback Configuration
```bash
# Revert to previous commit
git revert HEAD
git push origin main

# GoCD will automatically pick up the changes
```

## Prevention Tips

1. **Always validate before committing**
2. **Use feature branches for major changes**
3. **Test with simple pipelines first**
4. **Keep templates simple and well-documented**
5. **Regular backups of working configurations**

## Getting Help

1. **GoCD Documentation:** https://docs.gocd.org/current/advanced_usage/pipelines_as_code.html
2. **YAML Plugin:** https://github.com/tomzo/gocd-yaml-config-plugin
3. **Community:** GoCD Google Group
4. **This repository:** Check `examples/` directory for working configurations
