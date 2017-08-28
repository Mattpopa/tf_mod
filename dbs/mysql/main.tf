resource "aws_db_instance" "wipdb080817" {
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "${terraform.env}"
    username = "toor"
    password = "${var.dbs_pass}"
    skip_final_snapshot = true 
}
