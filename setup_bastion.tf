    resource "null_resource" "setup_bastion" {

    connection {
        type     = "ssh"
        user     = "root"
        host = "${var.bastion_ip_address}"
        private_key = "${file(var.bastion_private_ssh_key)}"
    }

    provisioner "file" {
        source      = "${path.module}/scripts"
        destination = "/tmp"
    }


    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/scripts/*",
            "/tmp/scripts/rhn_register.sh ${var.rhn_username} ${var.rhn_password} ${var.rhn_poolid}",
            "/tmp/scripts/bastion_install_ansible.sh",
        ]
    }

    provisioner "remote-exec" {
        when = "destroy"
        inline = [
            "subscription-manager unregister",
        ]
    }
}
