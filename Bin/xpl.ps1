$path = $args[0]

if ($path) {
    explorer $path
} else {
    explorer ($pwd.ProviderPath)
}
