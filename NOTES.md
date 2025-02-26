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

### Local

1. `aws sso login --profile admin`
   - This will open a browser window to login to AWS.
2. `terraform init` from the `terraform` directory
   - This will initialize the Terraform project and create the workspace, if it doesn't already exist.
   - Will create a `.terraform` directory and download the necessary providers.
3. `terraform plan -out=tfplan`
   - This will show you the changes that will be made to your AWS resources.
   - The `-out=tfplan` flag will save the plan to a file.
4. `terraform apply tfplan`
   - If running for the first time, this will create the necessary AWS resources.
     - **NOTE**: the ALB takes a few minutes to be created... be patient.
   - If running again, this will update the existing resources.
5. Go to ECR in the AWS console and find the repository you created > `View push commands`
   - This will show you the commands you need to run to push your Docker image to the ECR repository.
   - `aws ecr get-login-password --region us-east-1 --profile admin | docker login --username AWS --password-stdin 021891593951.dkr.ecr.us-east-1.amazonaws.com`
   - **NOTE**: had to add `--profile admin` to the `aws ecr get-login-password` command. Was getting an error without it.
6. `docker build --platform linux/amd64 -t hono-app .`
   - This will build the Docker image.
   - **NOTE**: need to explicitly build for linux/amd64 platform
7. `docker tag hono-app:latest 021891593951.dkr.ecr.us-east-1.amazonaws.com/hono-app:latest`
   - This will tag the Docker image.
8. `docker push 021891593951.dkr.ecr.us-east-1.amazonaws.com/hono-app:latest`
   - This will push the Docker image to the ECR repository.
9. `aws ecs update-service --cluster hono-app-cluster --service hono-app-service --force-new-deployment --profile admin --region us-east-1`
   - This will update the ECS service to use the new Docker image.
   - **NOTE**: had to add `--profile admin` to the command.

### [HCP Terraform](https://app.terraform.io/app/organizations)

- Is a Terraform cloud provider that manages runs in a consistent and reliable environment instead of on your local machine.
- Securely stores state and secret data, and can connect to version control systems so that you can develop your infrastructure using a workflow similar to application development.
- Has a private registry for sharing your organization's Terraform modules and providers.

#### CLI-based workflow

1. `terraform login`
   - This will log you in to HCP Terraform.
2. Configure `terraform.cloud {}` in the `terraform.tf` file.
3. `terraform init`
   - Once this is done, you can delete any local `.tfstate`, `.tfstate.backup`, and `.tfplan` files (this is now stored in HCP Terraform).
4. Authenticate to AWS
   - In the AWS console, go to IAM > Users > Create user > `terraform-admin` > Attach policies directly > AdministratorAccess.
     - Ideally, you should follow the principle of least privilege and create a new policy with only the necessary permissions.
   - Go to the user > Create access key.
   - In HCP Terraform, create a "Variable Set" with `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. Make sure to set them as "Environment" variables, not "Terraform" variables.
5. `terraform plan`
6. `terraform apply`
7. Either:
   - Review the plan in the console and type `yes` to apply it.
   - Go to the URL outputted in the console, review the plan, and click "Confirm & apply".

> There's also a **VCS(Version Control System)-based workflow** that is useful for teams. In short, PRs are created, reviewed, and merged in the same way as code.

### Storage Module

- After moving DynamoDB resources to the storage module, I had to make Terraform aware of the changes by running `terraform init` again. Additionally, I had to update the state to reflect the new resource addresses:
  - `terraform state mv aws_dynamodb_table.app_table module.storage.aws_dynamodb_table.app_table`

### ECR Module

- I decided to break out the ECR repository into its own "root" module so that I could manage it separately from the rest of the application.
  - This allows me to destroy/recreate the "app" resources without affecting the ECR repository and (more importantly) the image(s) in it.
  - Had I not done this, destroying then recreating the app would initially fail because the ECR repository would not contain the image that the app needs.

### `Development` Workspace

- Created a new `development` workspace to deploy the app to a different AWS region (`us-east-2`).
  - `terraform workspace new development` (returned `workspaces not supported` error)
    - **NOTE**: workspaces are managed differently when using HCP Terraform.
  - run `terraform workspace select default` to go back to the default workspace.

### Destroying the app

`terraform destroy`

### Other Commands

`terraform fmt`: automatically updates configurations in the current directory for readability and consistency.

`terraform validate`: checks the configuration files for syntax errors, formatting issues, and other potential problems.

`terraform show`: displays the current state of the Terraform configuration.

`terraform state list`: lists all resources managed by Terraform.

`terraform state mv <resource_name> <new_resource_name>`: moves a resource to a new name. Used to move resources between modules.

### Auto-Generating Docs

`terraform-docs markdown table --output-file README.md --output-mode inject /path/to/module`

## To Do

- [ ] lock down ALB DNS Name URL ("hono-app-alb-351534744.us-east-1.elb.amazonaws.com") - should not be able to access the app via this URL (I think..?)
- [ ] set up CI/CD pipeline to build the Docker image and push it to ECR
- [ ] Auto re-deploy ECS service when the Docker image is updated in ECR
- [x] Try destroying and recreating the app from scratch
- [ ] Auto-scaling - spin up task/instance on request instead of having one always running (to save money). Downside: cold start time.
- [x] Try using one (or more) of the [AWS modules from the Terraform registry](https://registry.terraform.io/browse/modules?provider=aws)
  - used the `cloudwatch` module to create the log group
  - used the `vpc` module to create the VPC, subnets, etc.
  - used the `security-group` module to create the security groups
- [ ] Deploy and run `terraform graph`
