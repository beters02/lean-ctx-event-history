local process = require("@lute/process")
local tbl = require("./tables")
local cli = require("./cli/cli")

local args = process.args

if not args[2] then
    cli.ExecuteCommand("help")
    return
end

if not cli.GetCommand(args[2]) then
    print("Command "..args[2].." does not exist.")
    cli.ExecuteCommand("help")
    return
end

cli.ExecuteCommand(args[2], table.unpack(#args > 2 and tbl.sub(args, 3) or {}))