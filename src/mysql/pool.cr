module MySQL
	class PooledConnection < Connection
		def initialize(@pool, @cnx)
			@handle = @cnx.@handle
			@connected = true
		end

		def finalize
			close
		end

		def close
			@pool.queue_connection @cnx
			@connected = false
		end
	end

	class ConnectionPool
		def initialize(@pool_name, @pool_size, *args)
			@queue = Array(MySQL::Connection).new @pool_size
			@queue_lock = Mutex.new

			# Add connections
			i = 0
			while i < @pool_size
				add_connection(*args)
				i += 1
			end
		end

		private def add_connection(*args)
			@queue_lock.synchronize do
				@queue.push Connection.new.connect(*args)
			end
		end

		def queue_connection(cnx : MySQL::Connection)
			# TODO Reset session
			@queue_lock.synchronize do
				@queue = @queue.push cnx
			end
		end

		def get_connection?
			@queue.size > 0
		end

		def get_connection
			@queue_lock.synchronize do
				if !get_connection?
					raise Errors::ConnectionPoolExhaustedError.new
				end
				cnx = @queue.pop
				PooledConnection.new self, cnx
			end
		end

		def finalize
			@queue_lock.synchronize do
				while @queue.pop?
					cnx = @queue.pop
					cnx.close
				end
			end
		end
	end
end