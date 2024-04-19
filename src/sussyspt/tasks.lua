exports.tasks = {}

function exports.addTask(cb)
    local id = #exports.tasks + 1
    exports.tasks[id] = cb
    return id
end

function exports.runAll(rs)
    for k, v in pairs(exports.tasks) do
        local success, result = pcall(v, rs)
        if not success then
            log.warning("Error while executing task #'"..k.."': "..result)
            yu.notify(3, "Error executing task. See console for more details")
        end
        exports.tasks[k] = nil
    end
end

return exports
