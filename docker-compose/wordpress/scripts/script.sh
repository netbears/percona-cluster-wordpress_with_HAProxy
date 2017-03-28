#!/bin/bash
cat <<EOF > /opt/add-memcache.php
$memcached_servers = array(
	'default' => array(
		'mem1:11211',
		'mem2:11211'
	)
);
EOF
