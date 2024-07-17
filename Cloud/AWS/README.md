
Keep the most commonly used script to launch Amazon Web Services.

- [General](#general)
- [Template](#template)
  - [Generic](#generic)
  - [Proxy](#proxy)

## General

To use AWS CLI, ensure the security credential (both access key ID and secret access key) is created and added to "~/.aws/credentials".
```sh
aws cloudformation create-stack \
    --template-body file://<CURRENT_DIR>/<CONFIG>.yaml \
     --parameters ParameterKey=UserData,ParameterValue=$(base64 <CURRENT_DIR>/<SCRIPT>.sh) \
    --stack-name <name>

aws cloudformation delete-stack \
    --stack-name <name>
```

To check the finger print of a PEM file, run `openssl pkcs8 -in Tibra.pem -nocrypt -topk8 -outform DER | openssl sha1 -c`.


## Template

### Generic
This is a template for the most generic stack, which will create two instances connected:
```sh
aws cloudformation create-stack \
    --template-body file://generic/cf.yaml \
    --parameters \
        ParameterKey=Ec2PemKey,ParameterValue="<name_of_pem>" \
        ParameterKey=UserData,ParameterValue=$(base64 generic/init.sh) \
    --stack-name generic

aws cloudformation delete-stack \
    --stack-name generic
```

### Proxy
This is to launch a proxy server via V2Ray:
```sh
aws cloudformation create-stack \
    --template-body file://proxy/cf.yaml \
    --parameters \
        ParameterKey=Ec2PemKey,ParameterValue="<name_of_pem>" \
        ParameterKey=UserData,ParameterValue=$(base64 proxy/init.sh) \
    --stack-name walless

aws cloudformation delete-stack \
    --stack-name walless
```
