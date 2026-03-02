<?php
$file = '/var/www/html/lib/pkp/classes/core/PKPApplication.php';
$content = file_get_contents($file);
$content = preg_replace(
    '/public static function isInstalled\(\).*?\{.*?return[^}]+\}/s',
    'public static function isInstalled(): bool { return false; }',
    $content
);
file_put_contents($file, $content);
echo "isInstalled patched\n";
