provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["../../.credentials"]
}

locals {
  ami           = "ami-005f9685cb30f234b"
  instance_type = "t2.micro"
}

variable "jupyter_pass" {
    type = string
    description = "Jupyter pass"
}

resource "aws_eip" "jupyter" {
  instance = aws_instance.jupyter.id
}

resource "aws_instance" "jupyter" {
  ami           = local.ami
  instance_type = local.instance_type

  key_name = "terraform_key"

  provisioner "file" {
    source      = "./init_jupyter.bash"
    destination = "/tmp/init_jupyter.bash"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("../../terraform_key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init_jupyter.bash",
      "sudo /tmp/init_jupyter.bash ${var.jupyter_pass}",
    ]
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.allow_http_ssh.id
  network_interface_id = aws_instance.jupyter.primary_network_interface_id
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh_traffic"
  description = "Allow HTTP/SSH Traffic"

  ingress {
    description      = "Allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_ssh"
  }
}

output "jupyter_url" {
    value = "http://${aws_eip.jupyter.public_ip}"
}