#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   18/11/20 17:06

# Exit on non-zero return status
set -e

KEYFILE="$HOME"'/.ssh/aws-key.pem'

if [ "$#" != '1' ]; then
	echo 'Usage: aws-ssh <hostname>'
	exit 1
fi

host="$1"

t="$(mktemp)"

echo 'Enter the ~/.aws/credentials file'
echo 'Finish with control D'

cat - > "$t"

clear

echo 'ssh ...'

(
	ssh -i "$KEYFILE" 'ubuntu@'"$host" 'mkdir -p .aws'
	sleep 1
	scp -i "$KEYFILE" "$t" 'ubuntu@'"$host"':.aws/credentials'
	sleep 1
)

(
	ssh -i "$KEYFILE" 'ubuntu@'"$host" 'mkdir -p .ssh'
	sleep 1
	scp -i "$KEYFILE" "$KEYFILE" 'ubuntu@'"$host"':.ssh/aws-key.pem'
	sleep 1
	ssh -i "$KEYFILE" 'ubuntu@'"$host" 'chmod 600 .ssh/aws-key.pem'
	sleep 1
)

rsync -rave "ssh -i $KEYFILE" src/* "ubuntu"@"$host":'~' &
rsync -rave "ssh -i $KEYFILE" *.sh "ubuntu"@"$host":'~' &

wait

###
AWS_KEYFILE='/home/ubuntu/.ssh/aws-key.pem'

aws_access_key_id="$(awk -F'=' '/^aws_access_key_id=/ {print $2}' < "$t")"
aws_secret_access_key="$(awk -F'=' '/^aws_secret_access_key=/ {print $2}' < "$t")"
aws_session_token="$(awk -F'=' '/^aws_session_token=/ {print $2}' < "$t")"

echo Running setup.sh ...
ssh -i "$KEYFILE" 'ubuntu@'"$host" ./minimoto_setup.sh "$AWS_KEYFILE" "$aws_access_key_id" "$aws_secret_access_key" "$aws_session_token"
###

rm -f "$t"

exec ssh -i "$KEYFILE" 'ubuntu@'"$host"




