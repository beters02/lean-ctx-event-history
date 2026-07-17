local types = require("./types")

local Tool = require("../tool")

local print_commands = require("./print_commands")
local print_tool_calls = require("./print_tool_calls")
local get_tool_calls = require("./get_tool_calls")

export type CliCommand = types.CliCommand
export type CliCommandData = types.CliCommandData
export type CliCommandArray = types.CliCommandArray

type CliCommandClass = {
	__index: CliCommandClass,
	new: (data: types.CliCommandData) -> types.CliCommand,
}

warn = function(msg: string)
    print(string.format("\27[33m%s\27[0m", msg))
end

local Command: CliCommandClass = {} :: CliCommandClass
Command.__index = Command

function Command.new(data: types.CliCommandData): types.CliCommand
	local self: types.CliCommand = {
		name = data.name,
        description = data.description,
        args = data.args or {},
        argsDescriptors = data.argsDescriptors or {},
        callback = data.callback
	}

	return setmetatable(self, Command) :: any
end

local cli = {}

cli.Commands = {

    Command.new({
        name = "help",
        description = "Print all available commands.",
        callback = function()
            print_commands(cli.Commands)
        end
    }),

    Command.new({
        name = "calls",
        description = "Print recent events",
        args = {"<tool>", "<amount>"},
        argsDescriptors = {"The tool to filter by. (default All)", "The amount of history to print. (default 50)"},
        callback = function(...)
            local args = table.pack(...)
            local amnt = nil
            local tool = nil

            if #args > 0 then
                local parsedTool = Tool.fromString(args[1])
                if parsedTool then
                    tool = parsedTool
                else
                    warn("Could not parse argument 1 as Tool: "..args[1].." using default Tool instead.")
                end
                
                if args[2] then
                    if tonumber(args[2]) then
                        amnt = tonumber(args[2])
                    else
                        warn("Could not parse argument 2 as number: "..args[2].." using default number instead.")
                    end
                end
            end
            
            print_tool_calls.recent(get_tool_calls(), tool, amnt)
        end
    }),

    Command.new({
        name = "hitters",
        description = "Print most expensive recent events",
        args = {"<amount>"},
        argsDescriptors = {"The amount of history to print. (default 50)"},
        callback = function(...)
            local args = table.pack(...)
            local amnt = nil

            if #args > 0 then
                if tonumber(args[1]) then
                    amnt = tonumber(args[1])
                else
                    warn("Could not parse argument 1 as number: "..args[1].." using default number instead.")
                end
            end
            
            print_tool_calls.heavyHitters(get_tool_calls(), amnt)
        end
    }),

} :: types.CliCommandArray

function cli.GetCommand(name: string): CliCommand?
    local index = -1
    for i, cmd in pairs(cli.Commands) do
        if cmd.name == name then
            index = i
            break
        end
    end

    return index ~= -1 and cli.Commands[index] or nil
end

function cli.ExecuteCommand(name: string, ...)
    local cmd = cli.GetCommand(name)

    if not cmd then
        error("Command "..cmd.." does not exist.")
    end

    cmd.callback(...)
end

return cli