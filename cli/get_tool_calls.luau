local json = require("@std/json")
local fs = require("@lute/fs")
local parser = require("../parser")
local config = require("../config")

local ToolCall = require("../tool_call")

return function()
    local f = fs.open(config.LeanCtxHistoryLocation, "r")
    local history = json.deserialize(parser.jsonlToJson(fs.read(f)))
    fs.close(f)

    local callsArray = parser.jsonObjectToToolCalls(history)
    return parser.jsonObjectToToolCalls(callsArray)
end :: () -> (ToolCall.ToolCallArray)