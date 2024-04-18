
function getCommands() {
    return [
        require("./commands/build"),
        require("./commands/clean"),
    ];
}


function main(argv) {
    const commands = getCommands();

    if (argv[0]) {
        for (const i of commands) {
            const handler = i.handle;
            if (handler(argv[0]) == true)
                return;
        }
    }

    // Well done nodejs. My code looks very clean and awesome with this multiline string
    console.log(`Running t@v1.0.0
${argv[0] ? "Command not found.\n" : ""}
Available commands:
    build, clean

Usage: ./t.sh <command>`);
}

main(process.argv.slice(2));
