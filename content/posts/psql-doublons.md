+++
title = 'PostgreSQL: Trouver des doublons dans une table'
date = 2015-05-23T14:13:00+02:00
draft = false
+++

Dans PostgreSQL, il existe les window functions qui permettent de faire des calculs sur un ensemble d'éléments liés aux éléments courants. Dans le cas présent, nous allons demander à PostgreSQL de regrouper les éléments en fonction de la valeur de deux champs.

* Jeu de test :

```sql
CREATE TABLE double (id serial PRIMARY KEY, name text, value int );
INSERT INTO double (name, value) VALUES ('nom1', 1);
INSERT INTO double (name, value) VALUES ('nom1', 2);
INSERT INTO double (name, value) VALUES ('nom1', 3);
INSERT INTO double (name, value) VALUES ('nom2', 1);
INSERT INTO double (name, value) VALUES ('nom2', 2);
INSERT INTO double (name, value) VALUES ('nom2', 3);
INSERT INTO double (name, value) VALUES ('nom3', 1);
INSERT INTO double (name, value) VALUES ('nom1', 1);
INSERT INTO double (name, value) VALUES ('nom1', 1);

```


Nous allons maintenant rechercher les doublons sur le couple nom, valeur.

```sql
SELECT * FROM ( SELECT id, name, row_number() OVER (PARTITION BY name, value ORDER BY id ASC ) AS dup FROM double ) AS w WHERE dup > 1;
```

* Voici le résultat

```sql
[local]/test =# SELECT * FROM (SELECT id, name, row_number() OVER (PARTITION BY name, value ORDER BY id ASC) AS dup FROM double) AS pwet WHERE dup > 1; 
id │ name │ dup 
───┼──────┼───── 
 8 │ nom1 │ 2 
 9 │ nom1 │ 3 
(2 lignes) 

```

* On peut ensuite imaginer une requête qui supprime les doublons :

```sql
DELETE FROM double WHERE id IN ( SELECT id FROM ( SELECT id, name, row_number() OVER (PARTITION BY name, value ORDER BY id ASC) AS dup FROM double ) AS w WHERE dup > 1 ); 
DELETE 2 Temps : 65,681 ms 
```
