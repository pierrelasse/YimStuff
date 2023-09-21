# For YimUtils & SussySpt
Feel free to create an issue to report a bug, suggest a feature, or something else idk.

# YimUtils
**YimUtils was made for [YimMenu](https://github.com/YimMenu/YimMenu).**<br />
YimUtils is some sort of a libary for script developers to easily code without having to worry about things like mpx or if a script is running or other basic stuff.<br />
It also offers a key listener, a notification system, and utils for lua like boolstring which converts a boolean to a string or format_seconds, and more.<br />

### How to use in your script????
Add `yu = require "yimutils"` to the top of your script to use yimutils.<br />
Then you can do `yu.` and like use it idk.<br />
You can find [the docs here](https://github.com/pierrelasse/YimStuff/blob/master/docs/yimutils.txt).

## Lua Utils
The utilities for lua have functions such as<br />
format_num, boolstring, is_num_between, get_between_or_default,<br />get_or_default, get_key_from_table, format_seconds, copy_table.

## Notifications
A basic notification system where you can set a prefix for the title and send a notification using the notify function.
```
notify(type, message, [title])
    Param type: Available input:
        1 | "info"
        2 | "warn" | "warning"
        3 | "error" | "severe"
    Param message: The message to be displayed
    Param title: The suffix of the title
```

## Getters (trash category name)
"Getters" (i don't know a better name) return something without requireing arguments.
- get_unique_number() returns a number that was never returned from this function before.
- playerindex() returns a number i think
- is_script_running_hash(hash), and is_script_running(name) return if a script with that hash or name is active.

## Key Listener
A key listener system which made me start this project in the first place.

You can register a callback for a key by using
```lua
yu.key_listener.add_callback(123, function() end)
```

If you don't want to search up what key what id has, then wE haVe thE perFect sOluTioN foR yOU!<br />
You can use the code below to obtain the id of a key of available.
```lua
yu.keys["F1"] -- As example returns the id of the key F1
```
You can also unregister a key listener by using the remove_callback function which inputs the id of the callback.<br />
The id is returned from the add_callback function.

## Stats
You can use that if you don't want to use variables for some reason. Idk what i thought.

## Tasks
When executing stuff in a render loop, it can cause errors.<br />
So for example if you have a button in imgui, and you so things with stat modification, it can cause errors in the console.<br />
To fix this, you can use the following code to run it in the game tick loop? Atleast it fixes the errors in console so ye.
```lua
if ImGui.Button("A button -_-") then
    stats.set_bool("IS_FAT", false) -- Can cause errors
    yu.add_task(function()
        stats.set_bool("IS_FAT", false) -- Shouldn't cause errors :-)
    end)
end
```

You can also use has_task(id) to check if a task is currently running or waiting to be ran.<br />
The id is returned from the add_task function.

## "Injected" features
You can use function string.endswith to check if the string ends with the inputted string.<br />
Example usage:
```lua
thisIsTrue = "sussy baka".endswith("baka")
-- thisIsTrue is true :)
```

# SussySpt
SussySpt (weird name idk) is currently in development and features are getting added constantly.

## Self
- General
    - Invisible (Makes you invisible and your car if possible)
    - Remove blackscreen (Removes the blackscreen)
    - Max singleplayer cash (Sets the cash of all storymode characters to integer limit. I will have to improve this soon)
    - STOP_PLAYER_SWITCH (Currently temporarily)
- Stats
    - Reset mental state (Resets the mental state stat)
    - Badsport (Makes you badsport or not)
    - Remove bounty
    - Remove griefing cooldown for VIP/CEO (Idk what this does. Just copied from somewhere)
- Unlocks<br />
    ![Too lazy to write here](https://cdn.discordapp.com/attachments/1130207747867156566/1154437564510523472/image.png)

## HBO (Heists, Businesses & Other)
- Cayo Perio Heist
    - **Preperations**
    - The cayo perico heist editor allows you to set the
        - Primary target
        - Compound storages (with the amount)
        - Island storages (with the amount)
        - Paintings (buggy)
        - Difficulty
        - Approach
        - Weapons
        - Supply truck location
        - Cutting powder (makes guards weaker)
    - You can also reload the planning board with a button
    - There is also Unlock accesspoints & approaches button :)
    - And complete preps
    - & Remove Pavel & Fencing cut
    - **Cuts**
    - There is also a Cuts Editor
    - **Extra**
    - Remove all cameras
    - Skip sewer tunnel cut
    - Skip door hack
    - Skip fingerprint hack
    - Skip plasmacutter cut
    - Instant finish (solo only)
    - How many lifes you have
    - Real take
    - Cooldown viewer
- Diamond Casino Heist
    - **Preperations**
    - You can set the
        - Target
        - Approach
        - Gunman
        - Driver
        - Hacker
        - Mask
    - Unlock POI & accesspoints
    - Remove npc cuts
    - Unlock cancellation
    - **Extra**
    - Skip fingerprint hack
    - Skip keypad hack
    - Skip vaultdoor drill
    - Cooldown viewer
- Diamond Casino & Resort
    - **Slots**
    - Rig slot mashines (makes you always win)
    - **Lucky wheel**
    - Let's you select what prize you want to win
- Nightclub
    - Lets you refill the popularity... More to come i guess

## Quick actions
- Heal
- Refill health
- Refill armor
- Clear wanted level
- Refresh interior
- Repair vehicle
- Instant BST

## Old
- Self>Stats (Cool stats)
- Heists & Stuff idk (old heist editor)
- Misc
    - Remove all cameras
    - Complete objectives
    - Skip Lamar missions
    - Skip yacht missions
    - Skip ULP missions
    - Kosatka
        - Remove missile cooldown
        - Set missle range to 99999
    - Enable/Disable snow

# Cool
I used "idk" 6 times in the README! Now 7.
Also please give feedback and give me ideas on what to do.
