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

INIT_SCRIPT=$(cat vps-init.sh);

# remove trailing space after last domain
DOMAINS=`echo $DOMAINS | sed -e "s/ $//"`

# replace domain placeholder
INIT_SCRIPT=$(echo "$INIT_SCRIPT" | sed -e "s/DOMAINSPLACEHOLDER/$DOMAINS/");

# if Telegram variables are defined, add the API call to the end of the script
if [[ $TELEGRAM_BOT_ID && $TELEGRAM_CHAT_ID ]]
then
    INIT_SCRIPT+="
curl -s -o /dev/null 'https://api.telegram.org/bot$TELEGRAM_BOT_ID/sendMessage?text=Recon+complete&chat_id=$TELEGRAM_CHAT_ID';"
fi

doctl compute droplet create \
    --image ubuntu-18-04-x64 \
    --size $SIZE \
    --region $REGION \
    --user-data "$INIT_SCRIPT" \
    --wait \
    "recon"; 

