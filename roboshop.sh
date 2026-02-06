#!/bin/bash

SG_ID="sg-0c6bdbce9861ee385"
AMI_ID="ami-0220d79f3f480ecf5"



for intance in $@
do
        INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro  \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
         --query 'Instances[0].InstanceId' \
        --output text
        )

        if [ $instance == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \
                --query 'Reservations[].Instances[].PublicIpAddress' \
                --output text
            )
        else        
        IP=$(aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \
                --query 'Reservations[].Instances[].PrivateIpAddress' \
                --output text
            )
        fi

done


#aws ec2 run-instances --image-id ami-0220d79f3f480ecf5  --instance-type t3.micro --security-group-ids sg-0c6bdbce9861ee385 --query 'Instances[0].PrivateIpAddress'  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=test}]' --output text


#aws ec2 describe-instances --instance-ids i-06f1f961562363b62 --query 'Reservations[].Instances[].PublicIpAddress' --output text
