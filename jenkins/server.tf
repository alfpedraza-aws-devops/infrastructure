# ----------------------------------------------------------------------------#
# Get the AMI for the Jenkins server                                          #
# ----------------------------------------------------------------------------#

data "aws_ami" "server_image" {
  most_recent = true
  owners = ["161831738826"]

  filter {
    name   = "name"
    values = ["centos-7-base-*"]
  }
}

# ----------------------------------------------------------------------------#
# Create the Jenkins server in the private Jenkins subnet                     #
# ----------------------------------------------------------------------------#

resource "aws_instance" "jenkins" {
  subnet_id              = aws_subnet.private_jenkins.id
  ami                    = data.aws_ami.server_image.id
  instance_type          = var.server_instance_type
  key_name               = data.terraform_remote_state.vpc.outputs.key_name
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  user_data              = join("\n", [
                           "#!/bin/bash",
                           "PROJECT_NAME=${var.project_name}",
                           file("${path.module}/scripts/setup-jenkins.sh")])

  tags = merge(local.common_tags, map(
    "Name", "jenkins"
  ))

  # Store the passwords and secret information as RAM files, so they are never
  # written to disk. Once the user_data script reads them, it deletes these files.
  # This uses ssh so the data is kept safe while is in transit to the instance.
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /dev/shm/aws-devops/credentials",
      "echo ${var.jenkins_admin_password} > /dev/shm/aws-devops/credentials/jenkins-admin-password",
      "echo ${var.aws_access_key_id} > /dev/shm/aws-devops/credentials/aws-access-key-id",
      "echo ${var.aws_secret_access_key} > /dev/shm/aws-devops/credentials/aws-secret-access-key",
    ]
    connection {
      type  = "ssh"
      user  = "centos"
      host  = self.private_ip
    }
  }
}

# ----------------------------------------------------------------------------#
# Create the firewall rules for the NAT gateway                               #
# ----------------------------------------------------------------------------#

resource "aws_security_group" "jenkins" {
  name        = "jenkins"
  description = "Allows access to the Jenkins server."
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Ingress Rules

  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress Rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, map(
    "Name", "jenkins"
  ))
}