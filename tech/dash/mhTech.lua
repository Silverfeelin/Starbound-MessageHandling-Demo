require "/scripts/mhDemo/keybinds.lua"
require "/scripts/messageutil.lua"

mhTech = {}

--- Set up the tech
function mhTech.init()
  -- Listen to this message, allowing users to check if this tech is loaded.
  message.setHandler("mhTech_loaded", localHandler(mhTech.handler))

  -- Initialize promise keeper to keep track of responses for sent messages.
  mhTech.keeper = PromiseKeeper.new()

  -- When pressing "f", this will send the messages.
  Bind.create("specialOne", mhTech.send)
end

--- Update the promise keeper for responses to sent messages.
function mhTech.update(args)
  mhTech.keeper:update()
end

--- Simply replies 'true' whenever someone asks if this tech is loaded.
function mhTech.handler()
  return true
end

--- Sends messages to other places.
-- Will send messages to tech, deployment script, nearby objects, active item.
function mhTech.send()
  sb.logInfo("Sending messages from mhTech.")
  local id = entity.id()

  -- Check if our deployment script is running.
  mhTech.sendMessage(id, "mhDeployment_loaded")

  -- Check if we're holding the mhItem active item.
  mhTech.sendMessage(id, "mhItem_held")

  -- Ask any nearby computers (mouse position) if they can do some calculations.
  local computerIds = world.objectQuery(tech.aimPosition(), 3, { order = "nearest" })
  for _,computerId in ipairs(computerIds) do
    mhTech.sendMessage(computerId, "mhComputer_multiply")
    mhTech.sendMessage(computerId, "mhComputer_multiply", "apple", "banana")
    mhTech.sendMessage(computerId, "mhComputer_multiply", 5, 3)
    mhTech.sendMessage(computerId, "mhComputer_secret")
  end
end

--- Sends a message and saves the promise.
-- Response is logged, both for successful and failed messages.
function mhTech.sendMessage(id, message, ...)
  -- Send message
  local promise = world.sendEntityMessage(id, message, ...)

  -- Will run if the message succeeded and we got a valid response.
  local function responseHandler(result)
    mhTech.logSuccessfulPromise(message, result)
  end

  local function errorHandler(err)
    mhTech.logErrorPromise(message, err)
  end

  -- Start tracking of promise.
  -- We don't handle error messages here because we don't care if they failed.
  -- Keep in mind that bad responses (i.e. invalid arguments) don't mean the message will error.
  mhTech.keeper:add(promise, responseHandler, errorHandler)
end

--- Logs the message with a response.
function mhTech.logSuccessfulPromise(message, result)
  sb.logInfo("Message %s received a response: %s", message, type(result) == "table" and sb.printJson(result) or result)
end

function mhTech.logErrorPromise(message, err)
  sb.logInfo("Message %s errored: %s", message, err)
end

-- Inject our init and update code.
local ini = init
init = type(ini) == "function" and function() ini() mhTech.init() end or mhDemo.init
local upd = update
update = type(upd) == "function" and function(args) upd(args) mhTech.update(args) end or mhDemo.update
