
# crystal-mysql

Basic MySQL bindings for Crystal.

# MySQL's C API

| C Function            | Crystal Function      | Implemented? | Tested? |
|-----------------------|-----------------------|--------------|---------|
| mysql_init            | LibMySQL.init         | Yes          | Yes     |
| mysql_real_connect    | LibMySQL.real_connect | Yes          | Yes     |
| mysql_get_client_info | LibMySQL.client_info  | Yes          | Yes     |
| mysql_get_host_info   | LibMySQL.host_info    | No           | No      |
| mysql_commit          | LibMySQL.commit       | No           | No      |
| mysql_error           | LibMySQL.error        | Yes          | Yes     |
| mysql_query           | LibMySQL.query        | Yes          | No      |
| mysql_close           | LibMySQL.close        | Yes          | No      |
