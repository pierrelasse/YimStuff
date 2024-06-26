
const fs = require("fs");
const _path = require("path");

const argParser = require("../util/argParser");


const ensureFolderCreated = (folderPath) => { if (!fs.existsSync(folderPath)) fs.mkdirSync(folderPath, { recursive: true }); };

const normalizePath = (path) => _path.normalize(path).replace(/\\/g, "/");

function pack(srcDir, srcProjectDir, entryFile, outFile, callback, ext) {
    const modules = [];
    let moduleCounter = 0;
    const requireMapping = {};

    if (!require.extensions[ext]) require.extensions[ext] = function () { };
    // const prevExtensions = require.extensions;
    // require.extensions = {
    //     [ext]: function () { }
    // };

    function packFile(path) {
        const moduleId = moduleCounter;

        const resolveOptions = { paths: [_path.dirname(path)] };

        let fileContent = fs.readFileSync(path).toString().trim();

        fileContent = fileContent.replace(/require\(["'](.+?)["']\)/g,
            /** @param {string} modulePath */
            (match, modulePath) => {
                const getLine = () => fileContent.substring(0, fileContent.indexOf(match)).split("\n").length;

                let resolved;
                try {
                    if (modulePath.startsWith(".") === true) {
                        resolved = normalizePath(require.resolve(modulePath, resolveOptions));
                    } else {
                        resolved = normalizePath(`${srcDir}${modulePath}.lua`);
                        if (fs.existsSync(resolved) === false) throw undefined;
                    }
                } catch (ignored) {
                    throw Error(`Error while resolving module path for '${modulePath}' in [${path}:${getLine()}]`);
                }

                if (requireMapping.hasOwnProperty(resolved) === false) {
                    requireMapping[resolved] = ++moduleCounter;
                    packFile(resolved);
                }
                return `require(${requireMapping[resolved]})`;
            }
        );

        const relPath = path.replace(srcDir, "");

        if (callback !== undefined) {
            fileContent = callback(fileContent, { path, relPath }) || fileContent;
        }

        const moduleContent = fileContent
            .split("\n")
            .filter(v => v.trimStart().length !== 0)
            .join("\n            ");
        modules.push(`[${moduleId}] = function(require) --[[ ${relPath} ]]\n            ${moduleContent}\n        end`);
    }

    requireMapping[entryFile] = moduleCounter;
    packFile(entryFile);

    // require.extensions = prevExtensions;

    const out = `do
    local modules = {
        ${modules.join(",\n        ")}
    }
    local cache = {}

    local function mrequire(path)
        local val = cache[path]
        if val ~= nil then return val.exports end
        local module = {exports = nil}
        cache[path] = module
        local success, result = pcall(modules[path], mrequire)
        if success then
            if result ~= nil and result ~= module.exports then
                module.exports = result
            end
        else
            print("[!!!] Error require-ing "..path..": "..result.." [!!!]")
        end
        return module.exports
    end

    return mrequire(0)
end
`;

    fs.writeFileSync(outFile, out);

    return out;
}

function checkConfigFile(parser) {
    if (parser.hasShort("stfuconfig")) return;
    if (!fs.existsSync("config.json")) return;
    console.log(`
You still have the config.json file.
  It is now no longer used.
  If you want to set a custom scripts dir,
  use './t.sh build --scriptsDir="X:/path/to/your/scripts/folder/"'
`);
}

/**
 *
 * @param {string} command
 * @param {argParser.ArgParser} parser
 * @returns {boolean}
 */
module.exports.handle = (command, parser) => {
    if (command !== "build") return;

    checkConfigFile(parser);

    const project = (parser.values[1]?.replace(/[/\\]|(\.\.)/g, "")) || "sussyspt";
    console.log(`Building project '${project}'`);

    const srcDir = `${normalizePath(_path.resolve("src/"))}/`;

    const projectScriptPath = `${srcDir}${project}.project.js`;
    const projectScript = fs.existsSync(projectScriptPath) ? require(projectScriptPath) : {};

    if (projectScript.configure)
        projectScript.configure(parser);


    const srcProjectDir = `${srcDir}${project}/`;
    if (!fs.existsSync(srcProjectDir)) {
        console.log(`Project '${project}' not found!`);
        return true;
    }

    const mainFile = `${srcProjectDir}${projectScript.mainFileBase ? projectScript.mainFileBase() : "main.lua"}`;
    if (!fs.existsSync(mainFile)) {
        console.log(`Project '${project}' not found!`);
        return true;
    }


    const buildDir = `${normalizePath(_path.resolve("build/"))}/`;
    const projectBuildDir = `${buildDir}${project}/`;
    ensureFolderCreated(projectBuildDir);

    let out;

    const packedFile = `${projectBuildDir}packed`;
    console.log("\n> Packing...");
    try {
        out = pack(srcDir, srcProjectDir, mainFile, packedFile, projectScript.mapPack, projectScript.ext ? projectScript.ext() : ".lua");
    } catch (err) {
        console.info(`> An error occured while packing files:\n${err}`);
        return true;
    }
    console.log("> Packed!");

    if (projectScript.mapPackPost) {
        out = projectScript.mapPackPost(out) || out;
    }

    const libsDir = `${buildDir}libs/`;
    ensureFolderCreated(libsDir);

    fs.writeFileSync(`${libsDir}${projectScript.outName ? projectScript.outName() : `${project}.lua`}`, out);

    if (projectScript.finish) {
        projectScript.finish(out);
    }

    console.log("\nBUILD SUCCESS!");

    return true;
};
