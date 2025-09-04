# GoCD YAML Configuration Error Prevention Guide

This guide helps you avoid common errors when writing GoCD pipeline configurations.

## ✅ Fixed Issues Summary

### 1. NullPointerException: "rootMap is null" 
**Cause:** Comment-only `.gocd.yaml` files  
**Fix:** Rename to `.md` or add valid YAML structure

### 2. Parameter Pattern Errors: "# must be followed by a parameter pattern"
**Cause:** Comments with `#` in command strings  
**Fix:** Replace inline comments with echo statements

### 3. Invalid Encrypted Values
**Cause:** Dummy `AES:encrypted_password_here` values  
**Fix:** Comment out or use GoCD UI to encrypt real values

### 4. Invalid Agent UUID Patterns  
**Cause:** Wildcard patterns like `*-prod-*`  
**Fix:** Use actual agent UUIDs from GoCD UI

## 🛡️ Error Prevention Rules

### Rule 1: Comments in Commands
❌ **Wrong:**
```yaml
tasks:
  - exec:
      command: /bin/bash
      arguments:
        - -c
        - |
          echo "Building..."
          # This comment causes errors
          npm install
```

✅ **Correct:**
```yaml
tasks:
  - exec:
      command: /bin/bash  
      arguments:
        - -c
        - |
          echo "Building..."
          echo "Running npm install"
          npm install
```

### Rule 2: File Content Requirements
❌ **Wrong:**
```yaml
# templates/example.gocd.yaml
# This file only has comments - causes NullPointerException
```

✅ **Correct:**
```yaml
# templates/example.gocd.yaml
format_version: 10
# Comments are fine when there's valid YAML structure
```

### Rule 3: Secure Variables
❌ **Wrong:**
```yaml
secure_variables:
  PASSWORD: AES:fake_encrypted_value
```

✅ **Correct:**
```yaml
# Comment out dummy values
# secure_variables:
  # PASSWORD: AES:encrypted_value_from_gocd_ui
```

### Rule 4: Agent References
❌ **Wrong:**
```yaml
agents:
  - "*-prod-*"  # Wildcards not supported
```

✅ **Correct:**
```yaml
# agents:
  # Use actual UUIDs from GoCD UI:
  # - "12345678-abcd-efgh-1234-567890abcdef"
```

## 🔍 Pre-Commit Checklist

Before committing pipeline configurations:

- [ ] Run `./scripts/validate-pipelines.sh`
- [ ] Check for inline comments in command strings
- [ ] Verify all `.gocd.yaml` files have valid YAML structure
- [ ] Comment out dummy encrypted values
- [ ] Use actual agent UUIDs or comment them out
- [ ] Test with a simple pipeline first

## 🧪 Testing Your Configurations

### 1. Local Validation
```bash
# Validate YAML syntax
yq eval '.' pipelines/my-pipeline.gocd.yaml

# Validate all GoCD files
./scripts/validate-pipelines.sh
```

### 2. Test in GoCD
```bash
# Create minimal test pipeline first
cat > pipelines/test-simple.gocd.yaml << EOF
format_version: 10
pipelines:
  test-simple:
    group: testing
    materials:
      git:
        git: https://github.com/your-org/test-repo.git
        branch: main
    stages:
      - build:
          jobs:
            simple-job:
              resources:
                - docker
              tasks:
                - exec:
                    command: echo
                    arguments: ["Hello from GoCD"]
EOF
```

### 3. Gradual Complexity
1. Start with simple pipeline
2. Add environment variables
3. Add complex commands
4. Add multiple stages
5. Add environments and agents

## 🚨 Common Gotchas

### 1. YAML Indentation
```yaml
# Wrong indentation
pipelines:
my-app:  # Missing 2 spaces
  group: deployment

# Correct indentation  
pipelines:
  my-app:  # Properly indented
    group: deployment
```

### 2. Multi-line Strings
```yaml
# Use proper multi-line syntax
arguments:
  - -c
  - |
    echo "Line 1"
    echo "Line 2"
    # Not this: | echo "Line 1"; echo "Line 2"
```

### 3. Environment Variable Usage
```yaml
# In GoCD YAML, use simple $ syntax
environment_variables:
  MY_VAR: value

# In commands, reference as:
command: echo $MY_VAR
# Not: echo ${MY_VAR}
```

### 4. Resource Matching
```yaml
# Resources must match what agents provide
resources:
  - docker     # Agent must have 'docker' resource
  - build      # Agent must have 'build' resource
```

## 🔧 Debugging Tools

### Check Specific Files
```bash
# Check if file is valid YAML
yq eval '.' my-file.gocd.yaml

# Check structure
yq eval 'keys' my-file.gocd.yaml

# Check for empty content
if [ ! -s my-file.gocd.yaml ]; then
  echo "File is empty!"
fi
```

### Monitor GoCD Config Repository
```bash
# Check config repo status in GoCD UI
# Admin → Config Repositories → Your Repository

# Check for parsing errors
docker logs gocd-server | grep -i "yaml\|config.*repo\|error"
```

## 📝 Template Best Practices

### Use YAML Anchors Effectively
```yaml
format_version: 10

common:
  # Define once, use many times
  standard-job: &standard-job
    resources:
      - docker
    tasks:
      - exec:
          command: /bin/bash
          arguments: ["-c", "echo 'Standard job'"]

  # Environment-specific config
  prod-env: &prod-env
    environment_variables:
      ENVIRONMENT: production
      LOG_LEVEL: warn

pipelines:
  app1:
    group: apps
    <<: *prod-env
    stages:
      - deploy:
          jobs:
            deploy-job:
              <<: *standard-job

  app2:
    group: apps  
    <<: *prod-env
    stages:
      - deploy:
          jobs:
            deploy-job:
              <<: *standard-job
```

## 🎯 Success Tips

1. **Start Simple:** Begin with basic pipelines
2. **Validate Often:** Run validation after every change
3. **Use Examples:** Copy from working configurations
4. **Test Locally:** Use yq to check YAML before committing
5. **Incremental Changes:** Add complexity gradually
6. **Read Errors Carefully:** GoCD error messages are usually specific
7. **Comment Wisely:** Avoid inline comments in command strings

---

## ✅ Current Status

All configurations in this repository now:
- ✅ Pass YAML validation
- ✅ Have proper structure for GoCD
- ✅ Avoid common syntax errors
- ✅ Follow best practices
- ✅ Include comprehensive examples

**Your pipeline as code setup is error-free and ready to use!** 🎉
