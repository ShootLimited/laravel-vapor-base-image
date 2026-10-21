#!/bin/sh
set -eu

apk add --no-cache --virtual .php-security-build-deps \
    $PHPIZE_DEPS \
    argon2-dev \
    curl-dev \
    gnu-libiconv-dev \
    libsodium-dev \
    readline-dev \
    sqlite-dev

docker-php-source delete
curl --fail --show-error --location "$PHP_URL" --output /usr/src/php.tar.xz
echo "$PHP_SHA256  /usr/src/php.tar.xz" | sha256sum -c -
docker-php-source extract

# Match the official PHP Alpine build: use GNU iconv rather than musl's header.
rm -f /usr/include/iconv.h

export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"
cd /usr/src/php
./configure \
    --build=x86_64-linux-musl \
    --with-config-file-path=/usr/local/etc/php \
    --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
    --enable-option-checking=fatal \
    --with-mhash \
    --with-pic \
    --enable-mbstring \
    --enable-mysqlnd \
    --with-password-argon2 \
    --with-sodium=shared \
    --with-pdo-sqlite=/usr \
    --with-sqlite3=/usr \
    --with-curl \
    --with-iconv=/usr \
    --with-openssl \
    --with-readline \
    --with-zlib \
    --disable-phpdbg \
    --with-pear \
    --disable-cgi \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data

make -j4
make install

docker-php-ext-configure gd --with-freetype=/usr/lib/ --with-jpeg=/usr/lib/
docker-php-ext-install -j4 \
    bcmath gd gettext intl mysqli opcache pcntl pdo_mysql pdo_pgsql \
    soap sockets xsl zip

cd /
docker-php-source delete
apk del .php-security-build-deps
php -r 'if (PHP_VERSION !== "8.2.35") { fwrite(STDERR, "Patched PHP was not installed.\n"); exit(1); }'
