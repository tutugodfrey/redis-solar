#! /bin/bash

. ./stack-helper.sh # Source the stack helper file

create_stack redis-solar-vpc-stack redis-solar-vpc-stack.yml redis-solar-vpc-parameters.json;
sleep 15;
create_stack security-groups-stack security-groups-stack.yml security-groups-parameters.json;

sleep 15;
create_stack loadbalancer-stack loadbalancer-stack.yml loadbalancer-parameters.json;
create_stack jump-stack jump-stack.yml jump-parameters.json;
create_stack redis-db-stack redis-db-stack.yml redis-parameter.json;

sleep 60;
create_stack frontend-stack frontend-stack.yml frontend-parameters.json;
create_stack backend-stack backend-stack.yml backend-parameter.json;
