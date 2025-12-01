aws_region       = "ap-south-1"
project_name     = "terraform-app"
environment      = "dev"
vpc_cidr         = "10.0.0.0/16"
instance_type    = "t3.micro"
ssh_allowed_cidr = ["10.0.0.0/8"]

# Vault configuration (update with your Vault details)
vault_addr            = "http://localhost:8200"
vault_token           = "your-vault-token"
vault_skip_tls_verify = true

# Monitoring
enable_monitoring  = true
log_retention_days = 7

# SSH Public Key
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6gWQpqCl23i1H6pp9YYkKU1J1l9XEgANqwmGsh3uYbCbnbTuYPXuxRWHIKu/hbv+gavfizcRoEgpR37HUz87sVOKm5JKDhmfv0khjcSuy8RFK0yEt4J0mgnYJo26m+tH9BEsMJXQI5uoj3CPpWZa5uQ/qsHaYdAcV0qpi3MBgbtvvsvuTEMmLt6aGbqlQD/Rf74ebNnNbMgfmZYxrReSb3Jzqg9a+m5YqrM+BmAeJj2VO6LCmJiuNNDPWGDPw5CMDJYMWxrpFRqbq8c3hl8gn7YiV6IbrjKZvHVfMIwfgy2COIyoEv0kEcPq916KoSuH81htprGKlYJx7VR7aQ2PMvFCb896O2a9G6NNxzefZpjvG14SXQK+mrSogeilq/AiDRbMoHEPIUzvKt35ywMvoGpTQQwTPtA4uNz2hGyZlmBXVD9L/gCDkg5kPO4UvEuVRXNSv86tR06G/nofxH3M/xEzK9Eh/e55dS9l7ruE9KPZ4fT65a1i21ohkwczN0215wH4Dr8EsnNQdrdWx8IskZaJhguF0xptrw3gpTn+FlH+Ui6hsm8z8+L17N79nG4Eyi4FVkURHPSZL0IPD3wwsNFdmftBzbe6/qX00SWC1h72AMknuJv6QRjQOOv6nRnY1El7s5dIoFx6zJbsbgToOVAvbPWaO5JRTIPAvbfkXBw== 123@Bhagirath"
