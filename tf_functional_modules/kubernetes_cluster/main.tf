module "my_instances" {
    source = "../../tf_resources_modules/instances"
}

module "my_sg" {
    source = "../../tf_resources_modules_/security_groups"
}

module "my_networks" {
    source = "../../tf_resources_modules/networks"
}
