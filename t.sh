
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js is not installed. Please install Node.js to continue."
    echo "Official page: https://nodejs.org/"
    echo "Ask chatgpt on how to install it on your system smth"
    exit 1
fi

node t/index.js "$@"
