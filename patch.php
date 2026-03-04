<?php
$file = '/var/www/html/lib/pkp/classes/core/PKPApplication.php';
$content = file_get_contents($file);
$content = preg_replace(
    '/public static function isInstalled\(\): bool \{ return false; \}/',
    'public static function isInstalled(): bool { return (bool) Config::getVar(\'general\', \'installed\'); }',
    $content
);
file_put_contents($file, $content);
echo "isInstalled patched to read from config\n";
