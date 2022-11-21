#!/bin/bash

source igniter.conf

if [ -z "$pub_keys" ] || [ -z "$AMOUNT" ] || [ -z "$OUTGOING_CHAN_ID" ] || [ -z "$MAX_FEE" ]; then
	echo "Please set all required parameters (pub_keys, AMOUNT, OUTGOING_CHAN_ID and MAX_FEE) in igniter.conf."
	exit 1
fi

if [ ${pub_keys[0]} == "_EDIT_ME_" ]; then
	echo "Please edit igniter.conf and set your own route"
	exit 1
fi

# Join pub keys into single string at $HOPS
IFS=, eval 'HOPS="${pub_keys[*]}"'

# If an umbrel, use docker, else call lncli directly. Also setup dependencies accordingly.
LNCLI="lncli"
if [ -d "$HOME/umbrel" ] ; then
    # Umbrel < 0.5.x
    if docker ps -q  -f name=^lnd$ | grep -q . ; then
      LNCLI="docker exec -i lnd lncli"
    # Umbrel >= 0.5.x
    else
      LNCLI="$HOME/umbrel/scripts/app compose lightning exec lnd lncli"
    fi
    dependencies="cat jq"
else
    dependencies="cat jq lncli"
fi

# Arg option: 'build'
build () {
    $LNCLI buildroute --amt ${AMOUNT} --hops ${HOPS} --outgoing_chan_id ${OUTGOING_CHAN_ID}
}

# Arg option: 'connect'
connect () {
    IFS=,
    PEERS=$($LNCLI listpeers | grep pub_key  | tr '"' ' ' | awk '{print $3}')
    SELF=$($LNCLI getinfo | grep pubkey | tr '"' ' ' | head -n 1 | awk '{print $3}')
    for KEY in $HOPS
    do
	if [[ "$PEERS" =~ "$KEY" ]]; then
		echo "Already connected to: $KEY "
	else
	    if [ "$SELF" != "$KEY"  ] ; then
	        ADDRESS=$($LNCLI getnodeinfo $KEY | grep \"addr\" |head -n 1| awk '{print $2}' |sed 's/"//g' )
	        echo "Connecting to: $KEY@$ADDRESS"
	        lncli connect $KEY@$ADDRESS
	    fi
	fi
    done
}

# Arg option: 'send'
send () {
  INVOICE=$($LNCLI addinvoice --amt=${AMOUNT} --memo="Rebalancing...")

  PAYMENT_HASH=$(echo -n $INVOICE | jq -r .r_hash)
  PAYMENT_ADDRESS=$(echo -n $INVOICE | jq -r .payment_addr)
  
  ROUTE=$(build)
  FEE=$(echo -n $ROUTE | jq .route.total_fees_msat)
  # The fee is expressed as a quoted string in msat. A string length of less than 6 indicates a 0 sat fee.
  FEE=$([ ${#FEE} -lt 6 ] && echo "0" || echo ${FEE:1:-4})
  
  echo "Route fee is $FEE sats."

  if (( FEE  > MAX_FEE )); then
    echo "Error: $FEE exceeded max fee of $MAX_FEE"
    exit 1
  fi

  echo $ROUTE \
    | jq -c "(.route.hops[-1] | .mpp_record) |= {payment_addr:\"${PAYMENT_ADDRESS}\", total_amt_msat: \"${AMOUNT}000\"}" \
    | $LNCLI sendtoroute --payment_hash=${PAYMENT_HASH} -
}

# test for availability of tools before use, don't rely on users
# not used to cli dealing with errors down the line
assert_tools () {
  err=0
    while test $# -gt 0; do
      command -v "$1" >/dev/null 2>/dev/null || {
        >&2 printf "tool missing: $1\n"
        err=$(( $err + 1 ))
      }
      shift
    done
    test $err -eq 0 || exit $err
}

# Arg option: '--help'
help () {
    cat << EOF
usage: ./igniter.sh [--help] [build] [connect] [send]
       <command> [<args>]

Open the script and configure values first. Then run
the script with one of the following flags:

   build             Build the routes for the configured node
   connect           Connect to every peer with lncli
   send              Build route and send payment along route

EOF
}


# Run the script
assert_tools ${dependencies}
all_args=("$@")
rest_args_array=("${all_args[@]:1}")
rest_args="${rest_args_array[@]}"

case $1 in
    "build" )
        build $rest_args
        ;;
    "connect" )
	connect $rest_args
	;;
    "send" )
        send $rest_args
        ;;
    "--help" )
        help
        ;;
    * )
        help
        ;;
esac
