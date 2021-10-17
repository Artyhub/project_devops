provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "server" {
  ami = "ami-05f7491af5eef733a"  # Need exactly this for free tier
  instance_type = "t2.micro"
  vpc_security_group_ids =  [ aws_security_group.my_server.id ]
  key_name = aws_key_pair.deployer.key_name
  tags = {
    Name = "servertest"
  }
}

resource "aws_instance" "server2" {
  ami = "ami-05f7491af5eef733a"  # Need exactly this for free tier
  instance_type = "t2.micro"
  vpc_security_group_ids =  [ aws_security_group.my_server.id ]
  key_name = aws_key_pair.deployer.key_name
  tags = {
    Name = "serverstage"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "arty-desktop"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "my_server" {
  name        = "Project Servers SecGroup"
  description = "Allow 22,80,8080,8090"
  
  ingress = [
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["109.87.22.73/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    },
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    },
    {
      description      = "HTTP jenk"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    },
    {
      description      = "HTTP app"
      from_port        = 8090
      to_port          = 8090
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  egress = [
    {
      description      = "all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false   }
  ]

}

output "servertest_public_ip" {
  description = "Servertest public ip"
  value = aws_instance.server.public_ip
}

output "serverstage_public_ip" {
  description = "Serverstage public ip"
  value = aws_instance.server2.public_ip
}
