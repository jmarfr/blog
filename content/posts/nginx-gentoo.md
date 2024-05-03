+++
title = 'Installation de Nginx sur Gentoo'
date = 2012-02-27T17:13:18+02:00
draft = false
+++

## Installation de Nginx

Nginx est un concurent d'apache qui est beaucoup plus performant que ce dernier. http://www.first-world.info/apache-vs-lighttpd-vs-nginx.html Voici comment installer Nginx sous Gentoo ...

### Compilation de Nginx
```bash
# Installation de vim-syntax avec nginx :-)
echo "www-server/nginx vim-syntax" > /etc/portage/package.use/nginx
emerge -av nginx
```

### Compilation de PHP
```bash
# N'ayant pas de module dav pour nginx, apache s'en occupera
echo "dev-lang/php fpm gd mysql zip apache2" > /etc/portage/package.use/php

# Options de compilation pour gd
echo "media-libs/gd png" > /etc/portage/package.use/gd

#Options de compilation pour png
# Ici la version de php a été forcée car sinon il y a des problèmes de dépendances.
echo "=dev-lang/php-5.3.8 truetype bcmath sockets" > /etc/portage/package.use/png 

emerge -av php
```

## Configuration

### Création d'un pool PHP

Editer le fichier /etc/php/fpm-php/php-fpm.conf

```ini
[global]

error_log = /var/log/php-fpm.log

[monpool]

listen = 127.0.0.1:9000
user = www-data
group = www-data
pm = dynamic
pm.max_children = 50
pm.min_spare_servers = 5
pm.max_spare_servers = 35
```

#### Détail des paramètres utilisés
**error_log** : Spécifie l'emplacement des logs  
**listen** : Spécifie l'ip et le port d'écoute de php-fpm  
**user/group** : Utilisateur et group d'exécution pour php-fpm  
**pm** = dynamic : PHP ne démarre pas immédiatement tous ses workers. Ils sont démarrés de façon dynamique.  
**pm.max_children** : Ici nous aurons au maximum 50 processus fils créés.  
**pm.min_spare_servers** : Ici 5 workers seront démarrés au lancement de PHP. Ceci est le nombre minimum de processus IDLE que nous trouverons sur le système.  
**pm.max_spare_servers** : Ici il y aura au maximum 35 workers PHP en IDLE. Ceci est réglé automatiquement en fonctione de la charge.

### Configuration du vhost Nginx

```nginx
upstream php {

 # Pas forcément utile ici, 
 # permets de faire du load-balancing entre différents serveurs php.
      #server unix:/tmp/php-cgi.socket;
      server 127.0.0.1:9000;

 }

 #Equivalent à 

 server {

   #On écoute sur toutes les interfaces

       listen       *;
       server_name  monsite.com  www.monsite.com;

       access_log /var/logs/nginx/monsite.com/access.log main;
       error_log /var/logs/nginx/monsite.com/error.log info;

       root /var/www/monsite.com;

        # Fichier d'index par defaut. Surcharge la valeur indiquée dans nginx.conf
       index index.php; 

       location = /favicon.ico {
             #On désactive les logs 404 et les access log pour les favicon.ico
             log_not_found off;
             access_log off;
       }

       location = /robots.txt {
            #On autorise tout le monde à avoir accès au fichier robots.txt et on 
            # désactive les logs pour ce fichier.
            allow all;
            log_not_found off;
            access_log off;
     }

   location / {
       #Si l'uri n'existe pas, 
       # on renvoie sur index.php
       try_files $uri $uri/ /index.php;
   }

   location ~ \.php {
      #Pour chaque fichier *.php, 
      # on charge la configuration php et on fait du proxypass vers le serveur php-fpm.
       include conf/fastcgi.conf;
       fastcgi_intercept_errors on;
       fastcgi_pass php;
   }

   location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
       # Tous les fichiers de type js,css,png,jpd,jpeg ... 
       # sont mis en cache pendant 24h. 
       # De plus les logs sont désactivés sur ces fichiers.
       expires 24h;
       log_not_found off;
   }

   location ~ \.htpasswd {
       # On interdit l'accès au fichier .htpasswd
       deny all;
   }

 }

 server {

     #On écoute sur le port 443. Ce vhost sera le vhost SSL par défaut.
     listen 443 default_server ssl;
     server_name monsite.com www.monsite.com;

     access_log /var/logs/nginx/monsite.com/access-ssl.log main;
     error_log /var/logs/nginx/monsite.com/error-ssl.log info;

     root /var/www/monsite.com;
     index index.php;

     location = /favicon.ico {
         log_not_found off;
         access_log off;
     }

     location = /robots.txt {
         allow all;
         log_not_found off;
         access_log off;
     }

     location / {
         #Si l'uri n'existe pas, on renvoie sur index.php
         try_files $uri $uri/ /index.php;
     }

     location ~ \.php {
         include conf/fastcgi.conf;
         fastcgi_intercept_errors on;
         fastcgi_pass php;
     }

     location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
         expires 24h;
         log_not_found off;
     }

     location ~ \.htpasswd {
         deny all;
     }
 }
```

Notez que dans la configuration du vhost SSL, il n'y pas d'information sur les certificats. En effet, ils ont été déclarés dans la configuration globale car ce sont des certificats wildcard. Ils sont donc valables pour tous les sous-domaine du site. Il est donc inutile de les redéfinir dans chaque vhost SSL. Par contre si il y a plusieurs domaines hébergés sur le même nginx, cette méthode n'est pas applicable.

## Démarrage des services Web

Lancement / Arrêt / Recharger la configuration Un init script a été installé automatiquement. Il permet de lancer/arrêter ou de recharger la configuration de nginx et php

```bash

/etc/init.d/nginx (start|stop|restart|reload)
/etc/init.d/php*fpm (start|stop|restart|reload)
```

## Lancement automatique des services web au redémarrage

```bash
rc-update add nginx default
rc-update add php-fpm default
```