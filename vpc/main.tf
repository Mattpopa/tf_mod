resource "aws_vpc" "m1_vpc" {
  cidr_block           = "${var.vpc_cidr[terraform.workspace]}"
  enable_dns_hostnames = true

  tags {
    Name        = "m1_${terraform.workspace}"
    Description = "For testing purposes"
    Environment = "${terraform.workspace}"
  }

  lifecycle {
    "ignore_changes" = ["tags.Description", "cidr_block"]
  }
}

resource "aws_subnet" "pub" {
  count                   = 2
  vpc_id                  = "${aws_vpc.m1_vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr[terraform.workspace], 3, count.index)}"
  availability_zone       = "${var.availability_zones[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${terraform.workspace}_m1_subnet_${format("%c", 97 + count.index)}"
    Environment = "${terraform.workspace}"
  }

  lifecycle {
    ignore_changes = "cidr_block"
  }
}

resource "aws_route_table_association" "pub" {
  count          = 2
  subnet_id      = "${aws_subnet.pub.*.id[count.index]}"
  route_table_id = "${aws_route_table.pub.*.id[count.index]}"
}

resource "aws_subnet" "private_elb" {
  count                   = 2
  vpc_id                  = "${aws_vpc.m1_vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr[terraform.workspace], 3, count.index + 2) }"
  availability_zone       = "${var.availability_zones[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${terraform.workspace}_private_elb_subnet_${format("%c", 97 + count.index)}"
    Environment = "${terraform.workspace}"
  }
  lifecycle {
    ignore_changes = "cidr_block"
  }
}

resource "aws_route_table_association" "private_elb" {
  count          = 2
  subnet_id      = "${aws_subnet.private_elb.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.*.id[count.index]}"
}

resource "aws_subnet" "db" {
  count                   = 2
  vpc_id                  = "${aws_vpc.digi.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr[terraform.workspace], 5, count.index + 16)}"
  availability_zone       = "${var.availability_zones[count.index]}"
  map_public_ip_on_launch = false
  tags {
    Name        = "${terraform.workspace}_db_subnet_${format("%c", 97 + count.index)}"
    Environment = "${terraform.workspace}"
  }

  lifecycle {
    ignore_changes = "cidr_block"
  }
}


