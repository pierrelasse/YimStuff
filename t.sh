
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js is not installed. Please install Node.js to continue."
    echo "Download page: https://nodejs.org/en/download"
    exit 1
fi

node t/index.js "$@"
