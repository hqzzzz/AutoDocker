FROM  php:8.0.26-fpm
LABEL org.opencontainers.image.authors="yang.linhao@Hotmail.com"

COPY . /usr/src/sspanel

VOLUME [ "/var/www" ]

WORKDIR /usr/src/sspanel/SSPanel-Uim

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl libzip-dev git supervisor vim nginx cron ca-certificates mariadb-client && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/cache/apt/* && \
    docker-php-ext-install zip pdo pdo_mysql opcache mysqli bcmath && \
    cp config/.config.example.php config/.config.php && \
    mv config/appprofile.example.php config/appprofile.php && \
    mv ../supervisord.conf /etc/supervisor/ && \
    mv ../sites.conf /etc/nginx/sites-enabled/default && \
    mv ../docker-entrypoint.sh /usr/local/bin/ && \
    mkdir -p /var/www/html && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chmod -R 755 storage && \
    chmod -R 777 storage/framework/smarty/compile/ && \
    mv db/migrations/20000101000000_init_database.php.new db/migrations/20000101000000_init_database.php && \
    curl -SL https://getcomposer.org/installer -o composer.phar && \
    php composer.phar && \
    php composer.phar config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true && \
    php composer.phar install && \
    php xcat ClientDownload && \
    crontab -l | { cat; echo "30 23 * * * php /var/www/xcat SendDiaryMail"; } | crontab - && \
    crontab -l | { cat; echo "0 0 * * * php /var/www/xcat Job DailyJob"; } | crontab - && \
    crontab -l | { cat; echo "*/1 * * * * php /var/www/xcat Job CheckJob"; } | crontab - && \
    crontab -l | { cat; echo "0 */1 * * * php /var/www/xcat Job UserJob"; } | crontab - && \
    { \
        echo '[program:crond]'; \
        echo 'command=cron -f'; \
        echo 'autostart=true'; \
        echo 'autorestart=true'; \
        echo 'killasgroup=true'; \
        echo 'stopasgroup=true'; \
    } | tee /etc/supervisor/crond.conf



WORKDIR /var/www/html
EXPOSE 80
#CMD["/usr/bin/supervisord"]
ENTRYPOINT ["docker-entrypoint.sh"]

