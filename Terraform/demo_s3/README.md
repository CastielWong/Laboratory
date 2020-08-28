

```sh
sudo apt-get update
sudo apt-get install -y python3-pip python-dev
pip3 install --upgrade pip
pip3 install awscli

# list files inside the bucket
aws s3 ls s3://{bucket}

# retrieve credential of the role
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/{role}
```
