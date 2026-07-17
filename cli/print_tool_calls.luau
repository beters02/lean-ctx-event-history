--!strict

local tableext = require("@std/tableext")
local tbl = require("../tables")

local ToolCall = require("../tool_call")
local Tool = require("../tool")

local function formatNumber(value: number): string
	local formatted = tostring(math.floor(value))

	while true do
		local updated, replacements =
			string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")

		formatted = updated

		if replacements == 0 then
			break
		end
	end

	return formatted
end

local function formatTimestamp(timestamp: string): string
	local date, time = string.match(
		timestamp,
		"^(%d%d%d%d%-%d%d%-%d%d)T(%d%d:%d%d:%d%d)"
	)

	if date and time then
		return `{date} {time}`
	end

	return timestamp
end

local function truncate(value: string, maximumLength: number): string
	if #value <= maximumLength then
		return value
	end

	return string.sub(value, 1, maximumLength - 3) .. "..."
end

local function printToolCalls(toolCalls: ToolCall.ToolCallArray, selectedTool: Tool.Tool, descending: boolean, truncateAt: number?)
	local totalOriginal = 0
	local totalSaved = 0

	print("")
	print(
		if selectedTool == Tool.All
			then "Recent Tool Calls"
			else `Recent {selectedTool.name} Calls`
	)
	print(string.rep("=", 100))

	print(
		string.format(
			"%-19s  %-20s  %10s  %10s  %8s  %s",
			"TIMESTAMP",
			"TOOL",
			"ORIGINAL",
			"SAVED",
			"SAVINGS",
			"DETAILS"
		)
	)

	print(string.rep("-", 100))

	if #toolCalls == 0 then
		print(`No recent calls found for "{selectedTool.name}".`)
		print("")
		return
	end

	if not descending then
		toolCalls = tableext.reverse(toolCalls)
	end

	for _, call in ipairs(toolCalls) do
		local original = call:getOriginalTokens()
		local saved = call:getTokensSaved()

		totalOriginal += original
		totalSaved += saved

		local details = call.kind.mode or ""

		if call.kind.path then
			details = if details == ""
				then call.kind.path
				else `{details} | {call.kind.path}`
		end

		print(
			string.format(
				"%-19s  %-20s  %10s  %10s  %7.1f%%  %s",
				formatTimestamp(call.timestamp),
				truncate(call:getTool(), 20),
				formatNumber(original),
				formatNumber(saved),
				call:getSavingsPercent(),
				truncate(details, truncateAt or 30)
			)
		)
	end

	local totalSavingsPercent = if totalOriginal > 0
		then totalSaved / totalOriginal * 100
		else 0

	print(string.rep("-", 100))

	print(
		string.format(
			"Showing %d call(s) | Original: %s | Saved: %s | Savings: %.1f%%",
			#toolCalls,
			formatNumber(totalOriginal),
			formatNumber(totalSaved),
			totalSavingsPercent
		)
	)

	print("")
end

-- printRecentToolCalls: (toolCalls: ToolCallArray, amnt: number? = 50, tool: Tool? = Tool.All)
--- Prints recent tool calls
--- @param toolCals: ToolCallArray - The deserialized tool calls.
--- @param amnt: number? = 50 - The amount of calls to print.
--- @param tool: Tool? = Tool.All - Filter by this tool.
local function printRecentToolCalls(
	toolCalls: ToolCall.ToolCallArray,
	tool: Tool.Tool?,
    amnt: number?,
	descending: boolean?
)
	local amount = math.max(0, math.floor(amnt or 50))
	local selectedTool = tool or Tool.All

	local matches: ToolCall.ToolCallArray = {}

	for index = #toolCalls, 1, -1 do
		local call = toolCalls[index]

		local toolMatches = selectedTool == Tool.All
			or selectedTool:matches(call:getTool())

		if toolMatches then
			table.insert(matches, call)

			if #matches >= amount then
				break
			end
		end
	end

	printToolCalls(matches, selectedTool, descending or false)
end

local function printHeavyHitters(toolCalls: ToolCall.ToolCallArray, amnt: number?, descending: boolean?)
	local amount = math.max(0, math.floor(amnt or 50))
	local matches: ToolCall.ToolCallArray = table.clone(toolCalls)

	table.sort(matches, function(a, b)
		return a:getOriginalTokens() - a:getTokensSaved() > b:getOriginalTokens() - b:getTokensSaved()
	end)
	
	printToolCalls(tbl.sub(matches, 1, amount), Tool.All, descending or false, 100)
end

return {
	recent = printRecentToolCalls,
	heavyHitters = printHeavyHitters
}