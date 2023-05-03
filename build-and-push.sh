#!/bin/bash

AWS_REGION="eu-west-2"
REPOSITORY="484824883615.dkr.ecr.eu-west-2.amazonaws.com"
IMAGE=$REPOSITORY:latest

# docker login
aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $REPOSITORY

# docker build
sudo docker build -t flask-app .

# docker tag and push to AWS ECR
sudo docker tag flask-app $REPOSITORY/flask-app:latest
sudo docker push $REPOSITORY/flask-app:latest
