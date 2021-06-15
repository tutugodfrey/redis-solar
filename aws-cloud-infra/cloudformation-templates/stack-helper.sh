#! /bin/bash

# Set Default region,
# The default will be overriden by script if AWS_REGION is set in env
REGION=us-west-2

function help() {
  echo """
  This script provide helpful functions to facilitate working with cloudformation.
  To use the script you can set AWS_PROFILE, and AWS_REGION in environment variable to override the defaults
  The commands will attempt to use your default AWS profile, unless you specify AWS_PROFILE in env.
  The default region set in this script is us-west-2. To override it set AWS_REGION in env.
  Depending on what command you want to execute the functions expose will require stack_name, template-body file, and parameters file.
  
  The following functions are provided when you source the script

  create_stack STACK_NAME TEMPLATE_BODY_FILE PARAMETERS_FILE : Create a stack 
  
  update_stack STACK_NAME TEMPLATE_BDOY_FILE PARAMETERS_FILE : Update a stack

  delete_stack STACK_NAME  : Delete a stack

  describe_stack STACK_NAME : Describe a stack

  list_stack : list stacks in your account

  """
}

if [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
  help;
fi

# Create a stack with stack_name, template_body_file, parameters_file given
function deploy_stack () {
  STACK_NAME=$1
  TEMPLATE_BODY=$2
  PARAMETERS=$3
  AWS_PROFILE=${AWS_PROFILE} # get from environment

  # Use region set in env if available
  if [[ ! -z ${AWS_REGION} ]]; then
    REGION=${AWS_REGION}
  fi

  if [[ ! -z $AWS_PROFILE ]]; then
    # Check if AWS_PROFILE is set in ENV and use it
    # If providing $PARAMETERS as file make sure to use the format file://parameters-file.json
    aws cloudformation deploy --stack-name $STACK_NAME --region=$REGION --template-file $TEMPLATE_BODY --parameter-overrides $PARAMETERS --profile $AWS_PROFILE
  else
    # Use default AWS Profile
    aws cloudformation deploy --stack-name $STACK_NAME --region $REGION --template-file $TEMPLATE_BODY --parameter-overrides $PARAMETERS
  fi
  # aws cloudformation deploy --stack-name $STACK_NAME --template-body file://$PARAMETERS  --parameters file://$3 --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" --region=us-east-1
}

# Create a stack with stack_name, template_body_file, parameters_file given
function create_stack () {
  STACK_NAME=$1
  TEMPLATE_BODY=$2
  PARAMETERS=$3
  AWS_PROFILE=${AWS_PROFILE} # get from environment

  # Use region set in env if available
  if [[ ! -z ${AWS_REGION} ]]; then
    REGION=${AWS_REGION}
  fi

  if [[ ! -z $AWS_PROFILE ]]; then
    # Check if AWS_PROFILE is set in ENV and use it
    aws cloudformation create-stack --stack-name $STACK_NAME --region=$REGION --template-body file://$TEMPLATE_BODY --parameters file://$PARAMETERS --profile $AWS_PROFILE
  else
    # Use default AWS Profile
    aws cloudformation create-stack --stack-name $STACK_NAME --region $REGION --template-body file://$TEMPLATE_BODY --parameters file://$PARAMETERS
  fi
  # aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://$PARAMETERS  --parameters file://$3 --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" --region=us-east-1
}

# Update a stack with name, template_body_file, parameters_file given
function update_stack () {
  STACK_NAME=$1
  TEMPLATE_BODY=$2
  PARAMETERS=$3
  AWS_PROFILE=${AWS_PROFILE}

  # Use region set in env if available
  if [[ ! -z ${AWS_REGION} ]]; then
    REGION=${AWS_REGION}
  fi

  if [[ ! -z $AWS_PROFILE ]]; then
    aws cloudformation update-stack --stack-name $STACK_NAME --region $REGION --template-body file://$TEMPLATE_BODY  --parameters file://$PARAMETERS --profile $AWS_PROFILE
  else 
     aws cloudformation update-stack --stack-name $STACK_NAME --region $REGION --template-body file://$TEMPLATE_BODY  --parameters file://$PARAMETERS
  fi
}

# Delete a stack with name given
function delete_stack () {
  STACK_NAME=$1
  if [[ ! -z ${AWS_PROFILE} ]]; then
    aws cloudformation delete-stack --stack-name $STACK_NAME --profile $AWS_PROFILE
  else
    aws cloudformation delete-stack --stack-name $STACK_NAME
  fi
}

# Describe a stack with name given
function describe_stack () {
  STACK_NAME=$1
  AWS_PROFILE=${AWS_PROFILE}

  if [[ ! -z $AWS_PROFILE ]]; then
    aws cloudformation delete-stack --stack-name $STACK_NAME --profile $AWS_PROFILE
  else 
    aws cloudformation delete-stack --stack-name $STACK_NAME
  fi
}

# List stacks in your account
function list_stack () {
  AWS_PROFILE=${AWS_PROFILE}

  if [[ ! -z $AWS_PROFILE ]]; then
    aws cloudformation list-stacks --profile $AWS_PROFILE
  else
    aws cloudformation list-stacks
  fi
}
