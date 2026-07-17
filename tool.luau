local types = require("./types")

export type Tool = types.Tool

type ToolClass = {
	new: (name: string, aliases: { string }?) -> Tool,
	fromString: (value: string) -> Tool?,

	All: Tool,
	Read: Tool,
	Search: Tool,
	Compose: Tool,
	Shell: Tool,
	Tree: Tool,
	Knowledge: Tool,
	Session: Tool,
	Call: Tool,
	DiscoverTools: Tool,

	values: { Tool },
}

local Tool = {} :: ToolClass

local ToolMetatable = {}
ToolMetatable.__index = ToolMetatable

function Tool.new(name: string, aliases: { string }?): Tool
	return setmetatable({
		name = name,
		aliases = aliases or {},
	}, ToolMetatable) :: any
end

function ToolMetatable.matches(self: Tool, value: string): boolean
	local normalized = string.lower(value)

	if string.lower(self.name) == normalized then
		return true
	end

	for _, alias in ipairs(self.aliases) do
		if string.lower(alias) == normalized then
			return true
		end
	end

	return false
end

Tool.All = Tool.new("all", { "*" })

Tool.Read = Tool.new("ctx_read", { "read" })
Tool.Search = Tool.new("ctx_search", { "search" })
Tool.Compose = Tool.new("ctx_compose", { "compose" })
Tool.Shell = Tool.new("ctx_shell", { "shell" })
Tool.Tree = Tool.new("ctx_tree", { "tree" })
Tool.Knowledge = Tool.new("ctx_knowledge", { "knowledge", "recall" })
Tool.Session = Tool.new("ctx_session", { "session" })
Tool.Call = Tool.new("ctx_call", { "call" })
Tool.DiscoverTools = Tool.new(
	"ctx_discover_tools",
	{ "discover", "discover_tools" }
)

Tool.values = {
	Tool.All,
	Tool.Read,
	Tool.Search,
	Tool.Compose,
	Tool.Shell,
	Tool.Tree,
	Tool.Knowledge,
	Tool.Session,
	Tool.Call,
	Tool.DiscoverTools,
}

function Tool.fromString(value: string): Tool?
    print(value)
	for _, tool in ipairs(Tool.values) do
		if tool:matches(value) then
			return tool
		end
	end

	return nil
end

return Tool