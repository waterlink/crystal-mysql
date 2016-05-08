module MySQL
  struct Query
    property value
    property params

    PARAM_REGEX = %r{:([a-zA-Z_0-9]+)}

    @params : Hash(String, MySQL::Types::SqlType)
    def initialize(
      @value : String,
      params = {} of String => MySQL::Types::SqlType
    )
      @params = {} of String => MySQL::Types::SqlType
      params.each do |key, value|
        @params[key] = value
      end

      require_params!
    end

    def to_mysql
      required_params.reduce(@value) { |value, name|
        replace(value, ":#{name}", representation(@params[name]))
      }
    end

    def run(connection)
      connection.query(to_mysql)
    end

    @_required_params : Array(String)?
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
      len = name.size
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
