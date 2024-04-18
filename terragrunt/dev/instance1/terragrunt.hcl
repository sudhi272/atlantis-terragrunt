include {
  path = find_in_parent_folders()
}

terraform {
  source  = "../../../terraform-aws-ec2"
}

inputs = {
  ami_id = "ami-074dc0a6f6c764218"
  availability_zone = "ap-south-1a"
  instance_type = "t2.micro"
  tags =  "my_ec2_instance_dev"
}
