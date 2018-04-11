require "/scripts/messageutil.lua"

mhDemo = {}

function mhDemo.init()
  message.setHandler("mhDeployment_loaded", localHandler(mhDemo.handler))
end

function mhDemo.handler()
  return true
end

local ini = init
init = type(ini) == "function" and function() ini() mhDemo.init() end or mhDemo.init
