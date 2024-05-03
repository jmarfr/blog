+++
title = 'PostgreSQL - Suppression de tables en fonction du Owner'
date = 2012-07-16T17:13:18+02:00
draft = false
+++
Suite à une fausse manipulation, j'ai importé l'ensemble de mes bases de données dans la base template1. Conséquence, toutes les nouvelles bases de données créées le seraient avec le schéma de toutes les autres bases. C'est moche ! Le nombre de table étant importantes, j'ai donc créé une procédure stockée afin de supprimer rapidement les tables en fonction d'un owner passé en paramètre. 

Connexion à la base Postgres à nettoyer
```bash
bash> psql -U postgres template1
```

* Création de la procédure
```sql
CREATE LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION clean_database(owner IN VARCHAR) RETURNS void AS $$
    DECLARE
        statements CURSOR FOR
            SELECT tablename FROM pg_tables
            WHERE tableowner = owner;
    BEGIN
        FOR stmt IN statements LOOP
            EXECUTE 'DROP TABLE ' || quote_ident(stmt.tablename) || ';';
        END LOOP;
    END;
    $$
    LANGUAGE plpgsql;
```

* Exécution de la procédure. Les tables ont les owner suivants : zabbix,photos,drupal.
```sql
SELECT clean_database('zabbix');
SELECT clean_database('drupal');
SELECT clean_database('photos');
```