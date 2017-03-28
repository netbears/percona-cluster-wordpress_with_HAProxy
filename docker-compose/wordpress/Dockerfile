FROM wordpress
ADD  https://raw.githubusercontent.com/Automattic/wp-memcached/master/object-cache.php /var/www/html/object-cache.php
RUN  echo "require_once(ABSPATH . 'add-memcache.php');" >> /var/www/html/wp-config.php
RUN  echo "$memcached_servers = array('default' => array('mem1:11211','mem2:11211'));" > /var/www/html/add-memcache.php