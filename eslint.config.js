
const globals = require("globals");

const WARN = 1;

module.exports = [
    {
        files: ["**/*.js"],

        languageOptions: {
            ecmaVersion: 2022,
            sourceType: "module",
            globals: { ...globals.es2021, ...globals.node }
        },

        rules: {
            // === Possible Problems ===
            "no-dupe-args": WARN,
            "no-dupe-class-members": WARN,
            "no-dupe-else-if": WARN,
            "no-dupe-keys": WARN,
            "no-duplicate-imports": WARN,
            "no-invalid-regexp": WARN,
            "no-loss-of-precision": WARN,
            "no-promise-executor-return": WARN,
            "no-self-assign": [WARN, { "props": false }],
            "no-self-compare": WARN,
            "no-undef": WARN,
            "no-unexpected-multiline": WARN,
            // "no-unreachable": WARN,
            "no-unreachable-loop": [WARN, { "ignore": ["ForStatement", "ForInStatement", "ForOfStatement"] }],
            "no-unsafe-negation": WARN,
            "no-unsafe-optional-chaining": WARN,
            "no-unused-vars": [WARN, {
                "varsIgnorePattern": "^",
                "args": "after-used",
                "argsIgnorePattern": "_",
                "caughtErrors": "all",
                "caughtErrorsIgnorePattern": "ignored",
                "destructuredArrayIgnorePattern": "^_",
                "ignoreRestSiblings": true
            }],
            "no-useless-backreference": WARN,
            "require-atomic-updates": WARN,
            "use-isnan": WARN,
            "valid-typeof": WARN,

            // === Suggestions ===
            "default-case-last": WARN,
            "dot-notation": WARN,
            "eqeqeq": WARN,
            // "func-style": WARN,
            "max-depth": [WARN, { "max": 7 }],
            "max-nested-callbacks": WARN,
            "max-params": [WARN, { "max": 7 }],
            "no-empty-static-block": WARN,
            "no-extra-label": WARN,
            "no-invalid-this": WARN,
            "no-label-var": WARN,
            "no-lonely-if": WARN,
            // "no-multi-assign": WARN,
            "no-multi-str": WARN,
            "no-negated-condition": WARN,
            // "no-nested-ternary": WARN,
            "no-new-wrappers": WARN,
            "no-nonoctal-decimal-escape": WARN,
            "no-octal": WARN,
            "no-octal-escape": WARN,
            // "no-param-reassign": WARN,
            "no-redeclare": WARN,
            "no-regex-spaces": WARN,
            "no-return-assign": WARN,
            "no-sequences": WARN,
            // "no-throw-literal": WARN,
            "no-unneeded-ternary": WARN,
            // "no-undef-init": WARN,
            "no-unused-expressions": WARN,
            "no-unused-labels": WARN,
            "no-useless-call": WARN,
            "no-useless-catch": WARN,
            "no-useless-computed-key": WARN,
            "no-useless-concat": WARN,
            "no-useless-constructor": WARN,
            "no-useless-escape": WARN,
            "no-useless-return": WARN,
            "no-var": WARN,
            "no-void": WARN,
            "object-shorthand": WARN,
            "prefer-arrow-callback": WARN,
            "prefer-const": WARN,
            "prefer-destructuring": [WARN, { "array": false }],
            "prefer-exponentiation-operator": WARN,
            // "prefer-named-capture-group": WARN,
            "prefer-numeric-literals": WARN,
            "prefer-object-has-own": WARN,
            "prefer-object-spread": WARN,
            "prefer-regex-literals": WARN,
            // "prefer-rest-params": WARN,
            "prefer-spread": WARN,
            "prefer-template": WARN,
            "radix": WARN,
            "require-await": WARN,
            // "require-unicode-regexp": WARN,
            "require-yield": WARN,
            "sort-vars": WARN,

            // === Deprecated ===
            "quotes": [WARN, "double"],
            "semi": [WARN, "always"],
            "no-multi-spaces": [WARN, { "exceptions": { "VariableDeclarator": true } }],
            "no-multiple-empty-lines": [WARN, { "max": 2 }],
        }
    }
];
