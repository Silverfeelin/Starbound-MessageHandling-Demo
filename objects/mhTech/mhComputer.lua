require "/scripts/messageutil.lua"

function init()
  message.setHandler("mhComputer_multiply", simpleHandler(multiply))
  message.setHandler("mhComputer_secret", localHandler(secret))
end

function secret()
  return 42
end

function multiply(a, b)
  if type(a) ~= "number" or type(b) ~= "number" then
    return string.format("Cannot multiply %s with %s.", a, b)
  end

  local answer = a * b
  local response = {
    answer = answer,
    message = string.format("%s * %s = %s", a, b, answer)
  }

  object.say(response.message)

  return response
end
