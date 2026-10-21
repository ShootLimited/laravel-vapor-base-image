<?php

if (PHP_VERSION !== '8.2.35') {
    throw new RuntimeException('The runtime must use patched PHP 8.2.35.');
}

$required = [
    'bcmath', 'ctype', 'curl', 'dom', 'fileinfo', 'gd', 'gettext', 'iconv',
    'imagick', 'intl', 'mbstring', 'mysqli', 'openssl', 'pcntl', 'pdo_mysql',
    'pdo_pgsql', 'pdo_sqlite', 'redis', 'soap', 'sockets', 'sodium', 'tokenizer',
    'xml', 'xsl', 'zip', 'Zend OPcache',
];

foreach ($required as $extension) {
    if (!extension_loaded($extension)) {
        throw new RuntimeException('Missing required extension: '.$extension);
    }
}

$image = new Imagick();
$image->newImage(20, 10, new ImagickPixel('transparent'));
$image->setImageFormat('png');
$image->thumbnailImage(10, 5);
$decoded = new Imagick();
$decoded->readImageBlob($image->getImageBlob());

if ($decoded->getImageWidth() !== 10 || $decoded->getImageHeight() !== 5) {
    throw new RuntimeException('Imagick must resize and encode PNG images.');
}

$database = new PDO('sqlite::memory:');
if ((int) $database->query('SELECT 42')->fetchColumn() !== 42) {
    throw new RuntimeException('PDO must execute queries.');
}

echo 'PHP '.PHP_VERSION.': extensions, PNG processing and PDO passed.'.PHP_EOL;
