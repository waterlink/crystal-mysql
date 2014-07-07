
# crystal-mysql

Basic MySQL bindings.

## MySQL's C API

| C Function            | Crystal Function      | Implemented? |
|-----------------------|-----------------------|--------------|
| mysql_init            | LibMySQL.init         | Yes          |
| mysql_real_connect    | LibMySQL.real_connect | Yes          |
| mysql_get_client_info | LibMySQL.client_info  | Yes          |
| mysql_error           | LibMySQL.error        | Yes          |
| mysql_query           | LibMySQL.query        | Yes          |
| mysql_close           | LibMySQL.close        | Yes          |
