# igniter 🔥

When you need to do a circular rebalance by sending a payment
back to yourself using a specific route on the Bitcoin ₿
lightning network.

Igniter is being distributed by
[Lightning Shell](https://lightningshell.app)
and can thus be installed from
[Umbrel](https://getumbrel.com)'s app store.

This document will explain how to use it directly from this repo.

## Dependencies

* A Bitcoin lightning network LND node
* [jq](https://stedolan.github.io/jq/)

## What will happen

The script will create an invoice and route the payment back to
your node.

## How to use

### Edit igniter.conf

The sample config file is pre-populated with a list of imaginary
lightning network pub keys. They must be replaced by the nodes
you're looking forward to rebalance through. Aliases can be added
as a comment next to each of them to make it more readable.

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

* lncli must be in the path
  * Umbrel users should avoid using ~umbrel/umbrel/bin/lncli as this will fail
    * As an workaround, alias `lncli='docker exec -it lnd lncli'`
