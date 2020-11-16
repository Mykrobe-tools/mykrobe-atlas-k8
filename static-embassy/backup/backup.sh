#!/bin/bash

# Settings
date=`date +"%d%m%y"`
old_date=`date +"%d%m%y" -d "10 day ago"`

# Create the db dump
mongodump --host=$DB_HOST --port=$DB_PORT --username=$MONGO_USER --password=$MONGO_PASSWORD --out=/home/ubuntu/dump

# Zip the files
zip -r /home/ubuntu/backups/mongo_$date.zip /home/ubuntu/dump

# Replace env variables in s3cfg
#sed "s#{ACCESS_KEY}#$ACCESS_KEY#g" /root/.s3cfg > /root/.s3cfg1
#sed "s#{SECRET_KEY}#$SECRET_KEY#g" /root/.s3cfg1 > /root/.s3cfg2
#mv /root/.s3cfg2 /root/.s3cfg

# Transfer to S3
# s3cmd put /home/ubuntu/backups/uploads_$date.zip s3://$S3_BUCKET/uploads/uploads_$date.zip

# Remove old files
#s3cmd del s3://$S3_BUCKET/mysql/mysql_$old_date.zip

# Clean up
rm /home/ubuntu/backups/mongo_$date.zip