#! /bin/bash

# This script will be responsible for provisioning the initail environment
# for the application. 
# It ensures that VPC, Security groups, DB server, Cloudfront distribution
# are provisioned to provide the base on with CI will run

# Source the stack helper script
source ./stack-helper.sh

DEFAULT_WORKFLOW_ID=eee56529-211a-4066-9b2a-a9509536533a

deploy_stack redis-solar-vpc redis-solar-vpc-stack.yml
deploy_stack redis-solar-security-groups security-groups-stack.yml
deploy_stack redis-solar-instance-profile instance-profile.yml "" CAPABILITY_NAMED_IAM
deploy_stack redis-solar-loadbalancer-${DEFAULT_WORKFLOW_ID} loadbalancer-stack.yml
deploy_stack redis-solar-natinstance-stack natinstance-stack.yml
deploy_stack redis-solar-redis-db redis-db-stack.yml

# The following stack with be created/or updated in the CI/CD Pipeline
# This will be replaced by CI/CD pipeline
deploy_stack redis-solar-backend-stack-${DEFAULT_WORKFLOW_ID} backend-stack.yml

# This will be Updated by CI/CD pipeline
deploy_stack redis-solar-cloudfront cloudfront.yml WorkflowId=${DEFAULT_WORKFLOW_ID}

# deploy_stack redis-solar-instance-profile instance-profile.yml --capabilities CAPABILITY_NAMED_IAM