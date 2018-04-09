$port = $args[0]

if ($port) {
    python -m http.server $port
} else {
    python -m http.server 5000
}