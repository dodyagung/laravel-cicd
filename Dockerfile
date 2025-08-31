############################################
# Base Image
############################################
FROM serversideup/php:8.4-fpm-nginx-alpine AS base 

ENV TZ=Asia/Jakarta
ENV PHP_DATE_TIMEZONE=$TZ
USER root
RUN docker-php-serversideup-dep-install-alpine tz
USER www-data

############################################
# Dependency Image
############################################
FROM base AS dependency

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --classmap-authoritative

############################################
# Builder Image
############################################
FROM base AS builder

COPY --from=dependency /var/www/html/vendor ./vendor
COPY . .

############################################
# Development Image
############################################
FROM base AS development

USER root
ARG USER_ID
ARG GROUP_ID
RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx
USER www-data

############################################
# Production Image
############################################
FROM base AS production

ENV PHP_OPCACHE_ENABLE=1 \
    AUTORUN_ENABLED=true
COPY --chown=www-data:www-data --from=builder /var/www/html .