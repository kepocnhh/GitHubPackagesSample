echo "telegram send message start..."

EXPECTED_ARGUMENTS_COUNT=1
if test $# -ne $EXPECTED_ARGUMENTS_COUNT; then
 echo "Script needs for $EXPECTED_ARGUMENTS_COUNT arguments but actual $#"
 exit 11
fi

TELEGRAM_BOT_ID=${telegram_bot_id:?"Variable \"telegram_bot_id\" is not set"}
TELEGRAM_BOT_TOKEN=${telegram_bot_token:?"Variable \"telegram_bot_token\" is not set"}
TELEGRAM_CHAT_ID=${telegram_chat_id:?"Variable \"telegram_chat_id\" is not set"}
MESSAGE=$1

url="https://api.telegram.org/bot$TELEGRAM_BOT_ID:$TELEGRAM_BOT_TOKEN/sendMessage"

MESSAGE=${MESSAGE//"#"/"%23"}
MESSAGE=${MESSAGE//$'\n'/"%0A"}
MESSAGE=${MESSAGE//$'\r'/""}

CODE=$(curl -s -w %{http_code} -o /dev/null $url \
 -d chat_id=$TELEGRAM_CHAT_ID \
 -d text="$MESSAGE" \
 -d parse_mode=markdown)

if test $CODE -ne 200; then
 echo "Request error with response code $CODE!"
 exit 21
fi

echo "telegram send message success"

exit 0
