#!/bin/bash

# before running this script, the array below must be populated with
# all nodes pub keys that will be part of the route

declare pub_keys=(
    3a96005aeae5dd52b5bec13002f758530fc73047ddbfc3b5fd85e3976afd708df7 # first hop pub key (not yours)
    6a77ba85ffaab0e01a7d8357f73e6f9ac6e1cecc68639093c7a0bc5628a8223fc3 # next hop's pub key
    1b2a70017bb25e4d1fbc2cac80bf42af49e1259b94b4961be466c706fa939e99dc # next hop's pub key
    c4dfe87dfa148bb3e7b271cc481a46e92aa8f11311c6156255637671586f2af97a # next hop's pub key
    239ef4b4fd1ed494daca563fc51d309b7a2686142eec2db0ee917dde3c89d71577 # next hop's pub key
    61a622bf73ce3b8c19a798431ea05450ae99ddbb496a986f2ef35c67c1edb20165 # next hop's pub key
    e86f6e4beb29fada99497f1db754d4497bf3ed3ffcd850696a2173c6cd49f28eb3 # next hop's pub key
    40625736d487d4a5607a9107d9ce7bd7841c9f205513dde998b8d56009aada0a29 # your node's pub key
)

AMOUNT=10                            # value in satoshis to transmit
OUTGOING_CHAN_ID=749457911902765057  # initial channel to transmit from

####################################################
## the remaining of this script can remain untouched

IFS=, eval 'HOPS="${pub_keys[*]}"'

INVOICE=$(lncli addinvoice --amt=${AMOUNT} --memo="Rebalancing...")

PAYMENT_HASH=$(echo -n $INVOICE | jq -r .r_hash)
PAYMENT_ADDRESS=$(echo -n $INVOICE | jq -r .payment_addr)

lncli buildroute --amt ${AMOUNT} --hops ${HOPS} --outgoing_chan_id ${OUTGOING_CHAN_ID} \
  | jq -c "(.route.hops[-1] | .mpp_record) |= {payment_addr:\"${PAYMENT_ADDRESS}\", total_amt_msat: \"${AMOUNT}000\"}" \
  | lncli sendtoroute --payment_hash=${PAYMENT_HASH} -