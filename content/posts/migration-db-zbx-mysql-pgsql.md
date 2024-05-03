+++
title = 'Migration BDD Zabbix de MySQL vers PostgreSQL'
date = 2012-04-15T14:13:00+02:00
draft = false
+++

## Création de la base sous PostgreSQL

```sql
CREATE ROLE zabbix PASSWORD 'pass' LOGIN; 
CREATE DATABASE zabbix OWNER zabbix 
```

## Import du schéma Zabbix
```bash
psql -U zabbix zabbix < /usr/share/zabbix/database/create/postgresql.sql 
```

## Export des datas MySQL dans un format compatible avec PostgreSQL
```bash
mysqldump --compact -c -e -n -t --compatitable=postgresql zabbix > zabbix_mysql.sql 
```

## Echapement des apostrophes en trop
```bash
sed "s/\\\'/\'\'/g" zabbix_mysql.sql > zabbix_pg.sql 
```

## Import des données dans PostgreSQL
```bash
psql -U zabbix zabbix < zabbix_pg.sql 
```