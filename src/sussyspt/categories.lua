local cfg = require("./config")

SussySpt.debug("Initializing categories")

require("./catHBO")

for k, v in pairs({ "hbo", "qa" }) do
    yu.rendering.setCheckboxChecked("cat_"..v, cfg.get("cat_"..v, false))
end
