# SQL tips

## update a row with a substring of itself

* update the field_name with a substring from the '-' to 3 more characters

    ``UPDATE `table_name` SET `table_name`.`field_name` = substring_index(`table_name`.`field_name`,'-',3);``
    
* duplicate a column

    ``UPDATE `table_name` SET `table_name`.`field_name` = `table_name`.`old_field_name`;``
    
