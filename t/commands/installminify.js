
const fs = require("fs");

const argParser = require("../util/argParser");


async function download(name, url, saveTo, verbose) {
    try {
        if (verbose) console.log(`> (${name}) Fetching from ${url}...`);
        const res = await fetch(url);
        if (!res.ok) {
            if (verbose) console.log(`> (${name}) Error while requesting ${url}: ${res.status} ${res.statusText}`);
            return;
        }

        if (verbose) console.log(`> (${name}) Saving to file...`);
        let content = await res.text();

        if (name === "luamin") {
            if (verbose) console.log(`> (${name}) Patching file...`);
            content = content.replace("require('luaparse')", "require('./luaparse');\n    luaparse.defaultOptions.luaVersion = \"5.3\";");
            if (verbose) console.log(`> (${name}) Patch applied!`);
        }

        fs.writeFileSync(saveTo, content);
        if (verbose) console.log(`> (${name}) Done!`);

    } catch (err) {
        if (verbose) console.log(`> (${name}) Error:\n${err.stack || err}`);
    }
}

/**
 *
 * @param {string} command
 * @param {argParser.ArgParser} parser
 * @returns {boolean}
 */
module.exports.handle = async (command, parser) => {
    if (command !== "installminify") return;

    const verbose = !parser.has("s", "silent");

    if (!fs.existsSync("./t/minify")) {
        if (verbose) {
            console.log("> Minify folder not found. Is the cwd correct?");
        }
        return;
    }

    const luaparse = download("luaparse", "https://raw.githubusercontent.com/fstirlitz/luaparse/master/luaparse.js", "./t/minify/luaparse.js", verbose);
    const luamin = download("luamin", "https://raw.githubusercontent.com/mathiasbynens/luamin/master/luamin.js", "./t/minify/luamin.js", verbose);
    await luaparse;
    await luamin;
    if (verbose) console.log("> Done!");

    return true;
};
