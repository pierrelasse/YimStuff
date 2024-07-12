local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")
local triggerTransaction = require("sussyspt/util/triggerTransaction")

local exports = {}

function exports.register(tab)
    local tab2 = SussySpt.rendering.newTab("Money")

    local a = {
        transactions = {
            { "15M (Bend Job)",                         0x176D9D54,  15000000 },
            { "15M (Bend Bonus)",                       0xA174F633,  15000000 },
            { "15M (Criminal Mastermind)",              0x3EBB7442,  15000000 },
            { "15M (Gangpos Mastermind)",               0x23F59C7C,  15000000 },
            { "7M (Gang)",                              0xED97AFC1,  7000000 },
            { "3.6M (Casino Heist)",                    0xB703ED29,  3619000 },
            { "3M (Agency Story)",                      0xBD0D94E3,  3000000 },
            { "3M (Gangpos Mastermind)",                0x370A42A5,  3000000 },
            { "2.5M (Gang)",                            0x46521174,  2550000 },
            { "2.5M (Island Heist)",                    0xDBF39508,  2550000 },
            { "2M (Gangpos Award Order)",               0x32537662,  2000000 },
            { "2M (Heist Awards)",                      0x8107BB89,  2000000 },
            { "2M (Tuner Robbery)",                     0x921FCF3C,  2000000 },
            { "2M (Business Hub)",                      0x4B6A869C,  2000000 },
            { "1.5M (Gangpos Loyal Award)",             0x33E1D8F6,  1500000 },
            { "1.2M (Boss Agency)",                     0xCCFA52D,   1200000 },
            { "1M (Music Trip)",                        0xDF314B5A,  1000000 },
            { "1M (Daily Objective Event)",             0x314FB8B0,  1000000 },
            { "1M (Daily Objective)",                   0xBFCBE6B6,  1000000 },
            { "[DETECTED] 1M (Juggalo Story Award)",    0x615762F1,  1000000 },
            { "700K (Gangpos Loyal Award)",             0xED74CC1D,  700000 },
            { "680K (Betting)",                         0xACA75AAE,  680000 },
            { "620K (Vehicle Export)",                  0xEE884170,  620000 },
            { "500K (Casino Straight Flush)",           0x059E889DD, 500000 },
            { "500K (Juggalo Story)",                   0x05F2B7EE,  500000 },
            { "400K (Cayo Heist Award Professional)",   0xAC7144BC,  400000 },
            { "400K (Cayo Heist Award Cat Burglar)",    0xB4CA7969,  400000 },
            { "400K (Cayo Heist Award Elite Thief)",    0xF5AAD2DE,  400000 },
            { "400K (Cayo Heist Award Island Thief)",   0x1868FE18,  400000 },
            { "350K (Casino Heist Award Elite Thief)",  0x7954FD0F,  350000 },
            { "300K (Casino Heist Award All Rounder)",  0x234B8864,  300000 },
            { "300K (Casino Heist Award Pro Thief)",    0x2EC48716,  300000 },
            { "300K (Ambient Job Blast)",               0xC94D30CC,  300000 },
            { "300K (Premium Job)",                     0xFD2A7DE7,  300000 },
            { "270K (Smuggler Agency)",                 0x1B9AFE05,  270000 },
            { "250K (Casino Heist Award Professional)", 0x5D7FD908,  250000 },
            { "250K (Fixer Award Agency Story)",        0x87356274,  250000 },
            { "200K (DoomsDay Finale Bonus)",           0x9145F938,  200000 },
            { "200K (Action Figures)",                  0xCDCF2380,  200000 },
            { "190K (Vehicle Sales)",                   0xFD389995,  190000 },
            { "180K (Jobs)",                            -0x3D3A1CC7, 180000 }
        },
        transaction = 20,
        moneyMade = 0
    }

    function tab2.render()
        -- ImGui.Text("This feature is unstable and it is recommended to leave it on the '1M (Juggalo Story Award)'")
        -- ImGui.Text("You can do this every second so $1M/1s. Seems to be undetected")
        -- ImGui.Spacing()

        ImGui.Text("Currently broken (not receiving any money)")

        if a.moneyMade > 0 then
            ImGui.Text("Money made: "..yu.format_num(a.moneyMade))
        end

        ImGui.PushItemWidth(340)
        if ImGui.BeginCombo("Transaction", a.transactions[a.transaction][1]) then
            for k, v in pairs(a.transactions) do
                if ImGui.Selectable(v[1], false) then
                    a.transaction = k
                end
            end
            ImGui.EndCombo()
        end
        ImGui.PopItemWidth()

        if ImGui.Button("Trigger transaction") then
            yu.rif(function(rs)
                local data = a.transactions[a.transaction]
                if type(data) == "table" then
                    triggerTransaction(rs, data[2], data[3])
                    a.moneyMade = a.moneyMade + data[3]
                end
            end)
        end

        ImGui.SameLine()

        yu.rendering.renderCheckbox("Loop", "online_money_loop", function(state)
            if state then
                yu.rif(function(rs)
                    local data = a.transactions[a.transaction]
                    if type(data) == "table" then
                        while yu.rendering.isCheckboxChecked("online_money_loop") and not a.loop do
                            a.loop = true

                            triggerTransaction(rs, data[2], data[3])
                            a.moneyMade = a.moneyMade + data[3]

                            rs:sleep(1000)

                            a.loop = nil
                        end
                    end
                end)
            end
        end)
        -- yu.rendering.tooltip("You should only use the loop with the '1M (Juggalo Story Award)' transaction")

        if SussySpt.dev and ImGui.Button("Dump globals") then
            tasks.addTask(function()
                local b = values.g.transaction_base
                log.info("====[ Start ]====")
                log.info((b + 1)..": "..globals.get_int(b + 1).." = 2147483646")
                log.info((b + 7)..": "..globals.get_int(b + 7).." = 2147483647")
                log.info((b + 6)..": "..globals.get_int(b + 6).." = 0")
                log.info((b + 5)..": "..globals.get_int(b + 5).." = 0")
                log.info((b + 3)..": "..globals.get_int(b + 3).." = <hash>")
                log.info((b + 2)..": "..globals.get_int(b + 2).." = <amount>")
                log.info(b..": "..globals.get_int(b).." = 2")
                log.info("=====[ End ]=====")
            end)
        end
    end

    tab.sub[9] = tab2
end

return exports
