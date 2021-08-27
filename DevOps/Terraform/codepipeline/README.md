
This is demo for __CodePipeline__. Basically, AWS __CodePipeline__ integrates with:

- CodeCommit: git repository
- CodeBuild: launch EC2 instance to run test/build phase, as well as docker builds
- CodeDeploy: deploy on EC2/Lambda/ECS

This demo is going to use __CodeCommit__ + __CodeBuild__ to build a NodeJS docker image with the application code bundled, then apply __CodeDeploy__ to deploy it on ECS. The Deploy stage would switch from blue target group to green target group, which means the blue group would turned from active to inactive, while the green one would be adverse.

1. Initialize Terraform: `terraform init`
1. Provision all AWS services: `terraform apply --auto-approve`
1. After complete, first stage should be failed since there is nothing in __CodeCommit__
1. Work on __CodeCommit__
    1. Copy files in "app/" to an empty folder outside current git repo
        ```sh
        git init
        git add .
        git commit -m "Initial Commit"
        ```
    1. Attach SSH public key to the AWS user so that the user is able to push repo to __CodeCommit__
    1. Clone SSH URL of the git repo from __CodeCommit__
    1. Add current git remote to the repo on __CodeCommit__: `git remote add origin ssh://{user_ssh_key}@{url}`
    1. Push all file to the __CodeCommit__ repo: `git push -u origin master`
1. After the repo is pushed, __CodePipeline__ should start working
1. Check services below to see the difference:
    - CodePiepline
    - CodeDeploy
    - ECR
    - ECS: from "blue" to "green"
    - S3
1. Go to __CodeDeploy__ to verify the status

If haven't, remember to add SSH private key to the local git via `ssh-add {ssh_key}`.

Before running `terraform destroy`, make sure the S3 bucket has been emptied. The image on ECR wouldn't be destroyed and it would still exist. So don't forget to delete it if it's no longer needed.

Note:
"buildspec.yml" inside "app/" will take effect since "codecommit.tf" has already linked it to trigger.
