
easytlsDir=/usr/share/easy-rsa/pki/easytls/


function getFilePathIfExist(){
    fileName=$1
    filePath=$easytlsDir$fileName.inline
    if [ -f "$filePath" ]; then
        echo $filePath
    else
        echo ''
    fi
}

function removeFile(){
    filePath=$1
    fileName=$2
    rm $filePath
    echo "Delete $fileName"
}

function deleteEasytlsIClientnline(){
    fileName=$1
    filePath=$(getFilePathIfExist "$fileName")
    if [ ! -z "$filePath" ]; then
        correctChoice=false
        while [ "$correctChoice"=false ]
            do
            read -p "Delete $fileName? [Y/n] If not, the script stops" choice
            case $choice in
                Y|y ) removeFile $filePath $fileName; correctChoice=true ;; 
                N|n ) echo "Not delete $fileName. The script stops"; exit;;
                * ) echo "Invalid input. Enter [Y/n].";;
            esac
        done
    fi
}

getFilePathIfExist client1
