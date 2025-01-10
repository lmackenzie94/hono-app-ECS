# Notes

## Local Development

`docker compose up`

You ran `aws configure` and used `local` for everything and `json` for the output format. These values don't matter for local development.

To create the local DynamoDB table, you ran:

```bash
aws dynamodb create-table \
    --endpoint-url http://localhost:8000 \
    --table-name ViewCounter \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
    --key-schema \
        AttributeName=id,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5
```

## Deploying to AWS ECS

1. `aws sso login --profile admin`
   - This will open a browser window to login to AWS.
2. `terraform init` from the `terraform` directory
   - This will create a `.terraform` directory and download the necessary providers.
3. `terraform plan`
   - This will show you the changes that will be made to your AWS resources.
4. `terraform apply`
   - If running for the first time, this will create the necessary AWS resources.
   - If running again, this will update the existing resources.
5. Go to ECR in the AWS console and find the repository you created > `View push commands`
   - This will show you the commands you need to run to push your Docker image to the ECR repository.
   - `aws ecr get-login-password --region us-east-1 --profile admin | docker login --username AWS --password-stdin 021891593951.dkr.ecr.us-east-1.amazonaws.com`
   - **NOTE**: had to add `--profile admin` to the `aws ecr get-login-password` command. Was getting an error without it.
6. `docker build --platform linux/amd64 -t hono-app .`
   - This will build the Docker image.
   - **NOTE**: Need to explicitly build for linux/amd64 platform
7. `docker tag hono-app:latest 021891593951.dkr.ecr.us-east-1.amazonaws.com/hono-app:latest`
   - This will tag the Docker image.
8. `docker push 021891593951.dkr.ecr.us-east-1.amazonaws.com/hono-app:latest`
   - This will push the Docker image to the ECR repository.
9. `aws ecs update-service --cluster hono-app-cluster --service hono-app-service --force-new-deployment --profile admin --region us-east-1`
   - This will update the ECS service to use the new Docker image.
   - **NOTE**: Had to add `--profile admin` to the command.
