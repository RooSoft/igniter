# igniter 🔥

When you need to send a payment back to yourself using a 
specific route on the Bitcoin ₿ lightning network, essentially
doing a rebalance operation.

## Prerequisites

Those items are required before you attempt to use that script

* A Bitcoin lightning network LND node
* A need to send sats using a specific route
* Enough liquidity in the said channel to cover the payment
* Some modiications to the script to include a list of hops, an amount in
satoshis as well as the initial channel's id.

## What will happen

The script will create an invoice and route the payment back to
your node.

## How to use

### Edit igniter.sh

The script is currently pre-populated with a list of imaginary
lightning network pub keys you'll have to replace. Aliases
can be added as a comment next to each of them. They need to be
replaced by an arbitrary number of pub keys related to nodes
you're willing to route through.

Make sure that the last pub key is the one from your own node
as this is where the funds will eventually land.

Next, update AMOUNT with the quantity of satoshis that will be
routed.

Finally, OUTGOING_CHAN_ID should contain the channel ID from
where the payment will originate. This is one of the sender's
node channels. In a `ring of fire`, it should be the channel
you created. 

For peeps having a hard time finding the channel id:

* go to https://1ml.com
* find your node
* go to the channels tab
* find the channel you created
* the number will be in the table header

### First things first

Make sure the script is executable

```bash
chmod +x igniter.sh
```

### Route the payment

All that's left to do is to execute the script with this command

```bash
./igniter.sh
```

## What can be improved

* We assume everything's going to be ok, must add some error handling
* lncli must be in the path
  * Umbrel users should avoid using ~umbrel/umbrel/bin/lncli as this will fail
    * As an workaround, alias `lncli='docker exec -it lnd lncli'`
