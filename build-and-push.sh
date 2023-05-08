#!/usr/bin/env bash

set -eoux pipefail

AWS_REGION=$1
REPOSITORY=$2

# docker login
aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $REPOSITORY

# docker build
sudo docker build -t flask-app .

# docker tag and push to AWS ECR
sudo docker tag flask-app $REPOSITORY/flask-app:latest
sudo docker push $REPOSITORY/flask-app:latest

# Execute terraform module to create flask app aws Infra Creation
#./deploy.sh $AWS_REGION "$REPOSITORY/flask-app"