import boto3
from botocore.exceptions import ClientError

ecs = boto3.client('ecs')
rds = boto3.client('rds')

def lambda_handler(event, context):
    try:
        if 'ecs' in event:
            ecs_info = event['ecs']
            update_ecs_states(ecs_info)

        if 'rds' in event:
            rds_info = event['rds']
            update_rds_states(rds_info)
            
    except ClientError as e:
        print("exception: %s" % e)
    

def update_ecs_states(ecs_info):
    for service_info in ecs_info:
        service_update_result = ecs.update_service(
            cluster = service_info['cluster'],
            service = service_info['service'],
            desiredCount = service_info['desiredCount']
        )
        print(service_update_result)


def update_rds_states(rds_info):
    for cluster_info in rds_info:

        if cluster_info['action'] == "start":
            cluster_update_result = rds.start_db_cluster(
                DBClusterIdentifier = cluster_info['DBClusterIdentifier']
            )
            print(cluster_update_result)

        if cluster_info['action'] == "stop":
            cluster_update_result = rds.stop_db_cluster(
                DBClusterIdentifier = cluster_info['DBClusterIdentifier']
            )
            print(cluster_update_result)