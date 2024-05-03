+++
title = 'Installation de PostgreSQL via YUM'
date = 2014-05-14T14:13:00+02:00
draft = false
+++

Note: Toute cette procédure est applicable pour Centos6

## 1. Configurer le dépôt officiel

```bash
rpm -ivh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm
```

## 2. Installer les paquets nécessaires
```bash
yum install postgresql93 postgresql93-server postgresql93-contrib --enablerepo=postgresql93
```
## 3. Créer le fichier de paramètres

Sous Centos, il est possible de créer un fichier dans /etc/sysconfig/pgsql/. Ce fichier permet de fixer les valeurs par defaut de l'instance

* **/etc/sysconfig/pgsql/postgresql-9.3:**
```ini
    PGDATA="/srv/postgresql/"
    PGPORT="5432"
    PG_INITDB_OPTS="--locale=en_US.UTF8"
```

## 4. Initialisation de l'instance
```bash
/etc/init.d/postgresql-9.3 initdb
```

Ne pas oublier d'activer PostgreSQL au démarrage de la machine :

```bash
chkconfig postgresql-9.3 on
```

## 5. Création d'une base avec l'utilisateur associé

```bash
su - postgres
/usr/pgsql-9.3/bin/createdb mabase
/usr/pgsql-9.3/bin/createuser -l monuser -W
# Entrer le mot de passe utilisateur
```
Il faut ensuite attribuer les droits à l'utilisateur sur la base. Ici nous allons le rendre propriétaire de la base.

```sql
psql
ALTER DATABASE mabase OWNER TO monuser;
```

## 6. Droits d'accès aux différentes bases

Le fichier pg_hba.conf se trouve dans le répertoire $PGDATA. Il permet de déterminer qui peut se connecter à tel ou tel base et quelle méthode d'authentification il doit utiliser.

http://www.postgresql.org/docs/9.3/static/auth-pg-hba-conf.html

Le fichier par défaut que j'utilise est le suivant :

```ini
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    mabase         monuser          127.0.0.1/32            md5

# IPv6 local connections:
host    mabase        monuser           ::1/128                 md5
```

Ici, les connexions via le socket local sont autorisées sans mot de passe à condition que l'utilisateur Unix soit le même que l'utilisateur de connexion à PostgreSQL.
Les connexions à la base mabase avec l'utilisateur monuser sont autorisées à partir de la boucle locale en ipv4 et en ipv6 avec la saisie d'un mot de passe. Le client doit envoyer le mot de passe en MD5

## Dernière étape

Il faut penser à recharger la configuration afin de prendre en compte la modification du fichier pg_hba.conf

```bash
/etc/init.d/postgresql-9.3 reload
```