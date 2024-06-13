
function testConfigDriver() {
    configDriver "myserver" "example.com" "user" "22" "~/.ssh/id_rsa" "8888:80,9999:443"
}