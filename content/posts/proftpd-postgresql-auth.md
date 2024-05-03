+++
title = 'Authentification PostgreSQL pour Proftpd'
date = 2013-11-18T14:13:00+02:00
draft = false
+++

## Préparation de la base PostgreSQL

### Création de l'utilisateur
```sql
CREATE USER ftp LOGIN ENCRYPTED PASSWORD 'sup3rs3cret'; 
CREATE DATABASE ftpuser OWNER ftp; 
CREATE TABLE users ( pkid serial PRIMARY KEY, userid text NOT NULL UNIQUE, passwd text, uid int, gid int, homedir text, shell text ); 
CREATE TABLE groups ( groupname VARCHAR(30) NOT NULL, gid INTEGER NOT NULL, members VARCHAR(255) ); 
```

Ajout de l'extention pgcrypto pour les mots de passe Nécessiste d'avoir le paquet contrib d'installé. 

```sql
CREATE EXTENTION pgcrypto;
```

## Préparation de la configuration Proftpd

**proftpd.conf**
```ini
LoadModule mod_sql.c 
include /etc/proftpd/pgsql.conf 
# Module important pour indiquer quel type de backend utiliser (MySQL ou PostgreSQL) 
LoadModule mod_sql_postgres.c 
AuthOrder mod_sql.c 
SQLAuthTypes Crypt Plaintext 
SQLAuthenticate users 
SQLConnectInfo ftpusers@127.0.0.1:5432 
ftp supers3cr3t 
SQLDefaultUID 1000 # CHANGE FOR YOUR FTP USERS UID FOUND IN /etc/passwd 
SQLDefaultGID 1000 # CHANGE FOR YOUR FTP USERS GID, FOUND IN /etc/groups 
SQLDefaultHomedir /home/ftp RequireValidShell off SQLUserInfo users userid passwd uid gid homedir shell 
SQLNegativeCache off 
SQLLogFile /var/log/proftpd-sql 
SQLLog STOR newfile # Permet de logger en base si la table existe. 
SQLNamedQuery newfile FREEFORM "INSERT INTO file_log(userid,abs_path,file,dns,time_transaction) VALUES ('%U','%f','%J','%V','%T')" # %U => userid # %D => --Nothing, # %f => abs_path # %J => file # %h => dns_remote, %V => dns_local # %a => remote_ip, %L => local_ip # %t => localtime # %T => transfer_time
```

## Création de l'utilisateur
```sql
INSERT INTO users ( userid, passwd, homedir, shell ) VALUES ( 'user1', crypt('pwd1', gen_salt('md5')), '/home/ftp/user', '/bin/false' );
```