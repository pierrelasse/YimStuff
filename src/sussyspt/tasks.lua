local tasks = {}

tasks.tasks = {}

function tasks.addTask(cb)
    local id = #tasks.tasks + 1
    tasks.tasks[id] = cb
    return id
end

function tasks.runAll(rs)
    for taskId, taskFunc in pairs(yu.copy_table(tasks.tasks)) do
        tasks.tasks[taskId] = nil
        local success, result = pcall(taskFunc, rs)
        if not success then
            log.warning("Error while executing task #'"..taskId.."': "..result)
            yu.notify(3, "Error executing task. See console for more details")
        end
    end
end

return tasks
