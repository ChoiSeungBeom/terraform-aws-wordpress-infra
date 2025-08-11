#!/bin/bash

# 패키지 업데이트/설치
apt update -y
apt install -y nginx php php-fpm php-mysql mariadb-client wget unzip

systemctl enable nginx
systemctl start nginx
systemctl enable php8.1-fpm
systemctl start php8.1-fpm

# 워드프레스 설치
cd /var/www/html
rm -f index.html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# 권한 설정
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# DB 설정
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${db_name}/" wp-config.php
sed -i "s/username_here/${db_user}/" wp-config.php
sed -i "s/password_here/${db_password}/" wp-config.php
sed -i "s/localhost/${db_endpoint}/" wp-config.php

# HTTPS 프록시 인지 + 사이트 주소 고정
WP_MARK_BEGIN="# >>> WP_PROXY_HTTPS_BEGIN"
if ! grep -q "$WP_MARK_BEGIN" wp-config.php; then
  LINE=$(grep -n "define( *'ABSPATH'" wp-config.php | head -n1 | cut -d: -f1)
  TMP=$(mktemp)
  if [ -n "$LINE" ]; then
    # ABSPATH 앞에 블록 삽입
    head -n $((LINE-1)) wp-config.php > "$TMP"
    cat >> "$TMP" <<'PHP'
# >>> WP_PROXY_HTTPS_BEGIN
if (!empty($_SERVER['HTTP_CLOUDFRONT_FORWARDED_PROTO']) && $_SERVER['HTTP_CLOUDFRONT_FORWARDED_PROTO'] === 'https') { $_SERVER['HTTPS'] = 'on'; }
if (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') { $_SERVER['HTTPS'] = 'on'; }
if (!defined('FORCE_SSL_ADMIN')) { define('FORCE_SSL_ADMIN', true); }
if (!defined('WP_HOME'))    { define('WP_HOME',    'https://__WP_DOMAIN__'); }
if (!defined('WP_SITEURL')) { define('WP_SITEURL', 'https://__WP_DOMAIN__'); }
# <<< WP_PROXY_HTTPS_END
PHP
    tail -n +"$LINE" wp-config.php >> "$TMP"
    sed -i "s#__WP_DOMAIN__#${domain}#g" "$TMP"
    cp "$TMP" wp-config.php && rm -f "$TMP"
  else
    cat >> wp-config.php <<'PHP'
# >>> WP_PROXY_HTTPS_BEGIN
if (!empty($_SERVER['HTTP_CLOUDFRONT_FORWARDED_PROTO']) && $_SERVER['HTTP_CLOUDFRONT_FORWARDED_PROTO'] === 'https') { $_SERVER['HTTPS'] = 'on'; }
if (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') { $_SERVER['HTTPS'] = 'on'; }
if (!defined('FORCE_SSL_ADMIN')) { define('FORCE_SSL_ADMIN', true); }
if (!defined('WP_HOME'))    { define('WP_HOME',    'https://__WP_DOMAIN__'); }
if (!defined('WP_SITEURL')) { define('WP_SITEURL', 'https://__WP_DOMAIN__'); }
# <<< WP_PROXY_HTTPS_END
PHP
    sed -i "s#__WP_DOMAIN__#${domain}#g" wp-config.php
  fi
fi

# nginx 서버블록 (프록시 HTTPS 헤더 전달)
cat > /etc/nginx/sites-available/default <<'EOF'
map $http_cloudfront_forwarded_proto $cf_https { default off; https on; }
map $http_x_forwarded_proto           $xfp_https { default $cf_https; https on; }

server {
    listen 80;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name _;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_param HTTPS $xfp_https;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# nginx 재시작
systemctl restart nginx

# 완료 로그 생성
echo "UserData completed"
