output "public_instance_id" {
  value = aws_instance.public_instance.id
}

output "private_instance_id" {
  value = aws_instance.private_instance.id
}

output "public_ip" {
  value = aws_instance.public_instance.public_ip
  
}

output "private_ip" {
  value = aws_instance.private_instance.public_ip
  
}
