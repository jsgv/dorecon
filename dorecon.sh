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

SSH_KEYS=${SSH_KEYS:-0}
REGION=${REGION:-sfo2}
SIZE=${SIZE:-s-1vcpu-2gb}

# replace domain placeholder
USER_DATA=$(sed -e "s/example.com/$1/" vps-init.sh);

doctl compute droplet create \
    --image ubuntu-18-04-x64 \
    --size $SIZE \
    --region $REGION \
    --ssh-keys $SSH_KEYS \
    --user-data "$USER_DATA" \
    "recon-$1"; 

