#!/bin/bash
if [ $1 -eq 0 ]; then
    echo "No value provided For image name. EX: \"./script.sh nginx:latest\"  Exiting.."
    exit 1
fi

if [ $2 -eq 0 ]; then
    echo "No value provided For command . EX: \"./script.sh nginx:latest some_command\". Continueing without command. It will use Dockerfile default"
fi

$IMAGE_NAME=$1
$COMMAND=$2

echo "Getting all Secrets Name from GCP secret manager"
gcloud secrets list > all_secrets.txt


DEST="docker run "

while read -r line; do
    first_field=$(echo "$line" | cut -d ' ' -f 1)
    echo "Pulling Secret for $first_field"
    secret_value="$(gcloud secrets versions access latest --secret $first_field)"
    if [ "$first_field" = "DATABASE_URL" ]
    then
            continue
    fi

    if [ -z "$secret_value" ]
            then
                    echo "The value of \"$first_field\" is null so ignoring."
                    continue
    fi


    if [ "$first_field" = "DATABASE_URL_VM" ]
    then
            DEST="$DEST -e \"DATABASE_URL=$secret_value\" "
    else
             DEST="$DEST -e \"${first_field}=$secret_value\" "
    fi
done < ./all_secrets.txt

DEST="$DEST $IMAGE_NAME $COMMAND"

echo $DEST > docker.sh

echo "Starting container with all secrets..."
sh -c "$DEST"
echo "Continer is running"