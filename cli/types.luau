export type CliCommand = {
    name: string,
    description: string,
    args: {string}?,
    argsDescriptors: {string}?,
    callback: (...any) -> ()
}

export type CliCommandData = CliCommand

export type CliCommandArray = {CliCommand}

export type Tool = {
	name: string,
	aliases: { string },

	matches: (self: Tool, value: string) -> boolean,
}

return {}