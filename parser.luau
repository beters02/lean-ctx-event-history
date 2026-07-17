local json = require("@std/json")

local ToolCall = require("./tool_call")

export type JsonPrimitive = boolean | number | string
export type JsonValue = JsonPrimitive | JsonArray | JsonObject

export type JsonArray = { JsonValue }
export type JsonObject = {
	[string]: JsonValue,
}

local parser = {}

function parser.jsonlToJson(source: string): string
	local values = {}

	local startIndex: number? = nil
	local depth = 0
	local inString = false
	local escaped = false
	local physicalLine = 1
	local valueStartLine = 1

	for index = 1, #source do
		local character = string.sub(source, index, index)

		if character == "\n" then
			physicalLine += 1
		end

		if startIndex == nil then
			-- Skip whitespace between JSON values.
			if string.match(character, "%s") then
				continue
			end

			if character ~= "{" and character ~= "[" then
				error(
					`Unexpected character "{character}" at line {physicalLine}, byte {index}`
				)
			end

			startIndex = index
			valueStartLine = physicalLine
			depth = 1
			inString = false
			escaped = false
			continue
		end

		if inString then
			if escaped then
				escaped = false
			elseif character == "\\" then
				escaped = true
			elseif character == '"' then
				inString = false
			end

			continue
		end

		if character == '"' then
			inString = true
		elseif character == "{" or character == "[" then
			depth += 1
		elseif character == "}" or character == "]" then
			depth -= 1

			if depth < 0 then
				error(`Unexpected closing bracket at line {physicalLine}`)
			end

			if depth == 0 then
				local jsonValue = string.sub(source, startIndex, index)
				-- JSON null cannot be represented normally in a Luau array.
				-- Your records are objects, so this should be fine.

				local success, decoded = pcall(json.deserialize, jsonValue)

				if not success then
					error(
						`Failed to parse JSON value beginning at line {valueStartLine}: {decoded}`
					)
				end

				table.insert(values, decoded)
				startIndex = nil
			end
		end
	end

	if startIndex ~= nil then
		error(`Incomplete JSON value beginning at line {valueStartLine}`)
	end

	return json.serialize(values, true)
end

function parser.jsonObjectToToolCalls(values: JsonArray): { ToolCall.ToolCall }
	local results: { ToolCall.ToolCall } = {}

	for index, value in values do
		assert(type(value) == "table", `Expected object at index {index}`)

		local object = value :: JsonObject
		local kindValue = object.kind

		assert(type(kindValue) == "table", `Missing or invalid kind at index {index}`)

		local kind = kindValue :: JsonObject

		-- The log also contains AgentAction and potentially other event types.
		if kind.type ~= "ToolCall" then
			continue
		end

		assert(type(object.id) == "number", `Missing or invalid id at index {index}`)
		assert(
			type(object.timestamp) == "string",
			`Missing or invalid timestamp at index {index}`
		)
		assert(type(kind.tool) == "string", `Missing tool at index {index}`)
		assert(
			type(kind.tokens_original) == "number",
			`Missing tokens_original at index {index}`
		)
		assert(
			type(kind.tokens_saved) == "number",
			`Missing tokens_saved at index {index}`
		)
		assert(
			type(kind.duration_ms) == "number",
			`Missing duration_ms at index {index}`
		)

		local data: ToolCall.ToolCallData = {
			id = object.id,
			timestamp = object.timestamp,

			kind = {
				type = "ToolCall",
				tool = kind.tool,
				tokens_original = kind.tokens_original,
				tokens_saved = kind.tokens_saved,
				duration_ms = kind.duration_ms,

				mode = if type(kind.mode) == "string"
					then kind.mode
					else nil,

				path = if type(kind.path) == "string"
					then kind.path
					else nil,
			},
		}

		table.insert(results, ToolCall.new(data))
	end

	return results
end

return parser