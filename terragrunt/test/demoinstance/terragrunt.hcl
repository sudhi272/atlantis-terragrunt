include {
  path = find_in_parent_folders()
}

terraform {
  source  = "../../../terraform-aws-ec2"
}

inputs = {
  ami_id = "ami-0a0f1259dd1c90938"
  availability_zone = "ap-south-1a"
  instance_type = "t2.micro"
  tags =  "my_ec2_test_demo"
}
