#! /bin/bash

# This script will be responsible for provisioning the initail environment
# for the application. 
# It ensures that VPC, Security groups, DB server, Cloudfront distribution
# are provisioned to provide the base on with CI will run

# Source the stack helper script
source ./stack-helper.sh

# Set the default WorkflowId, or use CircleCI WORKDLOW ID
WORKFLOW_ID=eee56529-211a-4066-9b2a-a9509536533a
if [[ ! -z $CIRCLE_WORKFLOW_ID ]]; then
  WORKFLOW_ID=${CIRCLE_WORKFLOW_ID}
fi

echo Workflow ID is $WORKFLOW_ID
echo Environment is ${ENVIRONMENT}
echo Environment is $ENVIRONMENT
# Enforce Dev as the default environment
if [[ -z $ENVIRONMENT ]]; then
  ENVIRONMENT=Dev
fi


deploy_stack redis-solar-${ENVIRONMENT}-vpc redis-solar-vpc-stack.yml "EnvironmentName=${ENVIRONMENT}"
deploy_stack redis-solar-${ENVIRONMENT}-security-groups security-groups-stack.yml "EnvironmentName=${ENVIRONMENT}"
deploy_stack redis-solar-${ENVIRONMENT}-instance-profile instance-profile.yml "EnvironmentName=${ENVIRONMENT}" CAPABILITY_NAMED_IAM
deploy_stack redis-solar-${ENVIRONMENT}-natinstance natinstance-stack.yml "EnvironmentName=${ENVIRONMENT}"
deploy_stack redis-solar-${ENVIRONMENT}-loadbalancer-${WORKFLOW_ID} loadbalancer-stack.yml "EnvironmentName=${ENVIRONMENT}  WorkflowId=${WORKFLOW_ID}"
deploy_stack redis-solar-${ENVIRONMENT}-redis-db redis-db-stack.yml "EnvironmentName=${ENVIRONMENT}"

# The following stack with be created/or updated in the CI/CD Pipeline
# This will be replaced by CI/CD pipeline
deploy_stack redis-solar-${ENVIRONMENT}-backend-app-${WORKFLOW_ID} backend-stack.yml "EnvironmentName=${ENVIRONMENT} WorkflowId=${WORKFLOW_ID}"

# This will be Updated by CI/CD pipeline
deploy_stack redis-solar-${ENVIRONMENT}-cloudfront cloudfront.yml "EnvironmentName=${ENVIRONMENT} WorkflowId=${WORKFLOW_ID} CertificateARN=${CertificateARN} DomainName=${DomainName}"

# deploy_stack redis-solar-instance-profile instance-profile.yml --capabilities CAPABILITY_NAMED_IAM

# Create Route53 hosted zone with alias record for production use
if [[ $ENVIRONMENT == Prod ]]; then
  deploy_stack redis-solar-${ENVIRONMENT}-route53 route53-stack.yml "EnvironmentName=${ENVIRONMENT} DomainName=${DomainName} "
fi