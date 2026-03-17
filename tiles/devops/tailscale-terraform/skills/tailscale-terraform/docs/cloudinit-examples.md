# Cloud-Init Deployment Examples

Use `terraform-cloudinit-tailscale` to deploy Tailscale on cloud VMs with automatic configuration.

## Module Source

```hcl
module "tailscale" {
  source = "github.com/tailscale/terraform-cloudinit-tailscale"
  # ... configuration
}
```

## AWS EC2

### Basic Server

```hcl
resource "tailscale_tailnet_key" "server" {
  reusable      = true
  preauthorized = true
  tags          = ["tag:server"]
}

module "server_cloudinit" {
  source         = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key       = tailscale_tailnet_key.server.key
  hostname       = "web-server"
  advertise_tags = ["tag:server"]
  enable_ssh     = true
}

resource "aws_instance" "server" {
  ami                    = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04
  instance_type          = "t3.micro"
  user_data_base64       = module.server_cloudinit.rendered
  vpc_security_group_ids = [aws_security_group.tailscale.id]

  tags = {
    Name = "tailscale-server"
  }
}

resource "aws_security_group" "tailscale" {
  name = "tailscale"

  ingress {
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Subnet Router

```hcl
resource "tailscale_tailnet_key" "router" {
  reusable      = true
  preauthorized = true
  tags          = ["tag:router"]
}

module "router_cloudinit" {
  source           = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key         = tailscale_tailnet_key.router.key
  hostname         = "subnet-router"
  advertise_routes = ["10.0.0.0/16", "192.168.1.0/24"]
  accept_routes    = true
  advertise_tags   = ["tag:router"]
}

resource "aws_instance" "router" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.small"
  user_data_base64       = module.router_cloudinit.rendered
  vpc_security_group_ids = [aws_security_group.tailscale.id]

  # Enable IP forwarding
  source_dest_check = false
}

# Enable routes after device registers
data "tailscale_device" "router" {
  name = "subnet-router"

  depends_on = [aws_instance.router]
}

resource "tailscale_device_subnet_routes" "router" {
  device_id = data.tailscale_device.router.node_id
  routes    = ["10.0.0.0/16", "192.168.1.0/24"]
}
```

### Exit Node

```hcl
resource "tailscale_tailnet_key" "exit" {
  reusable      = true
  preauthorized = true
  tags          = ["tag:exit-node"]
}

module "exit_cloudinit" {
  source              = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key            = tailscale_tailnet_key.exit.key
  hostname            = "exit-node"
  advertise_exit_node = true
  advertise_tags      = ["tag:exit-node"]
}

resource "aws_instance" "exit" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.micro"
  user_data_base64       = module.exit_cloudinit.rendered
  vpc_security_group_ids = [aws_security_group.tailscale.id]
  source_dest_check      = false
}

data "tailscale_device" "exit" {
  name = "exit-node"

  depends_on = [aws_instance.exit]
}

resource "tailscale_device_subnet_routes" "exit" {
  device_id = data.tailscale_device.exit.node_id
  routes    = ["0.0.0.0/0", "::/0"]
}
```

## DigitalOcean

```hcl
resource "tailscale_tailnet_key" "do_server" {
  reusable      = true
  preauthorized = true
}

module "do_cloudinit" {
  source          = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key        = tailscale_tailnet_key.do_server.key
  hostname        = "do-server"
  base64_encode   = false  # DigitalOcean uses plain user_data
}

resource "digitalocean_droplet" "server" {
  image     = "ubuntu-22-04-x64"
  name      = "tailscale-server"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  user_data = module.do_cloudinit.rendered
}
```

## Google Cloud (GCP)

```hcl
resource "tailscale_tailnet_key" "gcp_server" {
  reusable      = true
  preauthorized = true
}

module "gcp_cloudinit" {
  source    = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key  = tailscale_tailnet_key.gcp_server.key
  hostname  = "gcp-server"
}

resource "google_compute_instance" "server" {
  name         = "tailscale-server"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    user-data = module.gcp_cloudinit.rendered
  }
}
```

## Azure

```hcl
resource "tailscale_tailnet_key" "azure_server" {
  reusable      = true
  preauthorized = true
}

module "azure_cloudinit" {
  source    = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key  = tailscale_tailnet_key.azure_server.key
  hostname  = "azure-server"
}

resource "azurerm_linux_virtual_machine" "server" {
  name                = "tailscale-server"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.main.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(module.azure_cloudinit.rendered)
}
```

## Secret Injection

### From File

```hcl
module "cloudinit" {
  source   = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key = "file:/path/to/auth-key"
}
```

### From Command

```hcl
module "cloudinit" {
  source   = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key = "command:aws ssm get-parameter --name /tailscale/auth-key --query Parameter.Value --output text"
}
```

### From Vault

```hcl
module "cloudinit" {
  source   = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key = "command:vault kv get -field=auth-key secret/tailscale"
}
```

## Workload Identity (OIDC)

For cloud-native authentication without auth keys:

### AWS IAM Identity Center

```hcl
module "cloudinit" {
  source        = "github.com/tailscale/terraform-cloudinit-tailscale"
  client_id     = aws_iam_openid_connect_provider.tailscale.arn
  id_token      = "command:/opt/fetch-id-token"
  audience      = "https://tailscale.com"
}
```

## Custom Configuration

### Additional Cloud-Init Parts

```hcl
module "cloudinit" {
  source    = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key  = tailscale_tailnet_key.server.key

  additional_parts = [
    {
      filename     = "install-docker.sh"
      content_type = "text/x-shellscript"
      content      = <<-EOF
        #!/bin/bash
        curl -fsSL https://get.docker.com | sh
        usermod -aG docker ubuntu
      EOF
    }
  ]
}
```

### Custom Tailscaled Flags

```hcl
module "cloudinit" {
  source                       = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key                     = tailscale_tailnet_key.server.key
  tailscaled_flag_state        = "mem:"  # Ephemeral node
  tailscaled_flag_verbose      = 1
  tailscaled_flag_port         = 41641
  tailscaled_flag_outbound_http_proxy_listen = "localhost:8080"
  tailscaled_flag_socks5_server = "localhost:1080"
}
```

## Module Outputs

```hcl
output "cloudinit_rendered" {
  value = module.cloudinit.rendered
}
```

Use the `rendered` output as:
- `user_data_base64` for AWS
- `user_data` for DigitalOcean, GCP, Azure
- `custom_data` for Azure (base64 encoded)

## Security Groups / Firewalls

Required ports for Tailscale:

| Port | Protocol | Purpose |
|------|----------|---------|
| 41641 | UDP | WireGuard/Tailscale traffic |
| 41641 | TCP | DERP relay (fallback) |

```hcl
# AWS
resource "aws_security_group_rule" "tailscale_udp" {
  type              = "ingress"
  from_port         = 41641
  to_port           = 41641
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}

# GCP
resource "google_compute_firewall" "tailscale" {
  name    = "tailscale"
  network = "default"

  allow {
    protocol = "udp"
    ports    = ["41641"]
  }

  source_ranges = ["0.0.0.0/0"]
}
```