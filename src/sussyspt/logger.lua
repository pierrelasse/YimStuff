-- TODO: Recode

SussySpt.debugtext = ""

function SussySpt.debug(s)
    if type(s) == "string" then
        SussySpt.debugtext = SussySpt.debugtext..(SussySpt.debugtext == "" and "" or "\n")..s
        if yu.rendering.isCheckboxChecked("debug_console") then
            log.debug(s)
        end
    end
end
