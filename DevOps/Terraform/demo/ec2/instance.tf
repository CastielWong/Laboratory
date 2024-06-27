
resource "aws_key_pair" "demo_tf" {
  key_name = var.KEY_NAME
  public_key = file("../${var.KEY_NAME}.pub")
}

resource "aws_instance" "demo" {
  ami           = lookup(var.AMIS, var.AWS_REGION)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.demo_tf.key_name

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      # remove spurious CR characters
      "sudo sed -i -e 's/\r$//' /tmp/script.sh",
      "sudo /tmp/script.sh",
    ]
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.demo.private_ip} >> private_ips.txt"
  }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file("../${var.KEY_NAME}")
  }
}

output "ip" {
  value = aws_instance.demo.public_ip
}
