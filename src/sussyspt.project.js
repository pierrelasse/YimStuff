
const fs = require("fs");


function getMinify() {
    if (!fs.existsSync("t/minify/luamin.js")) {
        return;
    }
    return require("../t/minify/luamin").minify;
}

function expandEnvVars(input) {
    return input.replace(/%([^%]+)%/g, (_, n) => process.env[n])
}

let parser;
let isRelease;

module.exports = {
    configure: (parserIn) => {
        parser = parserIn;
        isRelease = parser.hasShort("re") || parser.hasLong("release");
    },

    outName: () => {
        return "SussySpt.lua"
    },

    mapPack: (data, { path, relPath }) => {
        if (relPath === "version.lua") {
            console.log(`>   Transforming ${relPath}`);

            data = data.replace("0 --[[VERSIONTYPE]]", isRelease ? 1 : 2);
            data = data.replace("0 --[[BUILD]]", Date.now());

            console.log(">   Transformed!");
        }

        return data;
    },
    mapPackPost: (data) => {
        if (!isRelease) return;

        console.log("\n> Minifiying...");

        try {
            const minify = getMinify();
            if (minify !== undefined) {
                data = `--[[ More info & source @ https://github.com/pierrelasse/YimStuff ]]\n${minify(data)}\n`;
                console.log("> Minified!");
            } else {
                console.log(`> Minifying not available. Use 't installminify' to install the minifier`);
            }
        } catch (err) {
            throw new Error(`An error occured while minifing the file:\n${err.stack || err}`);
        }

        return data;
    },

    finish: (data) => {
        if (!parser.hasShort("nocpy")) {
            let scriptsPath = expandEnvVars(parser.getLong("scriptsDir") || "%appdata%/YimMenu/scripts/");
            if (fs.existsSync(scriptsPath)) {
                while (scriptsPath.includes("\\")) scriptsPath = scriptsPath.replace("\\", "/");

                console.log(`\n> Copying final script to ${scriptsPath}`);

                fs.writeFileSync(`${scriptsPath}/SussySpt.lua`, data);

                console.log("> Copied!");
            }
        }
    }
};
