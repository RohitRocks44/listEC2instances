import boto3
aws_management_console=boto3.session.Session(profile_name="default",region_name="us-east-1")
ec2_console=aws_management_console.client(service_name="ec2")

result=ec2_console.describe_instances()['Reservations']
for each_instance in result:
    for value in each_instance['Instances']:
        print(value['InstanceId'])
