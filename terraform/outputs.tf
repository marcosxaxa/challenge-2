output "webserver" {
  value = aws_instance.app.public_ip
}