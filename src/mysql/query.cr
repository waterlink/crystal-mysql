module MySQL
  struct Query
    property value
    property params

    PARAM_REGEX = %r{:([a-z_][a-zA-Z_0-9]*)}

    def initialize(@value, @params={} of Symbol => MySQL::Types::SqlType)
      require_params!
    end

    def to_mysql
      required_params.inject(@value) { |value, name|
        replace(value, ":#{name}", representation(@params[name]))
      }
    end

    def run(connection)
      connection.query(to_mysql)
    end

    private def required_params
      @_required_params ||= @value.scan(PARAM_REGEX).map { |m| m[1] }
    end

    private def require_params!
      required_params.each do |name|
        @params.fetch(name) do
          raise Errors::MissingParameter.new("parameter :#{name} is missing, query: #{@value}")
        end
      end
    end

    private def replace(s, name, value)
      result = ""
      len = name.length
      p0 = 0
      while p1 = s.index(name, p0)
        result += s[p0...p1]
        result += value
        p0 = p1 + len
      end
      result + s[p0..-1]
    end

    def representation(value)
      Types::Value.new(value).lift_down.to_mysql
    end
  end
end
