# Message Handling Demo

Entity messages allow us to share data between scripts and even between different clients. This project contains some simple examples of sending and handling entity messages.

If you already know how to work with entity messages, there's probably not much more in this project for you. The [Wiki](https://github.com/Silverfeelin/Starbound-MessageHandling-Demo/wiki) may still contain some useful information, though.

## Deployment Script

* [`/scripts/mhDemo/mhDeployment.lua`](scripts/mhDemo/mhDeployment.lua)

Deployment scripts are automatically loaded alongside the player.
Our deployment script simply handles the message `mhDeployment_loaded` by responding with `true`, but only locally.  

This message will always respond `true` when sent to yourself, but will never respond with `true` when sent to or received by other entities.

> Note: Due to the way message handlers and Lua in general work, you can never "not" return a value from your handler. Even local handlers will return 'nil', and the promise will still succeed.  
> In this use case, it would mean users could check if your deployment script is loaded simply by checking if the promise succeeded or not (regardless of the result value).

##  Object

* [`/objects/mhTech/mhComputer.lua`]("objects/mhTech/mhComputer.lua")

The `mhComputer` object can multiply two numbers. It is truly a miracle this tiny machine is capable of such complex requests /s.


You can obtain the object with `/spawnitem mhComputer`.

The object script sets two message handlers, which will be covered individually.

### Multiplying

The message handler `mhComputer_multiply` can be used to multiply two numbers.

We want everyone to be able to use this computer, so a `simpleHandler` is used instead of a `localHandler`.

Because anyone could send any data, verification of parameters is important. If either value is not a number, we return an error message.

> Note: As a message is a valid response, this "error" message is simply a string. The message will still succeed and yield a result! **Never** call `error()` in your message handler, it will simply break your own script!

If both numbers are valid, the answer is returned as a Lua object. This makes both the actual answer and a formatted message easily accessible. The object will also say this message in a text bubble.

### Secret

The computer knows of a secret code, only accessible to local entities. Good luck trying to access it, though!

When sending the message `mhComputer_secret` from our tech, deployment or active item script, the response will always be `nil`.

We might have placed the object, but the object is not controlled/managed by the player. Even in single player, it will not work from a player script.

## Tech

* [`/tech/dash/mhTech.lua`](tech/dash/mhTech.lua)

A script has been added to the dash tech, which we'll use to send messages to objects and other player scripts.

To use this script, you must equip the `dash` tech.

### Message Handler

Just like the deployment script, the tech script has a local message handler (`mhTech_loaded`) that'll simply respond with true.

Although this feature may seem useless due to the presence of `player.equippedTech`, it can still be used to determine if this specific module is loaded (and it's just an example, geez..).

### Sending Messages

When pressing `f`, the script will send a couple of messages to the player, and a couple of messages to the objects near your cursor.

* `mhDeployment_loaded`  
Sent to yourself, and will respond `true`.
* `mhItem_held`  
Sent to yourself, and will respond with `true` if the demo item is held.
* `mhComputer_multiply`  
Sent to nearby objects. Expected: `"Cannot multiply nil with nil."`.
* `mhComputer_multiply` (`"apple", "banana"`)  
Sent to nearby objects. Expected: `"Cannot multiply apple with banana."`.
* `mhComputer_multiply` (`5`, `3`)  
Sent to nearby objects. Expected: `{ answer = 15, message = "5 * 3 = 15"}`.
* `mhComputer_secret`  
Sent to nearby objects. Expected: `nil`.

Since the `mhComputer` messages are sent to all objects near your cursor, you may see some failed messages as well (`"Message not handled by entity"`). If no objects were found near your cursor, nothing will happen as no messages were sent.

### Promise Keeper

All message responses are managed by the promise keeper created in `mhTech.init`. We update the promise keeper in `mhTech.update`.

In `mhTech.sendMessage`, the message is sent to the entity and the response is passed to the promise keeper. For our `onSuccess` and `onError` callback we simply log the results.

## Active Item

The active item `mhItem` will reward you, but only if you have the best tech equipped: `dash`.

You can obtain the item with `/spawnitem mhItem`.

### Message Handler

This script comes with a local message handler (`mhItem_held`) which can be used to check if this item is being held. The feature itself is basically useless due to the presence of `world.entityHandItem`, but let us ignore that.

### Sending Messages

On firing, the item will send the message `mhTech_loaded`, which will check if the tech module is loaded.

If the module is loaded (`onSuccess`), the item will be consumed and the player will receive 100 coins and the confetti animation will play.

If the module is not loaded (`onError`), the item will make an error noise.

Just like the tech module, promises are managed by a promise keeper.
