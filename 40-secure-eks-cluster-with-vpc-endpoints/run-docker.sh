#!/usr/bin/bash


# build docker image
docker build -t my-nginx-test .


# set environment variables
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO=example_repo


# configure docker client to aunthenticate to ECR
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS \
  --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com


# tag the local image with AWS ECR required format
docker tag my-nginx-test:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

# push image to ECR
docker push \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest