#!/bin/sh

set -e
echo start entrypoint

PJ_PREFIX="nasu"
ENV_PREFIX="prod"
PROFILE_NAME="nasu-infra"
CLUSTER_NAME=$(aws ssm get-parameter --query "Parameter.Value" --output text --name /${PJ_PREFIX}/${ENV_PREFIX}/flask/CLUSTER_NAME --profile ${PROFILE_NAME})
TASKDEF_ARN="arn:aws:ecs:ap-northeast-1:267751904634:task-definition/nasu-prod-migrate-fargate-task:15"
NETWORK_CONFIG=$(aws ssm get-parameter --query "Parameter.Value" --output text --name /${PJ_PREFIX}/${ENV_PREFIX}/flask/NETWORK_CONFIG --profile ${PROFILE_NAME})

RUN_TASK_DETAIL=$(aws ecs run-task --cluster ${CLUSTER_NAME} --task-definition ${TASKDEF_ARN} --network-configuration ${NETWORK_CONFIG} --launch-type FARGATE)
echo ${RUN_TASK_DETAIL}| jq -r 

TASK_ARN=$(echo ${RUN_TASK_DETAIL}| jq -r '.tasks[0].taskArn')
echo ${TASK_ARN}

while true
do
  sleep 6

  TASK_DETAIL=$(aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_ARN})
  echo ${TASK_DETAIL}| jq -r 

  TASK_STATUS=$(echo ${TASK_DETAIL}| jq -r '.tasks[0].lastStatus')

    if [ -n "${TASK_STATUS}" ] && [ "${TASK_STATUS}" = "STOPPED" ]; then
      echo "task is stopped"
      break;
    fi

  echo "task is not stopped"
  echo "task status is ${TASK_STATUS}"
done

exec "$@"