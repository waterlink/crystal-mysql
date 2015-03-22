# crystal-mysql

[![Build Status](https://travis-ci.org/waterlink/crystal-mysql.svg?branch=master)](https://travis-ci.org/waterlink/crystal-mysql)

Fork of https://github.com/farleyknight/crystal-mysql

Basic MySQL bindings for Crystal.

## Installation

Add it to your `Projectfile`

```crystal
deps do
  github "waterlink/crystal-mysql"
end
```

## Usage

```crystal
require "mysql"
```

### Connecting to mysql

```crystal
# MySQL.connect(host, user, password, database, port, socket, flags = 0)
conn = MySQL.connect("127.0.0.1", "crystal_mysql", "", "crystal_mysql_test", 3306_u16, nil)
```

## High-level API roadmap

| High level method               | Implemented? |
|---------------------------------|--------------|
| MySQL.connect                   | Yes          |
| Connection#initialize           | Yes          |
| Connection#client_info          | Yes          |
| Connection#error                | Yes          |
| Support#escape_string           | Yes          |
| Connection#connect              | Yes          |
| Connection#host_info            | No           |
| Connection#query                | 65% (usable) |
| Connection#start_transaction    | Yes          |
| Connection#commit_transaction   | Yes          |
| Connection#rollback_transaction | Yes          |
| Connection#transaction          | Yes          |
| Connection#close                | Yes          |

## Contributing

1. Fork it ( https://github.com/waterlink/crystal-mysql/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) - maintainer
- [farleyknight](https://github.com/farleyknight) - original idea
