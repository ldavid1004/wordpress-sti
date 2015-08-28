# FROM ip-172-31-27-60.us-west-2.compute.internal:5000/wordpress
FROM wordpress

MAINTAINER lysander_david@symantec.com

# Location of the STI scripts inside the image
#
LABEL io.k8s.description="Platform for building and running Wordpress applications" \
      io.k8s.display-name="Wordpress on Apache 2.4 with PHP 5.6" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,php,php56,rh-php56 \
      io.openshift.s2i.scripts-url=image:///usr/local/sti

# The $HOME is not set by default, but some applications needs this variable
ENV HOME=/opt/app-root/src \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sti:$PATH \
    WORDPRESS_VERSION=4.3 \
    WORDPRESS_SHA1=1e9046b584d4eaebac9e1f7292ca7003bfc8ffd7

RUN groupadd -r default -f -g 1001 && \
    useradd -u 1001 -r -g default -d ${HOME} -s /sbin/nologin \
      -c "Default Application User" default && \
    chown -R 1001:1001 /var/www/html && \
    chown -R 1001:1001 /usr/src/wordpress

# copy config
COPY ./etc/apache2/apache2.conf /etc/apache2/apache2.conf

# Copy the STI scripts from the specific language image to /usr/local/sti
COPY ./.sti/bin/ /usr/local/sti

USER 1001

# Set the default CMD to print the usage of the language image
CMD ["usage"]
