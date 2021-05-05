# igniter 🔥

When you need to send a payment using a specific route.

Modify this script to include a list of hops, an amount in
satoshis as well as the initial channel's id.

## How to use

### Edit igniter.sh

The script is currently pre-populated with a list of imaginary
lightning network pub keys, with what could be their aliases
on their right as a comment to help debugging. That array should
obviously be filled with all nodes pub keys that will be part
of the route.

Next, update AMOUNT with the quantity of satoshis that will be
routed.

Finally, OUTGOING_CHAN_ID should contain the channel ID from
where the payment will originate. This is one of the sender's
node channels.

### Prerequisite

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
