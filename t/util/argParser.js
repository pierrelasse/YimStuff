
class ArgParser {
    /** @type {Object<string, string|undefined>} */
    shortArgs;
    /** @type {Object<string, string|undefined>} */
    longArgs;
    /** @type {string[]} */
    values;

    constructor() {
        this.shortArgs = {};
        this.longArgs = {};
        this.values = [];
    }

    /**
     *
     * @param {string[]} argList
     */
    parse(argList) {
        for (let i = 0; i < argList.length; i++) {
            const arg = argList[i];
            if (arg.startsWith("-")) {
                const isLong = arg.startsWith("--");
                const [key, value] = arg.slice(isLong ? 2 : 1).split("=", 2);
                if (isLong) {
                    this.longArgs[key] = value;
                } else {
                    this.shortArgs[key] = value;
                }
            } else {
                this.values.push(arg);
            }
        }
    }

    parseArgv(slice = 2) {
        this.parse(process.argv.slice(slice));
    }

    parseString(args) {
        this.parse(args.match(/(?:[^\s"']+|"[^"]*"|'[^']*')+/g));
    }

    /**
     *
     * @param {string} shortKey
     * @param {string} longKey
     * @returns {boolean}
     */
    has(shortKey, longKey) {
        return this.hasShort(shortKey) || this.hasLong(longKey);
    }

    /**
     *
     * @param {string} shortKey
     * @returns {boolean}
     */
    hasShort(shortKey) {
        return this.shortArgs.hasOwnProperty(shortKey);
    }

    /**
     *
     * @param {string} longKey
     * @returns {boolean}
     */
    hasLong(longKey) {
        return this.longArgs.hasOwnProperty(longKey);
    }

    /**
     *
     * @param {string} shortKey
     * @param {string} longKey
     * @returns {string|undefined}
     */
    get(shortKey, longKey) {
        return this.getShort(shortKey) || this.getLong(longKey);
    }

    /**
     *
     * @param {string} shortKey
     * @returns {string|undefined}
     */
    getShort(shortKey) {
        return this.shortArgs[shortKey];
    }

    /**
     *
     * @param {string} longKey
     * @returns {string|undefined}
     */
    getLong(longKey) {
        return this.longArgs[longKey];
    }
}

module.exports = {
    ArgParser
};
