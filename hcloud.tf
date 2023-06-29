resource "local_sensitive_file" "foo" {
  content  = <<-EOT
  dns_cloudflare_api_token = ${var.cf_api_token}
  EOT
  filename = "/home/noe/cloudflaresecrets"
}

resource "hcloud_server" "server" {
  count      = var.server_count
  name       = "server-${count.index + 1}"
  server_type = "cx11"
  location   = var.resource_location
  image      = "ubuntu-20.04"
  ssh_keys   = [hcloud_ssh_key.default.id]

firewall_ids = [ hcloud_firewall.firewall.id    
]     
provisioner "local-exec" {

  command = "sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /home/noe/cloudflaresecrets -d *.nikio.io --agree-tos -m noetizian.broennimann@baloise.ch --force-renewal || exit 0"

}


  provisioner "file" {
    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "root"
      private_key = file(var.ssh_private_key)
    }
    source      = "/home/noe/certs/fullchain.pem"
    destination = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
    
  }
 provisioner "file" {
    source      = "/home/noe/certs/privkey.pem"
    destination = "/etc/ssl/private/ssl-cert-snakeoil.key"
 
    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "root"
      private_key = file(var.ssh_private_key)
    }
 
 
  }



  provisioner "remote-exec" {
    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "root"
      private_key = file(var.ssh_private_key)
    }
    inline = [
      "sudo apt-get update",
      "sudo apt-get install apache2 -y "
      ,"sudo cp /etc/apache2/sites-available/default-ssl.conf  /etc/apache2/sites-enabled/default-ssl.conf",
      "sudo a2enmod ssl",
      "sudo systemctl restart apache2"
    ]

  }



}

  resource "cloudflare_record" "DNS" {
  count = var.server_count
  type = "A"
  zone_id = var.cf_zone_id
  name = "${var.subdomain_name_cloudserver}${count.index}.${var.domain_name}"
  value = hcloud_server.server[count.index].ipv4_address
  ttl = 60 
}


resource "hcloud_load_balancer_service" "service" {
  load_balancer_id     = hcloud_load_balancer.lb-1.id
  listen_port          = 80
  destination_port     = 80
  protocol = "tcp"
}

resource "hcloud_load_balancer" "lb-1" {
  name               = "lb-1"
  load_balancer_type = "lb11"
  location           = var.resource_location
  dynamic "target" {
    for_each = hcloud_server.server
    content {
      type      = "server"
      server_id = target.value.id
    }
  }
}

resource "cloudflare_record" "lb" {
  type = "A"
  zone_id = var.cf_zone_id
  name = "${var.subdomain_name_load_balancer}.${var.domain_name}"
  value = hcloud_load_balancer.lb-1.ipv4
  ttl = 60 
}


resource "hcloud_ssh_key" "default" {
  name       = "tf-ssh-key"
  public_key = file(var.ssh_public_key)
}


resource "hcloud_firewall" "firewall" {
  name = "fw"
 
   rule {
    direction  = "in"
    protocol   = "tcp"
    port = "22"
    source_ips = ["0.0.0.0/0"]
  }

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0"]
  }
      rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = ["0.0.0.0/0"]
  }
    rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = ["0.0.0.0/0"]
  }


}

