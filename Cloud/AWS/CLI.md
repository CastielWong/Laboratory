
- [General](#general)
- [ECR](#ecr)


## General
```sh
# initialize profile
aws configure

# set the default profile
export AWS_PROFILE="{profile}"  # switch profile by updating
export AWS_ACCESS_KEY_ID="{access_key}"
export AWS_SECRET_ACCESS_KEY="{secret_key}"
export AWS_ACCOUNT_ID="{account}"
export AWS_REGION="ap-east-1"
export CLUSTER_NAME="{name}"
export EKS_CLUSTER="arn:aws:eks:${AWS_REGION}:${AWS_ACCOUNT_ID}:cluster/${CLUSTER_NAME}"

# profile
# check current profile
aws configure list
# check current role
aws iam get-account-authorization-details
# check identity
aws sts get-caller-identity --profile ${AWS_PROFILE}

# set EKS for kubectl to access
aws eks list-clusters --profile ${AWS_PROFILE}
aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
```


## ECR
```sh
export IMAGE_SHA={image}

aws ecr describe-repositories
aws ecr describe-images --repository-name ${ECR_REPO}

# authenticate Docker to ECR under current profile
aws ecr get-login-password --profile ${AWS_PROFILE} --region ${AWS_REGION} |
docker login --username AWS \
--password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

aws ecr create-repository --repository-name ${ECR_REPO}

docker build --build-arg http_proxy=$HTTP_PROXY \
-f ./Dockerfile -t {tag} .

docker tag ${IMAGE_SHA} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${ECR_TAG}

# push image to ECR
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${ECR_TAG}
```
