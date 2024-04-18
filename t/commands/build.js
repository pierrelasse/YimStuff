
const fs = require("fs");
const _path = require("path");

const argParser = require("../util/argParser");


const ensureFolderCreated = (folderPath) => { if (!fs.existsSync(folderPath)) fs.mkdirSync(folderPath, { recursive: true }); };

const normalizePath = (path) => _path.normalize(path).replace(/\\/g, "/");

function pack(srcDir, entryFile, outFile, callback, ext) {
    const modules = [];
    let moduleCounter = 0;
    const requireMapping = {};

    if (!require.extensions[ext]) require.extensions[ext] = function (module, filename) { };

    function packFile(path) {
        const moduleId = moduleCounter;

        let fileContent = fs.readFileSync(path).toString()
            .trim()
            .replace(/require\(["'](.+?)["']\)/g, (match, modulePath) => {
                if (!modulePath.startsWith(".")) {
                    return `require("${modulePath}")`;
                }
                const resolved = normalizePath(require.resolve(modulePath, { paths: [srcDir, _path.dirname(path)] }));
                if (!requireMapping.hasOwnProperty(resolved)) {
                    requireMapping[resolved] = ++moduleCounter;
                    packFile(resolved);
                }
                return `require(${requireMapping[resolved]})`;
            });

        const relPath = path.replace(srcDir, "");

        if (callback !== undefined) {
            fileContent = callback(fileContent, { path, relPath }) || fileContent;
        }

        const moduleContent = fileContent
            .split("\n")
            .filter(v => v.trimStart().length !== 0)
            .join("\n            ");
        modules.push(`[${moduleId}] = function(exports, require) --[[ ${relPath} ]]\n            ${moduleContent}\n        end`);
    }

    requireMapping[entryFile] = moduleCounter;
    packFile(entryFile);

    const out = `do
    local modules = {
        ${modules.join(",\n        ")}
    }
    local cache = {}

    local function mrequire(path)
        local val = cache[path]
        if val ~= nil then return val.exports end
        local module = {exports = {}}
        cache[path] = module
        local success, result = pcall(modules[path], module.exports, mrequire)
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

module.exports.handle = (command, args) => {
    if (command !== "build") return;

    const parser = new argParser.ArgParser();
    parser.parse(process.argv.slice(3));

    checkConfigFile(parser);

    const project = (parser.values[0]?.replace(/[/\\]|(\.\.)/g, "")) || "sussyspt";
    console.log(`Building project '${project}'`);

    const srcDir = `${normalizePath(_path.resolve(`src/`))}/`;

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


    const buildDir = `${normalizePath(_path.resolve(`build/`))}/`;
    const projectBuildDir = `${buildDir}${project}/`;
    ensureFolderCreated(projectBuildDir);

    const packedFile = `${projectBuildDir}packed`;
    console.log("\n> Packing...");
    let out = pack(srcProjectDir, mainFile, packedFile, projectScript.mapPack, projectScript.ext ? projectScript.ext() : ".lua");
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

    console.log("\nBUILD DONE!");

    return true;
};
