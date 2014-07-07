# -*- coding: utf-8 -*-
lib LibMySQL("mysqlclient_r")
  struct MySQL
    # Look inside the file:
    #
    #   /usr/local/include/mysql/mysql.h
    #
    # and you'll find lots of gory details
    # about the struct `st_mysql`.
    #
    # However, it seems that the MySQL C API
    # was designed for you *not* to touch it's
    # internals in any way.
    #
    # In that case, I'm leave the struct blank
    # unless it's otherwise necessary to provide
    # more info.
  end

  # Allocates or initializes a MYSQL object suitable for mysql_real_connect().
  #
  # If the first parameter is a NULL pointer, the function allocates,
  # initializes, and returns a new object.
  #
  # Otherwise, the object is initialized and the address of the object is returned.
  # If mysql_init() allocates a new object, it is freed when mysql_close() is
  # called to close the connection.

  fun init         = mysql_init(m : MySQL*) : MySQL*

  # mysql_real_connect() attempts to establish a connection to a MySQL database
  # engine running on host. mysql_real_connect() must complete successfully before
  # you can execute any other API functions that require a valid MYSQL connection
  # handle structure.
  #
  # Arguments:
  #
  # * db is the database name. If db is not NULL, the connection sets the default
  # database to this value.
  # * If port is not 0, the value is used as the port number for the TCP/IP
  # connection. Note that the host parameter determines the type of the connection.
  # * If unix_socket is not NULL, the string specifies the socket or named pipe to
  # use. Note that the host parameter determines the type of the connection.
  # * The value of client_flag is usually 0, but can be set to a combination of the
  # following flags to enable certain features.

  fun real_connect = mysql_real_connect(mysql       : MySQL*,
                                        host        : UInt8*,
                                        user        : UInt8*,
                                        passwd      : UInt8*,
                                        db          : UInt8*,
                                        port        : UInt16,
                                        unix_socket : UInt8*,
                                        client_flag : UInt32) : MySQL*


  # Returns a string that represents the MySQL client library version;
  # for example, "5.0.96".

  fun client_info  = mysql_get_client_info() : UInt8*


  # For the connection specified by mysql, mysql_error() returns a null-terminated
  # string containing the error message for the most recently invoked API function
  # that failed. If a function did not fail, the return value of mysql_error() may
  # be the previous error or an empty string to indicate no error.

  fun error        = mysql_error(mysql : MySQL*) : UInt8*

  # Executes the SQL statement pointed to by the null-terminated string stmt_str.
  # Normally, the string must consist of a single SQL statement without a
  # terminating semicolon (“;”) or \g. If multiple-statement execution has been
  # enabled, the string can contain several statements separated by semicolons.
  # Return Values
  # Zero for success. Nonzero if an error occurred.

  fun query        = mysql_query(mysql : MySQL*, stmt_str : UInt8*) : Int16

  # Closes a previously opened connection. mysql_close() also deallocates
  # the connection handle pointed to by mysql if the handle was allocated
  # automatically by mysql_init() or mysql_connect().

  fun close        = mysql_close(m : MySQL*) : Void

end
