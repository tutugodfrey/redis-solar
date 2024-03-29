#! /bin/bash

. ./stack-helper.sh # Source the stack helper file

create_stack redis-solar-vpc-stack redis-solar-vpc-stack.yml redis-solar-vpc-parameters.json;
sleep 60;
create_stack security-groups-stack security-groups-stack.yml security-groups-parameters.json;
deploy_stack --stack-name redis-solar-instance-profile --template-file instance-profile.yml --capabilities CAPABILITY_NAMED_IAM
sleep 60;
create_stack loadbalancer-stack loadbalancer-stack.yml loadbalancer-parameters.json;
create_stack jump-stack jump-stack.yml jump-parameters.json;
create_stack redis-db-stack redis-db-stack.yml redis-parameter.json;
create_stack natinstance-stack natinstance-stack.yml natinstance-parameters.json

sleep 120;
create_stack frontend-stack frontend-stack.yml frontend-parameters.json;
create_stack backend-stack backend-stack.yml backend-parameter.json;
