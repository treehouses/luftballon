function login(){

    username=$(retrieveCred username)
    password=$(retrieveCred password)
    tenant=$(retrieveCred tenant_name)

    az login --service-principal --username $username --password $password --tenant $tenant
}