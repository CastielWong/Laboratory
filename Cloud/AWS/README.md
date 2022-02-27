
Keep the most commonly used script to launch AWS services.

To use AWS CLI, ensure the security credential (both access key ID and secret access key) is created and added to "~/.aws/credentials".
```sh
aws cloudformation create-stack \
    --template-body file:///<CURRENT_DIR>/<CONFIG.YAML> \
    --stack-name <name>

aws cloudformation delete-stack \
    --stack-name <name>

```
