
To build the AMI image, __Packer__ is needed.
Run `brew install packer` to install it first.

Before building the image, run `aws configure list` to ensure credential to set up appropriately.

Run `./build_and_launch.sh` to pack up the AMI other than `terraform apply`.

The constructed image would reside under the page of [EC2](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images).

Remember to delete / deregister the AMI if it's just for testing.
