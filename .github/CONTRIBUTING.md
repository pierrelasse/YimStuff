# Contributing to YimStuff

Thank you for your interest in contributing to this repository!
We appreciate your help in making this project better.

You can contribute to YimStuff in several ways:

- [Creating Issues](#creating-issues)
- [Pull Requests](#pull-requests)
- [Contacting](#contacting)

## Creating Issues

If you encounter a bug, or have a feature request, please feel free to create an [issue](https://github.com/pierrelasse/YimStuff/issues/new/choose).

## Pull Requests

If you would like to contribute code, you can do so by creating a pull request (PR). Here's how you can get started:

1. Fork the repository to your GitHub account.
2. (Optionally) Create a new branch for your changes.
3. Make your changes, and try following the project's coding style.
4. Test your changes to ensure they work as expected.
5. Create a pull request.

Please provide a clear and concise description of your pull request, explaining what it does and why it's necessary. We will review your contribution and provide feedback if needed.

## Contacting

If you have questions, need clarifications, or want to discuss anything privately, you can contact me on Discord (`dcistdreck`).


# Lua Coding Standards
By following these guidelines, you can help maintain code consistency and quality within the project.

## Naming Style
- Global Variable: `thisIsAVariable`
- Local Variable: `thisIsAVariable`
- Global Function: `thisIsAFunction`
- Local Function: `thisIsAFunction`
- Yimutils API Function: `this_is_a_function`

## Formatting Style

### Indents
Use 4 spaces for indentation in your Lua code.

```lua
function exampleFunction()
    if condition then
        -- Four spaces of indentation
        print("Indented text")
    end
end
```

### Merging Strings
When concatenating strings using the `..` operator, avoid spaces before and after it to save space and maintain a clean code appearance:

```lua
local concatenatedString = "string1".."string2"
```

# Your own version
If you want to make changes to yimutils.lua, just go ahead.

After making changes to SussySpt.lua, you need to run `t update` to have it updated.
