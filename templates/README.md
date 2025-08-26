# Templates Directory

This directory contains documentation and examples for GoCD pipeline templates.

## Important Note

⚠️ **The GoCD YAML Configuration Plugin does not support standalone template files!**

Files ending with `.gocd.yaml` in this directory will cause parsing errors because the plugin expects them to contain valid pipeline, environment, or common configurations.

## How to Use Templates

### ✅ Correct Approach: YAML Anchors
Use YAML anchors and references within your pipeline files:

```yaml
# pipelines/my-app.gocd.yaml
format_version: 10

common:
  # Define reusable components with anchors
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
              <<: *deploy-job  # Reference the anchor
```

### 📚 Examples

See these working examples:
- `../pipelines/template-example.gocd.yaml` - Complete example with multiple anchors
- `../pipelines/fixed-deploy-app.gocd.yaml` - Real deployment pipeline

### ❌ What NOT to Do

Don't create files like this in the templates directory:
```yaml
# templates/bad-example.gocd.yaml - This will cause errors!
format_version: 10
templates:  # This key is not supported
  my-template:
    # template content
```

## File Naming

- ✅ Use `.md` extension for documentation files
- ✅ Use descriptive names like `deploy-template-DOCUMENTATION.md`
- ❌ Avoid `.gocd.yaml` extension unless the file contains valid GoCD configuration
