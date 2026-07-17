export type Tool = {
	name: string,
	aliases: { string },

	matches: (self: Tool, value: string) -> boolean,
}

export type ToolCallKindData = {
	type: "ToolCall",
	tool: string,
	tokens_original: number,
	tokens_saved: number,
	mode: string?,
	duration_ms: number,
	path: string?,
}

export type ToolCallData = {
	id: number,
	timestamp: string,
	kind: ToolCallKindData,
}

export type ToolCall = {
	id: number,
	timestamp: string,
	kind: ToolCallKindData,

	getTool: (self: ToolCall) -> string,
	getTokensSaved: (self: ToolCall) -> number,
	getOriginalTokens: (self: ToolCall) -> number,
	getSavingsPercent: (self: ToolCall) -> number,
	isTool: (self: ToolCall, toolName: string) -> boolean,
}

export type ToolCallArray = {ToolCall}

return {}