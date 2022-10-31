output "ubuntu_ami" {
 value = data.aws_ami.ubuntu.image_id
}