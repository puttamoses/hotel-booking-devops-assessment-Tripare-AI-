output "address" {
  value = aws_db_instance.main.address
}

output "endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = true
}

output "port" {
  value = aws_db_instance.main.port
}

output "identifier" {
  value = aws_db_instance.main.identifier
}
