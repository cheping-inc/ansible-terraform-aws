output "subnet_master_1_id" {
    value = aws_subnet.subnet_master_1.id
}

output "subnet_master_2_id" {
    value = aws_subnet.subnet_master_2.id
}

output "subnet_worker_id" {
    value = aws_subnet.subnet_worker.id
}

output "vpc_master_id" {
    value = aws_vpc.vpc_master.id
}

output "vpc_worker_id" {
    value = aws_vpc.vpc_worker.id
}

output "set_master_default_rt_assoc" {
    value = {}
    
    depends_on = [aws_main_route_table_association.set_master_default_rt_assoc]
}

output "set_worker_default_rt_assoc" {
    value = {}
    
    depends_on = [aws_main_route_table_association.set_worker_default_rt_assoc]
}
