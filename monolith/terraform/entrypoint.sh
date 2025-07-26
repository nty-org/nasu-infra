#!/bin/sh
set -e
echo start entrypoint

PROFILE_NAME="nasu-infra"
PJ_PREFIX="nasu"
ENV_PREFIX="prod"

AWS_ACCOUT_ID=$(aws ssm get-parameter --query "Parameter.Value" --output text --name /${PJ_PREFIX}/${ENV_PREFIX}/AWS_ACCOUNT_ID --profile ${PROFILE_NAME})
CLUSTER_NAME=$(aws ssm get-parameter --query "Parameter.Value" --output text --name /${PJ_PREFIX}/${ENV_PREFIX}/flask/CLUSTER_NAME --profile ${PROFILE_NAME})
TASKDEF_NAME_MIGRATE=$(aws ssm get-parameter --query "Parameter.Value" --output text --name /${PJ_PREFIX}/${ENV_PREFIX}/flask/TASKDEF_NAME_MIGRATE --profile ${PROFILE_NAME})
NETWORK_CONFIG=$(aws ssm get-parameter --query "Parameter.Value" --output text --name /${PJ_PREFIX}/${ENV_PREFIX}/flask/NETWORK_CONFIG --profile ${PROFILE_NAME})
IMAGE_REPOSITORY_NAME=${PJ_PREFIX}/${ENV_PREFIX}/api
REPOSITORY_URI=${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${IMAGE_REPOSITORY_NAME}

echo parameter is setted

aws ecs describe-task-definition --task-definition ${TASKDEF_NAME_MIGRATE} --profile ${PROFILE_NAME} \
|jq '.taskDefinition| del (.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)' \
|jq '.containerDefinitions[].image |= "'${REPOSITORY_URI}:latest'"' > taskdef_migrate.json
TASKDEF_DETAIL=$(aws ecs register-task-definition --cli-input-json file://taskdef_migrate.json)

rm taskdef_migrate.json

TASKDEF_ARN=$(echo ${TASKDEF_DETAIL}| jq -r '.taskDefinition.taskDefinitionArn')
echo "new taskdef:${TASKDEF_ARN}"

LOG_GROUP_NAME=$(echo $TASKDEF_DETAIL| jq -r '.taskDefinition.containerDefinitions[].logConfiguration.options."awslogs-group"')
echo "log group name:${LOG_GROUP_NAME}"

RUN_TASK_DETAIL=$(aws ecs run-task --cluster ${CLUSTER_NAME} --task-definition ${TASKDEF_ARN} --network-configuration ${NETWORK_CONFIG} --launch-type FARGATE)
echo ${RUN_TASK_DETAIL}| jq -r

exec "$@"