FROM surnet/alpine-wkhtmltopdf:3.20.2-0.12.6-full AS wkhtmltopdf

FROM laravelphp/vapor:php82

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
