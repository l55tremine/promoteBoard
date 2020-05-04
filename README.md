# promoteBoard
This is a object for tabletop simulator that has many functions that I believe should already be in the game in some form. But this is the next best thing. https://steamcommunity.com/sharedfiles/filedetails/?id=1459817693

description:

"A tool to help promoted people do things they can already do if they know how to use scripting well. This gives all promoted or "trusted" (an option given by the board) players ease of access to these abilities.

Simple and most used commands include:
"!msg <name or colour> <msg>" - This allows you to message spectators (which can't be done without scripting) or people by their name.

"!move <name> <colour/team>" - This allows promoted people to move other plays to different colours and teams. Which cant be done without scripting.

"!limit <number or off>" - this causes any non-promoted player to be moved to grey when they try to pick up or group more objects than you have set. (5 objects picked up and limit is set to 4)

"!grey", "!blind", "!kick", "!mute", and "!pmt" (short for promote) - these all do what you might expect. But they allow promoted players to do it.

"!sil <name>" - this silences a player, causing them to be muted and have an inability to chat. Them leaving the server and coming back WILL NOT cause them to be able to talk in chat anymore. silencing them again or clearing the list will allow them to talk again.

"!roll <sides> <number of dice>" - this allows players to roll dice when there isn't one available

Full command list: (command, permission required, description)
!a, 2: Used for admins to chat with each other without the whole table seeing
!anc, 2: Announces the given message
!ap, 2: Turns autopromote on and off
!blind, 2: Toggles the players blindfold.
!unblind, 2: Un-blindfolds the player.
!bring, 2: Brings the board to the center or a colour on the basic custom table
!bt, 2: Greys/kicks whoever sits in teal or brown
!destroy, 3: Destroys the board. Useful if you don't know where it is.
!code, 2: This takes the code of an object and puts it in the settings textbox
!grey, 2: Moves the player to grey
!hide, 2: Hides the command board far off the map. Only chat commands can be used.
!hours, 2: Gets the hours of the player
!kick, 2: Kicks the player(s)
!limit, 2: If a (non-promoted) player picks up more items than the selected number, it will move them to grey.
!lock, 2: Locks and makes the board uninteractable
!move, 2: Moves a player to the colour or team selected.
!msg, 0: Sends a secret message to the player/colour selected
!mute, 2: Toggles the players mute
!nick, 2: Nickname a player, the new name will appear each time they chat
!pa, 2: Sets the area of the world to the number specified
!pmt, 2: Promotes a player
!printh, 2: Prints hours instead of broadcasting to promoted players
!printcmds, 2: When someone uses a command it prints what they did in chat
!rb, 0: Turns whatever you chat after the "!rb" into a rainbow of colours
!reset, 3: Resets true and false values, nicknames, broadcast color, and silenced
!roll, 0: Rolls a dice and prints the result
!sil, 2: Mutes a player and silences their chats
!setcolor, 3: Sets the color for printing, can be any seat colour or a hex colour.
!shuffle, 2: Shuffles the seats of players. (1=default, 2=includes black, 3=includes spectators, 4=both
!status, 2: Gets the status of many settings on the board
!steamid, 0: Gets a players steamid, printing it to you, and placing it in the copy text box.
!swap 2: Swaps the first player with the second one or the colour if provided
!test, 0: Just a command to test if the board is on the table
!trust, 4: add or remove people from trusted.
!upload, 3: This will take the text from the settings textbox and set it as the lua code for an object, before reloading it.
!help, 0: Gets the description of a command or a general help statement
To find the help for a specific command type !help !<command>

1: seated
2: promoted
3: trusted
4: host"
