FROM surnet/alpine-wkhtmltopdf:3.20.2-0.12.6-full AS wkhtmltopdf

FROM laravelphp/vapor:php82

ENV PHP_VERSION=8.2.35 \
    PHP_URL=https://www.php.net/distributions/php-8.2.35.tar.xz \
    PHP_ASC_URL=https://www.php.net/distributions/php-8.2.35.tar.xz.asc \
    PHP_SHA256=5737b98601fe5ab1b8c5db0c82ed3158acb9283ed3081ffe2faffb9ac81455e6

# Rebuild PHP while the published Vapor image still contains an older release.
COPY build-php.sh /tmp/build-php.sh
RUN sh /tmp/build-php.sh && rm /tmp/build-php.sh

# Install runtime dependencies required for wkhtmltopdf and Imagick
RUN apk add --no-cache \
    libstdc++ \
    libx11 \
    libxrender \
    libxext \
    libssl3 \
    ca-certificates \
    fontconfig \
    freetype \
    ttf-dejavu \
    ttf-droid \
    ttf-freefont \
    ttf-liberation \
    imagemagick

# Install build dependencies for Imagick and fonts
RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    gcc \
    g++ \
    make \
    pkgconfig \
    imagemagick-dev \
    php82-dev \
    libtool \
    file \
    pkgconf \
    msttcorefonts-installer

# Install Microsoft fonts
RUN update-ms-fonts && fc-cache -f

# Install Imagick via PECL and enable it
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Clean up
RUN apk del .build-deps \
    && rm -rf /tmp/*

# Copy wkhtmltopdf files from the wkhtmltopdf image
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmltoimage /bin/wkhtmltoimage
COPY --from=wkhtmltopdf /bin/libwkhtmltox* /bin/

COPY tests/runtime.php /tmp/verify-runtime.php
RUN php /tmp/verify-runtime.php \
    && php-fpm -t \
    && wkhtmltopdf --version \
    && rm /tmp/verify-runtime.php
