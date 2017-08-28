output "db_address" {
  value = "${aws_db_instance.wipdb080817.address}"
}

output "db_port" {
  value = "${aws_db_instance.wipdb080817.port}"
}
