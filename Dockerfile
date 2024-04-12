FROM surnet/alpine-wkhtmltopdf:3.19.1-0.12.6-full as wkhtmltopdf

FROM laravelphp/vapor:php81

RUN apk add --no-cache libstdc++
RUN apk add --no-cache libx11
RUN apk add --no-cache libxrender
RUN apk add --no-cache libxext
RUN apk add --no-cache libssl3
RUN apk add --no-cache ca-certificates
RUN apk add --no-cache fontconfig
RUN apk add --no-cache freetype
RUN apk add --no-cache ttf-dejavu
RUN apk add --no-cache ttf-droid
RUN apk add --no-cache ttf-freefont
RUN apk add --no-cache ttf-liberation
RUN apk add --no-cache imagemagick
RUN apk add --no-cache imagemagick-dev

RUN apk add --no-cache --virtual .build-deps msttcorefonts-installer
RUN update-ms-fonts
RUN fc-cache -f

RUN rm -rf /tmp/*
RUN apk del .build-deps

COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmltoimage /bin/wkhtmltoimage
COPY --from=wkhtmltopdf /bin/libwkhtmltox* /bin/

RUN pecl install -o -f imagick
RUN docker-php-ext-enable imagick