output vcn {
  value = "${var.director_vcn}"
}
output subnet_id {
  value = "${oci_core_subnet.director_subnet.id}"

}
output compartment_id {
   value = "${oci_core_subnet.director_subnet.compartment_id}"
}

output ad {
  value = "${oci_core_subnet.director_subnet.availability_domain}"
}

output subnet_name {
  value = "${oci_core_subnet.director_subnet.display_name}"
}
output subnet_cidr {
  value = "${oci_core_subnet.director_subnet.cidr_block}"
}

output subnet_gw {
  value = "${cidrhost(oci_core_subnet.director_subnet.cidr_block, 1)}"
}

output subnet_first_ip {
   value = "${cidrhost(oci_core_subnet.director_subnet.cidr_block, 2)}"
}