resource "aws_instance" "example_instance" {
  ami           = "ami-0a0f1259dd1c90938"
  instance_type = "t2.micro"               

  tags = {
    Name = var.instance_name
  }
}