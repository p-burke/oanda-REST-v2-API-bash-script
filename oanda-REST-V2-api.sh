#!/bin/bash
## config
API_TOKEN="nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn-mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm" # TODO: Change for your account Token
ACCOUNT_ID="xxx-xxx-xxxxxxx-xxx"                                                # TODO: Change for your account id

## non-config
CURL="curl --silent --show-error"
AUTHORIZATION_HEADER="Authorization:Bearer ${API_TOKEN}"
API_ENVIRONMENT_URL="https://api-fxpractice.oanda.com"							

# Functions
help()
{
	echo Available Commands
	echo
	echo ""
	echo " accounts                                    - get a list of accounts for the username"
	echo " trades                                      - get a list of trades"
	echo " marketOrder new <instrument> [+/-]<units>   - create a new market order"
	echo " trade get <trade_id>                        - show trade information"
	echo " rate <instrument>                           - show the current rate for the provided instrument"
	echo ""
	echo " quit                                        - quit the program"
}

jecho ()
{
	echo "$1" | sed -e 's/},{/},\n{/g' -e 's/\[{/\[\n{/g' -e 's/}\]/}\n\]/g' -e 's/\],/\],\n/g'
}

accounts()
{
	ACCOUNTS=$(${CURL} "${API_ENVIRONMENT_URL}/v3/accounts/${ACCOUNT_ID}" -H "${AUTHORIZATION_HEADER}" -H "Content-Type:application/json")
	jecho "Accounts: ${ACCOUNTS}"
}

trades()
{
	TRADES=$(${CURL} "${API_ENVIRONMENT_URL}/v3/accounts/${ACCOUNT_ID}/trades" -H "${AUTHORIZATION_HEADER}" -H "Content-Type:application/json")
	jecho "Accounts: ${TRADES}"
}

# From the API Manual: 
# "units (integer (required)) – the number of units. 
# If positive the order results in a LONG order. 
# If negative the order results in a SHORT order"
marketOrder_new()
{
	set -x
	INSTRUMENT=$1
	UNITS=$2
	if [ "${INSTRUMENT}" = "" -o "${UNITS}" = "" ]; then
	  echo "Usage:"
	  echo "  marketOrder new <instrument> [+/-]<units>"
	  echo ""
	  echo "e.g.:"
	  echo "  marketOrder new EUR_USD 2"
	  echo "  marketOrder new GBP_USD -3"
		else
		# Form the HTTP Request Body structured as JSON
body=$(cat << EOF
	{
		  "order": {
		    "units": "$UNITS", 
		    "instrument": "$INSTRUMENT", 
		    "timeInForce": "FOK", 
		    "type": "MARKET", 
		    "positionFill": "DEFAULT"
		  }
		}
EOF
)			
	  TRADE_REQ="${API_ENVIRONMENT_URL}/v3/accounts/${ACCOUNT_ID}/orders"
	  TRADE_RESP=$(${CURL} -X POST -d "$body" "${TRADE_REQ}" -H "${AUTHORIZATION_HEADER}" -H "Content-Type:application/json")
	  jecho "Response: ${TRADE_RESP}"
	fi
}

trade_get()
{
	TRADE_ID=$1
	if [ "${TRADE_ID}" = "" ]; then
	  echo "Usage:"
	  echo "  trade get <trade_id>"
	else
	  TRADE_REQ="${API_ENVIRONMENT_URL}/v3/accounts/${ACCOUNT_ID}/trades/${TRADE_ID}"
	  TRADE_RESP=$(${CURL} ${TRADE_REQ} -H "${AUTHORIZATION_HEADER}" -H "Content-Type:application/json")
	  jecho "Response: ${TRADE_RESP}"
	fi
}

trade()
{
	if [ "$1" = "get" ]; then
	  shift
	  trade_get $*
	else
	  echo "  get - get details of an existing trade"
	fi
}

marketOrder()
{
	if [ "$1" = "new" ]; then
	  shift
	  marketOrder_new $*
	else
	  echo "  new - create a new marketOrder"
	fi
}

rate()
{
	INSTRUMENT="$1"
	if [ "${INSTRUMENT}" = "" ]; then
	  echo "Usage: rate <instrument>"
	  echo ""
	  echo "eg. rate EUR_USD"
	else
	  CONVERTED_INSTRUMENT=$(echo "${INSTRUMENT}" | sed -e 's%/%_%')
	  RATE_REQ="${API_ENVIRONMENT_URL}/v3/accounts/${ACCOUNT_ID}/pricing?instruments=${CONVERTED_INSTRUMENT}"
	  RATE_RESP=$(${CURL} ${RATE_REQ} -H "${AUTHORIZATION_HEADER}" -H "Content-Type:application/json")
	  jecho "Rate: ${RATE_RESP}"
	fi
}
# End of Functions

if [ "$1" != "" ]; then
  COMMAND=$*
fi

if [ "$1" = "--help" ]; then
  echo "Usage:"
  echo "  $0 [command] [args]"
  echo ""
  help
  exit 0
fi

if [ "$COMMAND" != "" ]; then
  echo $COMMAND
  $COMMAND
else
  help
  while [ "$COMMAND" != "quit" ]; do
    read -ep "${LOGGED_IN_USER}:${ACCOUNT}> " COMMAND
    history -s "$COMMAND"
    if [ "$COMMAND" = "?" ]; then
      COMMAND=help
    fi
    if [ "$COMMAND" != "quit" ]; then
      $COMMAND
    fi
  done
fi
exit
