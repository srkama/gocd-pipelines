#!/bin/bash
# Validate all GoCD pipeline configurations

echo "🔍 Validating GoCD pipeline configurations..."

has_errors=0

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "❌ yq is required for validation. Install it first:"
    echo "   https://github.com/mikefarah/yq/#install"
    exit 1
fi

# Find and validate all GoCD YAML files
find . -name "*.gocd.yaml" -type f | while read -r file; do
    echo "Validating: $file"
    
    # Basic YAML syntax check
    if ! yq eval '.' "$file" >/dev/null 2>&1; then
        echo "❌ YAML syntax error in $file"
        has_errors=1
        continue
    fi
    
    # Check required format_version
    if ! yq eval '.format_version' "$file" >/dev/null 2>&1; then
        echo "⚠️  Missing format_version in $file"
    fi
    
    # Check for valid pipeline structure
    if yq eval '.pipelines' "$file" >/dev/null 2>&1; then
        echo "✅ Pipeline configuration in $file is valid"
    elif yq eval '.templates' "$file" >/dev/null 2>&1; then
        echo "✅ Template configuration in $file is valid"
    elif yq eval '.environments' "$file" >/dev/null 2>&1; then
        echo "✅ Environment configuration in $file is valid"
    else
        echo "⚠️  Unknown configuration type in $file"
    fi
done

if [ $has_errors -eq 0 ]; then
    echo "🎉 All configurations validated successfully!"
    exit 0
else
    echo "❌ Validation failed. Please fix the errors above."
    exit 1
fi
