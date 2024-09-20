FROM surnet/alpine-wkhtmltopdf:3.20.2-0.12.6-full AS wkhtmltopdf

FROM laravelphp/vapor:php82

# Install dependencies and build tools
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
  imagemagick \
  imagemagick-dev \
  php82-dev \
  php82-pear \
  gcc \
  g++ \
  make \
  autoconf \
&& apk add --no-cache --virtual .build-deps \
  msttcorefonts-installer \
\
# Install Microsoft fonts
&& update-ms-fonts \
&& fc-cache -f \
\
# Install Imagick via PECL
&& pecl install imagick \
&& echo "extension=imagick.so" > /etc/php82/conf.d/00_imagick.ini \
\
# Clean up when done
&& rm -rf /tmp/* \
&& apk del .build-deps \
&& apk del php82-dev php82-pear gcc g++ make autoconf

# Copy wkhtmltopdf files from docker-wkhtmltopdf image
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmltoimage /bin/wkhtmltoimage
COPY --from=wkhtmltopdf /bin/libwkhtmltox* /bin/
