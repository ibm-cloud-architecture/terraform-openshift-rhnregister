resource "null_resource" "setup_storage" {
    count = "${var.storage["nodes"]}"
    connection {
        type     = "ssh"
        user     = "${var.ssh_username}"
        host = "${element(var.storage_ip_address, count.index)}"
        private_key = "${file(var.storage_private_ssh_key)}"
        bastion_host = "${var.bastion_ip_address}"
        bastion_host_key = "${file(var.bastion_private_ssh_key)}"
    }

    provisioner "file" {
        when = "create"
        source      = "${path.module}/scripts"
        destination = "/tmp"
    }

    provisioner "remote-exec" {
        when = "create"
        inline = [
            "sudo chmod +x /tmp/scripts/*",
            "sudo /tmp/scripts/rhn_register.sh ${var.rhn_username} ${var.rhn_password} ${var.rhn_poolid}",
        ]
    }

    provisioner "remote-exec" {
        when = "destroy"
        inline = [
            "sudo subscription-manager unregister",
        ]
    }

        depends_on = [
            "null_resource.dependency"
        ]
}
