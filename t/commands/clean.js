
const fs = require("fs");
const _path = require("path");


function deleteDirectoryRecursive(dirPath) {
    if (fs.existsSync(dirPath)) {
        fs.readdirSync(dirPath).forEach(file => {
            const curPath = _path.join(dirPath, file);
            if (fs.lstatSync(curPath).isDirectory()) {
                deleteDirectoryRecursive(curPath);
            } else {
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(dirPath);
    }
}

module.exports.handle = (command) => {
    if (command !== "clean") return;

    console.log("> Cleaning...");

    const buildDir = "build/";
    if (fs.existsSync(buildDir)) {
        console.log(">   Deleting build");
        deleteDirectoryRecursive(buildDir);
    }

    console.log("> Cleaned!");

    return true;
};
