#!/bin/bash -e

# Wait for EFS creation
sleep 120

# Set ECS cluster name
echo "ECS_CLUSTER=${ecs_cluster_name}" > /etc/ecs/ecs.config

# Mount EFS
yum install -y nfs-utils curl
EFS_PATH="/srv/synced"
EC2_AVAIL_ZONE="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
EC2_REGION="$(echo $EC2_AVAIL_ZONE | sed 's/[a-z]$//')"
mkdir -p $EFS_PATH
# https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-general.html
echo "$EC2_AVAIL_ZONE.${efs_id}.efs.$EC2_REGION.amazonaws.com:/ $EFS_PATH nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" >> /etc/fstab
mount -a
