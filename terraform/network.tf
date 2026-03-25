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

resource "azurerm_lb_backend_address_pool" "bap" {
  loadbalancer_id = azurerm_lb.alb.id
  name            = "HealthcarePool"
}

resource "azurerm_network_interface_backend_address_pool_association" "assoc" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bap.id
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.alb.id
  name            = "http-probe"
  port            = 32000
}

resource "azurerm_lb_rule" "rule" {
  loadbalancer_id                = azurerm_lb.alb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 32000
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bap.id]
}

resource "azurerm_lb_rule" "backend_rule" {
  loadbalancer_id                = azurerm_lb.alb.id
  name                           = "BackendRule"
  protocol                       = "Tcp"
  frontend_port                  = 31000
  backend_port                   = 31000
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bap.id]
}