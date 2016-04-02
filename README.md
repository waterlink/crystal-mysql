# crystal-mysql

[![Build Status](https://travis-ci.org/waterlink/crystal-mysql.svg?branch=master)](https://travis-ci.org/waterlink/crystal-mysql)

Fork of https://github.com/farleyknight/crystal-mysql

Basic MySQL bindings for Crystal.

CAUTION: Pre-alpha quality. Don't use for anything serious. Any bug reports and feedback are warmly welcome!

## Installation

Add it to your `shard.yml`

```yaml
dependencies:
  mysql:
    github: waterlink/crystal-mysql
    version: ~> 0.4
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

### Using higher level Query api

```crystal
MySQL::Query
  .new(%{SELECT * FROM user WHERE created_at > :from_filter},
       { "from_filter" => 14.days.ago })
  .run(conn)
```

You can reference parameters in query with symbol-like syntax: `:some_symbol_like_syntax` or `:someSymbolLikeSyntax`. And then you can resolve these references with passing a hash as a second argument, which specifies values for these parameters.

By the way all strings get properly escaped, so no SQL injections should be possible (if something is not escaped properly, then it is a bug, and you should probably report it here on github).

You can reference the same symbol multiple times in one query, as well you can use as much symbols as you want.

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

## Notes

* This library assumes `tinyint` is used as `boolean` type.

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
| Connection#query                | 72% (usable) |
| Connection#start_transaction    | Yes          |
| Connection#commit_transaction   | Yes          |
| Connection#rollback_transaction | Yes          |
| Connection#transaction          | Yes          |
| Connection#close                | Yes          |
| Query#to_mysql                  | Yes          |
| Query#run                       | Yes          |

## TODO

- Support more types: Enum, Set, Geometry, Binary strings
- Figure out utf-8 (and other collations) support
- Set up CI for different versions of mysql, ie: 5.5, 5.6, 5.7
- Set up CI for mac os x
- Figure out 32bit support?

## Contributing

1. Fork it ( https://github.com/waterlink/crystal-mysql/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) - maintainer
- [farleyknight](https://github.com/farleyknight) - original idea
