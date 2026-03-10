output "dev_public_ip" {
    value = aws_instance.dev.public_ip
  
}
output "dev_private_ip" {
    value = aws_instance.dev.private_ip
  
}
output "dev_az" {
    value = aws_instance.dev.availability_zone
  
}

output "test_public_ip" {
    value = aws_instance.test.public_ip
  
}
output "test_private_ip" {
    value = aws_instance.test.private_ip
  
}
output "test_az" {
    value = aws_instance.test.availability_zone
  
}