# crystal-mysql

[![Build Status](https://travis-ci.org/waterlink/crystal-mysql.svg?branch=master)](https://travis-ci.org/waterlink/crystal-mysql)

Fork of https://github.com/farleyknight/crystal-mysql

Basic MySQL bindings for Crystal.

## Usage

*No usage yet, since basic high level APIs are not yet implemented (such as `#query`)*

## High-level API roadmap

| High level method     | Implemented? |
|-----------------------|--------------|
| MySQL#initialize      | Yes          |
| MySQL#client_info     | Yes          |
| MySQL#error           | Yes          |
| MySQL#escape_string   | Yes          |
| MySQL#connect         | Yes          |
| MySQL#host_info       | No           |
| MySQL#query           | No           |
| MySQL#transaction     | No           |
| MySQL#close           | No           |

## Low-level API roadmap

| C Function            | Crystal Function      | Implemented? |
|-----------------------|-----------------------|--------------|
| mysql_init            | LibMySQL.init         | Yes          |
| mysql_real_connect    | LibMySQL.real_connect | Yes          |
| mysql_get_client_info | LibMySQL.client_info  | Yes          |
| mysql_get_host_info   | LibMySQL.host_info    | No           |
| mysql_commit          | LibMySQL.commit       | No           |
| mysql_error           | LibMySQL.error        | Yes          |
| mysql_query           | LibMySQL.query        | Yes          |
| mysql_close           | LibMySQL.close        | Yes          |

## Contributing

1. Fork it ( https://github.com/waterlink/crystal-mysql/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) - maintainer
- [farleyknight](https://github.com/farleyknight) - original idea
