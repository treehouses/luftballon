function initAzure(){
    az group create --name luftballon --location eastus
    az vm create   --resource-group luftballon --name luftballon --image Ubuntu2204 --admin-username hiroyuki --generate-ssh-keys --public-ip-sku Standard
    echo $(az vm show --show-details --resource-group luftballon --name luftballon --query publicIps --output tsv)
    az vm run-command invoke --resource-group luftballon --name luftballon --command-id RunShellScript --scripts "sudo apt-get update && sudo apt-get install -y nginx"
    az vm open-port --port 80 --resource-group luftballon --name luftballon
}
