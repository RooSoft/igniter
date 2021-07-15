import os
import sys

igniter_path = sys.argv[1]
if not os.path.exists(igniter_path):
    print("usage: python3 create_igniter.py <path_to_igniter.sh>")
    exit(1)

output_igniter_path = "customized_igniter.sh"

pub_keys = []
your_pub_key = ""
with open(igniter_path) as f:
    lines = f.readlines()

pubkeys_start_linenumber = 0
pubkeys_end_linenumber = 0
line_index = 0

print("Now you are going to enter all of the node ids in your ring.")
print("Start with the node where you have outbound liquidity.")
print("End with your node.")
print("---------------------------------------------------------")
print("Signal that you're done entering nodes with a blank line.")
print("---------------------------------------------------------")

user_nodes = []
for x in range(500):
    input_channel_id = input('Enter a node id: ')
    if len(input_channel_id) == 0:
        break
    else:
        user_nodes.append(input_channel_id)
print("---------------------------------------------------------")

satoshi_count = input('How many satoshis do you want to send? ')
print("---------------------------------------------------------")

chan_id_string = input('From what channel will the funds originate? ')
print("---------------------------------------------------------")

max_fee_string = input("What is the maximum fee you're willing to pay (in satoishis)? ")
print("---------------------------------------------------------")

needs_alias = input("Are you running this on an umbrel (or need an alias for lncli)? (y or n) ")
print("---------------------------------------------------------")
if needs_alias.startswith("y") or needs_alias.startswith("Y"):
    umbrel_alias_string = "alias lncli='docker exec -it lnd lncli'\n"
else:
    umbrel_alias_string = ""

user_node_string = user_nodes[-1]
user_nodes_index = 0
user_nodes = user_nodes[:-1]
updated_lines = []
for one in lines:
    words = one.split()
    updated_string = one
    if line_index == 2 and len(umbrel_alias_string) > 0:
        updated_lines.append(umbrel_alias_string)
    elif one.startswith("declare pub_keys=("):
        pubkeys_start_linenumber = line_index
    elif updated_string.startswith(")") and pubkeys_start_linenumber != 0 and pubkeys_end_linenumber == 0:
        pubkeys_end_linenumber = line_index
    elif pubkeys_start_linenumber > 0 and pubkeys_end_linenumber == 0:
        if one.endswith("# first hop pub key (not yours)\n"):
            for node_str in user_nodes:
                updated_string = updated_string.replace(words[0], node_str)
                updated_lines.append(updated_string)
                updated_string = updated_string.replace(node_str, words[0])
                updated_string = updated_string.replace("# first hop pub key (not yours)", "# next hop's pub key")
            updated_string = ""
            # print("first pubkey", "--", words[0])
        elif updated_string.endswith("# next hop's pub key\n"):
            updated_string = ""
            # pub_keys.append(words[0])
            # print("another pubkey", "--", words[0])
        elif updated_string.endswith("# your node's pub key\n"):
            updated_string = updated_string.replace(words[0], user_node_string)
            # print("your pubkey", "--", words[0])
    elif updated_string.startswith("AMOUNT="):
        updated_string = updated_string.replace(words[0], "AMOUNT=" + satoshi_count)
    elif updated_string.startswith("OUTGOING_CHAN_ID="):
        updated_string = updated_string.replace(words[0], "OUTGOING_CHAN_ID=" + chan_id_string)
    elif updated_string.startswith("MAX_FEE="):
        updated_string = updated_string.replace(words[0], "MAX_FEE=" + max_fee_string)

    if len(updated_string) > 0:
        updated_lines.append(updated_string)
    line_index += 1

# print(updated_lines)


with open(output_igniter_path, 'w') as f:
    for one_line in updated_lines:
        f.write(one_line)
