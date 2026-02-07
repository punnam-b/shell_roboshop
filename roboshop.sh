#!/bin/bash

SG_ID="sg-0c6bdbce9861ee385"
AMI_ID="ami-0220d79f3f480ecf5"
DOMAIN_NAME="dhruvanakshatra.in"
ZONE_ID="Z0402874NS4TU28JU0M9"


for instance in $@
do
        INSTANCE_ID=$( aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro  \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
         --query 'Instances[0].InstanceId' \
        --output text )

        if [ $instance == "frontend" ]; then
        IP=$( aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \
                --query 'Reservations[].Instances[].PublicIpAddress' \
                --output text
            )
            RECORD_NAME=$DOMAIN_NAME
        else        
        IP=$( aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \
                --query 'Reservations[].Instances[].PrivateIpAddress' \
                --output text
            )
            RECORD_NAME=$instance.$DOMAIN_NAME
        fi
        echo "IP Address is $IP"


aws route53 change-resource-record-sets \
            --hosted-zone-id $ZONE_ID \
            --change-batch ' {
                "Comment": "Update A record for www.example.com",
                "Changes": [
                    {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$RECORD_NAME'",
                        "Type": "A",
                        "TTL": 300,
                        "ResourceRecords": [
                        {
                            "Value": "'$IP'"
                        }
                        ]
                    }
                    }
                ]
                }'
                echo "Record updated for $instance"



done


#aws ec2 run-instances --image-id ami-0220d79f3f480ecf5  --instance-type t3.micro --security-group-ids sg-0c6bdbce9861ee385 --query 'Instances[0].PrivateIpAddress'  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=test}]' --output text
#aws ec2 describe-instances --instance-ids i-06f1f961562363b62 --query 'Reservations[].Instances[].PublicIpAddress' --output text
