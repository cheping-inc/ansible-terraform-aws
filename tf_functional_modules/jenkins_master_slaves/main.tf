module "instances" {
    source = "../../tf_resources_modules/instances"

    region_master = var.region_master
    region_worker = var.region_worker
    workers_count = var.workers_count
    masters_count = var.masters_count
    instance_type = var.instance_type
    external_ip   = var.external_ip
    webserver_port = var.webserver_port
    subnet_master_1_id = module.networks.subnet_master_1_id
    subnet_worker_id = module.networks.subnet_worker_id
    set_master_default_rt_assoc = module.networks.set_master_default_rt_assoc
    set_worker_default_rt_assoc = module.networks.set_worker_default_rt_assoc
    jenkins_sg_master_id = module.security_groups.jenkins_sg_master_id
    jenkins_sg_worker_id = module.security_groups.jenkins_sg_worker_id
    
    #depends_on = [module.networks.set_master_default_rt_assoc]
}

module "load_balancers" {
    source = "../../tf_resources_modules/load_balancers"

    region_master = var.region_master
    region_worker = var.region_worker
    webserver_port = var.webserver_port
    external_ip = var.external_ip
    jenkins_master_id = module.instances.jenkins_master_id
    lb_sg_id= module.security_groups.lb_sg_id
    subnet_master_1_id= module.networks.subnet_master_1_id
    subnet_master_2_id= module.networks.subnet_master_2_id
    vpc_master_id=module.networks.vpc_master_id
}

module "networks" {
    source = "../../tf_resources_modules/networks"

    region_master = var.region_master
    region_worker = var.region_worker
}

module "security_groups" {
    source = "../../tf_resources_modules/security_groups"

    region_master = var.region_master
    region_worker = var.region_worker
    external_ip = var.external_ip
    vpc_master_id = module.networks.vpc_master_id
    vpc_worker_id = module.networks.vpc_worker_id
}

