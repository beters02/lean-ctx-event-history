local tbl = {}

--- Create a new table with the elements of source tables elements from startIndex -> endIndex
---@param sourceTable table
---@param si number The start index
---@param ei number The end index
function tbl.sub(tbl: {any}, si: number, ei: number?)
    ei = ei or #tbl

    if ei > #tbl then
        error("tbl.sub: End index cannot be greater than the length of the table.")
    end

    if si < 0 then
        error("tbl.sub: Start index cannot be negative.")
    end

    if ei < 0 then
        error("tbl.sub: End index cannot be negative.")
    end

    if si > ei then
        error("tbl.sub: Start index cannot be greater than end index.")
    end
    
    local ntbl = {}
    for i, v in pairs(tbl) do
        if i < si then
            continue
        end

        if i > ei then
            break
        end

        table.insert(ntbl, tbl[i])
    end
    return ntbl
end

return tbl