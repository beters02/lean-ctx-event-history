--!strict

local types = require("./types")

export type ToolCall = types.ToolCall
export type ToolCallData = types.ToolCallData
export type ToolCallArray = types.ToolCallArray

type ToolCallClass = {
	__index: ToolCallClass,
	new: (data: ToolCallData) -> ToolCall,

	getTool: (self: ToolCall) -> string,
	getTokensSaved: (self: ToolCall) -> number,
	getOriginalTokens: (self: ToolCall) -> number,
	getSavingsPercent: (self: ToolCall) -> number,
	isTool: (self: ToolCall, toolName: string) -> boolean,
}

local ToolCall: ToolCallClass = {} :: ToolCallClass
ToolCall.__index = ToolCall

function ToolCall.new(data: ToolCallData): ToolCall
	local self = {
		id = data.id,
		timestamp = data.timestamp,
		kind = data.kind,
	}

	return setmetatable(self, ToolCall) :: any
end

function ToolCall.getTool(self: ToolCall): string
	return self.kind.tool
end

function ToolCall.getTokensSaved(self: ToolCall): number
	return self.kind.tokens_saved
end

function ToolCall.getOriginalTokens(self: ToolCall): number
	return self.kind.tokens_original
end

function ToolCall.getSavingsPercent(self: ToolCall): number
	if self.kind.tokens_original <= 0 then
		return 0
	end

	return self.kind.tokens_saved / self.kind.tokens_original * 100
end

function ToolCall.isTool(self: ToolCall, toolName: string): boolean
	return self.kind.tool == toolName
end

return ToolCall