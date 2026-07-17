local types = require("./types")

return function(commands: types.CliCommandArray)
    for i, v in pairs(commands) do
        print("")
        print("Available Commands")
        print("------------------")

        local longestName = 0

        for _, command in ipairs(commands) do
            longestName = math.max(longestName, #command.name)
        end

        for _, command in ipairs(commands) do
            local usage = command.name

            if command.args and #command.args > 0 then
                usage ..= " " .. table.concat(command.args, " ")
            end

            local padding = string.rep(" ", longestName - #command.name + 4)

            print(`  {usage}{padding}{command.description}`)

            if command.argsDescriptors then
                for index, descriptor in ipairs(command.argsDescriptors) do
                    local argumentName = command.args and command.args[index] or `arg{index}`
                    print(`      {argumentName}: {descriptor}`)
                end
            end
        end

        print("")
    end
end