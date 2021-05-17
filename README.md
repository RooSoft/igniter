# igniter 🔥

When you need to do a circular rebalance by sending a payment 
back to yourself using a specific route on the Bitcoin ₿ 
lightning network.

## Prerequisites

Those items are required before you attempt to use that script

* A Bitcoin lightning network LND node
* A need to rebalance
* Enough liquidity the original channel to cover the payment
* Some modifications to the script
  * A list of hops
  * An amount in satoshis
  * The initial channel's id

## What will happen

The script will create an invoice and route the payment back to
your node.

## How to use

### Edit igniter.sh

The script is currently pre-populated with a list of imaginary
lightning network pub keys you'll have to replace. They must be
replaced by the nodes you're looking forward to rebalance through.
Aliases can be added as a comment next to each of them.

Make sure that the last pub key is yours as this is where the 
funds will eventually land.

Next, update AMOUNT with the quantity of satoshis that will be
routed.

Finally, OUTGOING_CHAN_ID should contain the channel ID from
where the payment will originate. In a `ring of fire`, it should
be the channel you created yourself.

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

## Test the route

Test that all nodes are properly connected with this command

```bash
./igniter.sh build
```

### Route the payment

All that's left to do is to execute the script with this command

```bash
./igniter.sh send
```

## What can be improved

* We assume everything's going to be ok, must add some error handling
* Maybe separate the script from the parameters in different files
* lncli must be in the path
  * Umbrel users should avoid using ~umbrel/umbrel/bin/lncli as this will fail
    * As an workaround, alias `lncli='docker exec -it lnd lncli'`
