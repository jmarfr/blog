+++
title = 'MySQL Procédures Stockées'
date = 2013-08-02T17:13:18+02:00
draft = false
+++

J'ai eu besoin, dans le cadre d'un projet, de supprimer des lignes sur certaines tables contenant un ID spécifique. Cette manipulation devant se faire régulièrement, une procédure stockée a été créée. 

```sql
DELIMITER $$ 
DROP PROCEDURE IF EXISTS DeleteOrphan$$ 

CREATE PROCEDURE DeleteOrphan(IN hwid INT) 
BEGIN 
 DECLARE done INT DEFAULT 0; 
 DECLARE var_table VARCHAR(64); 
 DECLARE curseur1 CURSOR FOR 
                     SELECT DISTINCT table_name 
                     FROM information_schema.tables 
                     WHERE table_name LIKE 'aaa_%' 
                     AND table_schema='MySchema'; 
 DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1; 

 -- Ouverture du curseur 
 OPEN curseur1; 
    REPEAT 
 -- On récupère chaque élément dans var_table 
         FETCH curseur1 INTO var_table; 
          -- Si done = 0 (donc tant qu'on a pas SQLSTAT 02000 
          IF done = 0 THEN 
                SET @query = CONCAT('DELETE FROM ', var_table,' WHERE hardware_id = ', hwid); 
                PREPARE stmt FROM @query; EXECUTE stmt; 
          END IF; 
          UNTIL done 
          -- Done = 1 si on a SQLSTAT 02000 (No data - zero rows fetched, selected, or processed ) 
    END REPEAT; 
 CLOSE curseur1; 
END$$ 
DELIMITER ;

```