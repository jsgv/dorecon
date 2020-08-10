function banner () {
    cat <<'EOF'
    ____           ____                      
   / __ \____     / __ \___  _________  ____ 
  / / / / __ \   / /_/ / _ \/ ___/ __ \/ __ \
 / /_/ / /_/ /  / _, _/  __/ /__/ /_/ / / / /
/_____/\____/  /_/ |_|\___/\___/\____/_/ /_/ 
                    made with <3 by @jesgvn
EOF
}

banner;

REGION=${REGION:-sfo2}
SIZE=${SIZE:-s-1vcpu-2gb}

DOMAINS=""

for d in "$@"
do
    DOMAINS+="\"$d\" ";
done

# remove trailing space after last domain
DOMAINS=`echo $DOMAINS | sed -e "s/ $//"`

# replace domain placeholder
USER_DATA=$(sed -e "s/DOMAINSPLACEHOLDER/$DOMAINS/" vps-init.sh);

doctl compute droplet create \
    --image ubuntu-18-04-x64 \
    --size $SIZE \
    --region $REGION \
    --user-data "$USER_DATA" \
    --wait \
    "recon"; 

