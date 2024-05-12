local exports = {}

exports.tasks = {}

function exports.addTask(cb)
    local id = #exports.tasks + 1
    exports.tasks[id] = cb
    return id
end

function exports.runAll(rs)
    for taskId, taskFunc in pairs(yu.copy_table(exports.tasks)) do
        exports.tasks[taskId] = nil
        local success, result = pcall(taskFunc, rs)
        if not success then
            log.warning("Error while executing task #'"..taskId.."': "..result)
            yu.notify(3, "Error executing task. See console for more details")
        end
    end
end

return exports
