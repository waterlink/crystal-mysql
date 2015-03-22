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

### Making a query

```crystal
conn.query(%{SELECT 1})  #=> [[1]]

conn.query(%{CREATE TABLE user (id INT, email VARCHAR(255), name VARCHAR(255))})

conn.query(%{INSERT INTO user(id, email, name) values(1, "john@example.com", "John Smith")})
conn.query(%{INSERT INTO user(id, email, name) values(2, "sarah@example.com", "Sarah Smith")})

conn.query(%{SELECT * FROM user}) #=> [[1, "john@example.com", "John Smith"], [2, "sarah@example.com", "Sarah Smith"]]

conn.query(%{DROP TABLE user})
```

### Making a transaction

```crystal
other_conn = MySQL.connect("127.0.0.1", "crystal_mysql", "", "crystal_mysql_test", 3306_u16, nil)

conn.transaction do
  conn.query(%{SELECT COUNT(id) FROM user})  #=> 2
  conn.query(%{INSERT INTO user(id, email, name) values(1, "james@example.com", "James Smith")})

  conn.query(%{SELECT COUNT(id) FROM user})  #=> 3
  other_conn.query(%{SELECT COUNT(id) FROM user})  #=> 2
end

conn.query(%{SELECT COUNT(id) FROM user})  #=> 3
other_conn.query(%{SELECT COUNT(id) FROM user})  #=> 3
```

If block provided for `#transaction` raises exception, then it will rollback transaction automatically.

You can use `#start_transaction`, `#commit_transaction` and `#rollback_transaction` manually:

```crystal
begin
  conn.start_transaction
  # .. do stuff with conn ..
  conn.commit_transaction
rescue
  conn.rollback_transaction
end
```

Nested transactions are possible.

### Closing connection

```crystal
conn.close
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
