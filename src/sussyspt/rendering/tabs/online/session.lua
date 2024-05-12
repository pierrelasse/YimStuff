local exports = {}

function exports.register(tab)
    local tab2 = SussySpt.rendering.newTab("Session")

    function tab2.render()
        yu.rendering.renderCheckbox("Tutorial session", "online_session_ghostsess", function(state)
            if state then
                NETWORK.NETWORK_START_SOLO_TUTORIAL_SESSION()
            else
                NETWORK.NETWORK_END_TUTORIAL_SESSION()
            end
            yu.notify(1, "Tutorial session "..(state and "en" or "dis").."abled!", "Online->Session")
        end)
    end

    tab.sub[8] = tab2
end

return exports
