// This tool is for converting GtaHax stats files to text that can be used in Online->Stats->Loader
// If you encounter a problem, feel free to make an issue.
// Usage: node /path/to/GtaHaxStatsConverter.js /path/to/my/file.txt [/path/to/output/file.txt]

const fs = require("fs");

function convertFile(file, outFile) {
    const data = fs.readFileSync(file, "utf8");
    const lines = data.split("\n");

    let output = "";

    let stat = null;

    for (let line of lines) {
        line = line.trim();

        if (line.startsWith("$")) {
            stat = line.substring(1).replace(/MP[01x]/gi, "MPX");
            continue;
        } else if (stat === null) {
            console.info(`Skipped line '${line}'`);
            continue;
        }

        const value = line.toLowerCase();

        let type;

        if (value === "true" || value === "false") {
            type = "bool";
        } else if (isNaN(value)) {
            console.info(`Unknown type for line '${line}'`);
            continue;
        } else {
            const numValue = Number(value);
            if (numValue <= 2147483647 && numValue >= -2147483647) {
                type = numValue % 1 === 0 ? "int" : "float";
            }
        }

        const out = `${type} ${stat} ${value}`;
        console.log(`Wrote '${out}'`);
        output += `${out}\n`;

        stat = null;
    }

    output = `# Converted ${lines.length} line/s :D\n${output}`;

    if (!outFile) {
        outFile = `${file}_converted.txt`;
    }
    fs.writeFileSync(outFile, output);
}

const inputFilePath = process.argv[2];
if (inputFilePath) {
    convertFile(inputFilePath, process.argv[3]);
} else {
    console.log("Please provide the input file path.");
}
