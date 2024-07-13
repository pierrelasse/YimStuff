local chatlog = {}

chatlog.messages = {}

function chatlog.rebuildLog()
    local text = ""
    local newline = ""
    local doTimestamp = yu.rendering.isCheckboxChecked("online_chatlog_log_timestamp")
    for _, message in pairs(chatlog.messages) do
        text = text..newline..(doTimestamp and ("["..message[4].."] ") or "")..message[2]..": "..message[3]
        newline = "\n"
    end
    chatlog.text = text
end

function chatlog.registerListener()
    chatlog.registerListener = nil

    event.register_handler(menu_event.ChatMessageReceived, function(player_id, chat_message)
        if yu.rendering.isCheckboxChecked("online_chatlog_enabled") then
            local name = PLAYER.GET_PLAYER_NAME(player_id)
            chatlog.messages[#chatlog.messages + 1] = {
                player_id,
                name,
                chat_message,
                os.date("%H:%M:%S")
            }

            if yu.rendering.isCheckboxChecked("online_chatlog_console") then
                log.info("[CHAT] "..name..": "..chat_message)
            end

            chatlog.rebuildLog()
        end
    end)
end

return chatlog
