SussySpt.debug("Initializing chatlog")

SussySpt.chatlog = {
    messages = {},
    rebuildLog = function()
        local text = ""
        local newline = ""
        local doTimestamp = yu.rendering.isCheckboxChecked("online_chatlog_log_timestamp")
        for _, message in pairs(SussySpt.chatlog.messages) do
            text = text..newline..(doTimestamp and ("["..message[4].."] ") or "")..message[2]..": "..message[3]
            newline = "\n"
        end

        SussySpt.chatlog.text = text
    end
}

event.register_handler(menu_event.ChatMessageReceived, function(player_id, chat_message)
    if yu.rendering.isCheckboxChecked("online_chatlog_enabled") then
        local name = PLAYER.GET_PLAYER_NAME(player_id)
        SussySpt.chatlog.messages[#SussySpt.chatlog.messages + 1] = {
            player_id,
            name,
            chat_message,
            os.date("%H:%M:%S")
        }

        if yu.rendering.isCheckboxChecked("online_chatlog_console") then
            log.info("[CHAT] "..name..": "..chat_message)
        end

        SussySpt.chatlog.rebuildLog()
    end
end)
