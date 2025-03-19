FROM php:8.3-apache

ENV PNPM_HOME="/var/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Panther configuration
ENV PANTHER_NO_SANDBOX 1
ENV PANTHER_CHROME_ARGUMENTS='--disable-dev-shm-usage --ignore-certificate-errors'

# Suppress Apache warning about ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Create default VirtualHost
COPY "./docker/vhost.conf" "/etc/apache2/sites-enabled/000-default.conf"

# Override some php.ini configuration for our needs
RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
COPY "./docker/php.ini" "/usr/local/etc/php/conf.d/php-overrides.ini"

# Generate fake .gitconfig file
RUN printf "[user]\n\tname = example\n\temail = example@example.com\n" > /etc/gitconfig

# Install tool to manage PHP extensions as official Docker images
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install required PHP extensions
RUN chmod +x /usr/local/bin/install-php-extensions; \
    install-php-extensions intl zip pdo_pgsql pgsql bcmath xsl gd opcache @composer;

# Install laravel installer
RUN composer global require laravel/installer;

# Enable mod_rewrite module for Apache
RUN a2enmod rewrite

# Install latest stable node version
RUN curl -fsSL https://deb.nodesource.com/setup_23.x | bash -; \
    apt-get install -y nodejs; \
    npm install -g corepack@latest; \
    corepack enable pnpm --activate; \
    pnpm self-update; \
    pnpm add -g npm-check-updates;

# Set working directory
WORKDIR /var/www/html/
