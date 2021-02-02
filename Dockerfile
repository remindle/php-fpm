FROM php:7.4-fpm

RUN apt-get update

# Install dependencies
RUN apt-get install -y \
  libzip-dev \
  zip \
  libcurl3-dev \
  curl \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  imagemagick \
  --no-install-recommends libmagickwand-dev \
  zlib1g-dev \
  libicu-dev \
  g++ \
  libssl-dev

# Install PECL and PEAR extensions
RUN pecl install \
  redis \
  imagick

# Enable PECL and PEAR extensions
RUN docker-php-ext-enable \
  redis \
  imagick

# Configure php extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure intl
RUN docker-php-ext-configure zip

# Install php extensions
RUN docker-php-ext-install \
  bcmath \
  calendar \
  curl \
  exif \
  gd \
  iconv \
  intl \
  mysqli \
  pdo \
  pdo_mysql \
  pcntl \
  sockets \
  tokenizer \
  xml \
  zip

# Cleanup dev dependencies
RUN apt-get clean
RUN apt-get -y autoremove

# OPcache defaults
ENV PHP_OPCACHE_ENABLE="1"
ENV PHP_OPCACHE_MEMORY_CONSUMPTION="128"
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES="10000"
ENV PHP_OPCACHE_REVALIDATE_FREQUENCY="0"
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"

# Add opcache configuration file
RUN docker-php-ext-install opcache
ADD opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"

# PHP-FPM defaults
ENV PHP_FPM_PM="dynamic"
ENV PHP_FPM_MAX_CHILDREN="5"
ENV PHP_FPM_START_SERVERS="2"
ENV PHP_FPM_MIN_SPARE_SERVERS="1"
ENV PHP_FPM_MAX_SPARE_SERVERS="2"
ENV PHP_FPM_MAX_REQUESTS="1000"

# Copy the PHP-FPM configuration file
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

RUN chown -R www-data:www-data .
