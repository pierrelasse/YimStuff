function exports.register(tab)
    local tab2 = SussySpt.rendering.newTab("Session")

    tab2.should_display = SussySpt.getDev

    function tab2.render()
        yu.rendering.renderCheckbox("Create ghost session", "online_session_ghostsess", function(state)
            if state then
                NETWORK.NETWORK_START_SOLO_TUTORIAL_SESSION()
            else
                NETWORK.NETWORK_END_TUTORIAL_SESSION()
            end
            yu.notify(1, "Ghost session "..(state and "en" or "dis").."abled!", "Online->Session")
        end)
        yu.rendering.tooltip("This really just puts the players client-side under the map")
    end

    tab.sub[8] = tab2
end

return exports
