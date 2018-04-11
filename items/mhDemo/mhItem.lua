require "/scripts/messageutil.lua"

local promiseKeeper
local success = false

function init()
  message.setHandler("mhItem_held", localHandler(messageHandler))
  promiseKeeper = PromiseKeeper.new()
end

function update(dt, fireMode, shiftHeld)
  promiseKeeper:update()

  if success and animator.animationState("firing") == "off" then
    success = false
    player.giveItem({name = "money", count = 100})
    item.consume(1)
  end
end

function activate(fireMode, shiftHeld)
  sendMessages()
end

function sendMessages()
  local promise = world.sendEntityMessage(player.id(), "mhTech_loaded")
  promiseKeeper:add(promise,
    function(bool) -- onSuccess
      if bool then
        animator.setAnimationState("firing", "fire")
        success = true
      end
    end,
    function(err) -- onError
      animator.setAnimationState("firing", "fail")
    end)
end

function messageHandler()
  return true
end
