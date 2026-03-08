<?php
// Fix isInstalled
$file = '/var/www/html/lib/pkp/classes/core/PKPApplication.php';
$content = file_get_contents($file);
$content = preg_replace(
    '/public static function isInstalled\(\): bool \{ return false; \}/',
    'public static function isInstalled(): bool { return (bool) Config::getVar(\'general\', \'installed\'); }',
    $content
);
file_put_contents($file, $content);
echo "isInstalled patched\n";

// Fix PubObjectsExportPlugin
$file2 = '/var/www/html/classes/plugins/PubObjectsExportPlugin.php';
$content2 = file_get_contents($file2);
$content2 = preg_replace(
    '/public function registerSchedules\s*\(.*?\)\s*\{.*?\}/s',
    'public function registerSchedules($scheduler) {}',
    $content2
);
file_put_contents($file2, $content2);
echo "PubObjectsExportPlugin patched\n";
