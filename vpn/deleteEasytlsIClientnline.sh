
easytlsDir=/usr/share/easy-rsa/pki/easytls/

fileName=$1.inline

function getFilePathIfExist(){
    filePath=$easytlsDir$fileName.inline
    if [ -f "$filePath" ]; then
        echo $filePath
    else
        echo ''
    fi
}

function removeFile(){
    fileName=$1
    rm $1
    echo "Delete $fileName"
}

function deleteEasytlsIClientnline(){
    filaPath=$(getFilePathIfExist)
    if [ -n "$filePath" ]; then
        correctChoice=false
        while [ "$correct"=false ]
            do
            read -p "Delete $fileName? [Y/n] If not, the script stops" choice
            case $choice in
                Y|y ) removeFile $filePath; correctChoice=true ;; 
                N|n ) echo "Not delete $fileName. The script stops"; exit;;
                * ) echo "Invalid input. Enter [Y/n].";;
            esac
        done
    fi
}


