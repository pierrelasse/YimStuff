
const argParser = require("./util/argParser");


const commands = [
    require("./commands/build"),
    require("./commands/clean"),
    require("./commands/installminify")
];


async function main() {
    const parser = new argParser.ArgParser();
    parser.parseArgv();

    const command = parser.values[0];
    if (command !== undefined) {
        for (const cmd of commands) {
            const handler = cmd.handle;
            if (await handler(command, parser) == true)
                return;
        }
    }

    // Well done nodejs. My code looks very clean and awesome with this multiline string
    console.log(`Running t@v1.1.0
${command === undefined ? "" : "\nCommand not found."}
Available commands:
    build, clean, installminify

Usage: ./t.sh <command>`);
}

main();
