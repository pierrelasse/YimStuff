# Some of the info below might be outdated

# YimUtils
YimUtils is some sort of a libary for script developers to easily code without having to worry about things like mpx or if a script is running or other basic stuff.<br />
It also offers a key listener, a notification system, and utils for lua like boolstring which converts a boolean to a string or format_seconds, and more.<br />

### How to use in your script????
Add `yu = require "yimutils"` to the top of your script to use yimutils.<br />
Alternatively you can put the content of yimutils.lua at the top of your script.
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
