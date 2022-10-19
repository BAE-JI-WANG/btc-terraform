provider "aws" {
  region = "ap-northeast-2" # Asia Pacific (Seoul) region
}

resource "aws_instance" "web2" {
  ami           = "ami-0c76973fbe0ee100c" # Amazon Linux 2 (us-east-2)
  instance_type = "t3.micro"
}
