# GoCD YAML Plugin doesn't support standalone templates
# Templates must be defined within pipeline files
# This file shows the template structure for reference

# To use templates, define them within a pipeline file like this:
# 
# format_version: 10
# common:
#   deploy-template: &deploy-template
#     stages:
#       - build:
#           jobs:
#             package:
#               resources:
#                 - docker
#               tasks:
#                 - exec:
#                     command: /bin/bash
#                     arguments:
#                       - -c
#                       - echo "Building application"
#       - deploy:
#           approval:
#             type: manual
#           jobs:
#             deploy:
#               resources:
#                 - docker
#               tasks:
#                 - exec:
#                     command: /bin/bash
#                     arguments:
#                       - -c
#                       - ./scripts/deploy.sh
# 
# pipelines:
#   my-app:
#     group: deployment
#     materials:
#       git:
#         git: https://github.com/your-org/your-app.git
#     <<: *deploy-template

# Alternative: Use YAML anchors and references within the same file
# See pipelines/template-example.gocd.yaml for a working example