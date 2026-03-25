resource "azurerm_network_security_group" "nsg" {
  name                = "healthcare-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "ssh_rule" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "k8s_ports" {
  name                        = "AllowK8sNodePorts"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["31000", "32000"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "alb_ip" {
  name                = "healthcare-alb-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "alb" {
  name                = "healthcare-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.alb_ip.id
  }
}

resource "azurerm_network_security_rule" "allow_lb_inbound" {
  name                        = "AllowAzureLoadBalancer"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["31000", "32000"]
  source_address_prefix       = "AzureLoadBalancer" # Special Azure tag
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# 3. Backend Address Pool
resource "azurerm_lb_backend_address_pool" "bap" {
  loadbalancer_id = azurerm_lb.alb.id
  name            = "HealthcareBackendPool"
}

# 4. Associate VM Network Interface with Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "assoc" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bap.id
}

# 5. Health Probe (Crucial: ALB only sends traffic if this returns 200/OK)
resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.alb.id
  name            = "http-running-probe"
  port            = 32000 # Probes the K8s Frontend NodePort
  protocol        = "Tcp"
}

# 6. Inbound Load Balancing Rule (Port 80 -> 32000)
resource "azurerm_lb_rule" "frontend_rule" {
  loadbalancer_id                = azurerm_lb.alb.id
  name                           = "LBRule-Frontend"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 32000
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bap.id]
}

# 7. Inbound Rule for Backend API (Port 31000 -> 31000)
resource "azurerm_lb_rule" "backend_rule" {
  loadbalancer_id                = azurerm_lb.alb.id
  name                           = "LBRule-Backend"
  protocol                       = "Tcp"
  frontend_port                  = 31000
  backend_port                   = 31000
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bap.id]
}