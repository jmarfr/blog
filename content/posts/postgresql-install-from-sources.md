+++
title = 'Installation de PostgreSQL à partir des sources'
date = 2012-02-27T16:13:18+02:00
draft = false
+++

## Récupération des sources

```bash
wget http://ftp.postgresql.org/pub/source/v9.1.2/postgresql-9.1.2.tar.gz 
tar xvzf postgresql-9.1.2.tar.gz 
```

## Compilation des sources
```bash
cd postgresql-9.1.2 
./configure --prefix=/opt/postgresql-9.1.2 
make -j2 && make install 
```

## Initialisation de la base
```bash
useradd -d /home/databases/postgresql postgres 
mkdir -p /home/databases/postgresql 
chown postgres: -R /home/databases/postgresql 
su - postgres 
/opt/postgresql-9.1.2/bin/initdb -D /home/databases/postgresql-9.1.2 
/opt/postgersql-9.1.2/bin/pg_ctl -D /home/databases/postgresql-9.1.2 start 
```

Voila un postgresql installé et démarré. Un prochain article détaillera une configuration un peu plus optimisée.