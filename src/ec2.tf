locals {
    ami = "ami-005f9685cb30f234b"
    instance_type = "t2.micro"
}

resource "aws_instance" "web_page" {
  ami = local.ami
  instance_type = local.instance_type
  
  subnet_id   = aws_subnet.public.id
  depends_on = [
    aws_subnet.public
  ]
}

resource "aws_instance" "backend" {
    ami = local.ami
    instance_type = local.instance_type

    subnet_id   = aws_subnet.public.id
    depends_on = [
      aws_subnet.public
    ] 
}

resource "aws_instance" "database" {
    ami = local.ami
    instance_type = local.instance_type

    subnet_id = aws_subnet.private.id
    depends_on = [
      aws_subnet.private
    ] 
}

resource "aws_instance" "jupyter" {
  ami = local.ami
  instance_type = local.instance_type
  
  subnet_id   = aws_subnet.public.id
  depends_on = [
    aws_subnet.public
  ]
}

resource "aws_eip" "jupyter" {
    instance = aws_instance.jupyter.id
    vpc = true
}