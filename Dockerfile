FROM php:5.6-apache

LABEL io.k8s.description="Platform for building and running Wordpress applications" \
      io.k8s.display-name="Wordpress on Apache 2.4 with PHP 5.6" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,php,php56,rh-php56" \
      io.openshift.s2i.scripts-url="image:///usr/local/sti" \
      io.s2i.scripts-url="image:///usr/local/sti"

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd
RUN docker-php-ext-install mysqli

# VOLUME /var/www/html

# The $HOME is not set by default, but some applications needs this variable
ENV HOME=/opt/app-root/src \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sti:$PATH \
    WORDPRESS_VERSION=4.3 \
    WORDPRESS_SHA1=1e9046b584d4eaebac9e1f7292ca7003bfc8ffd7

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz \
    && chmod -R a+rw /usr/src/wordpress \
    && find /usr/src/wordpress -type d -exec chmod a+x {} \; \
    && mkdir -p /var/www/html \
    && chmod -R a+rw /var/www/html \
    && find /var/www/html -type d -exec chmod a+x {} \; \
    && chmod a+rw /tmp \
    && chmod -R a+rw / || true

#    && chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh
COPY etc/apache2/envvars /etc/apache2/envvars

# copy config
COPY ./etc/apache2/apache2.conf /etc/apache2/apache2.conf

# Copy the STI scripts from the specific language image to /usr/local/sti
COPY ./.sti/bin/ /usr/local/sti

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
# CMD ["apache2-foreground"]
CMD ["usage"]
LABEL io.openshift.builder-version="2976f63"
LABEL io.openshift.builder-base-version="c7358a4"
