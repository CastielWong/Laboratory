
- Allthe public subnets are connected to an Internet Gateway. These instances will also have a public IP address, allowing them to be reachable from the internet
- Instances launched in the private subnets don't get a public IP address, so they will not be reachable from the internet
- Instances in the same VPC should be able to communicate with each other if the firewall is set to allow traffic
- If a Load Banlancer is used, put the LB in the public subnets and the instances serving an application at the private subnets


Note that __NAT Gateway__ is not in AWS free tier.
