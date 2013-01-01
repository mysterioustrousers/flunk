class Flunk < ActionDispatch::IntegrationTest

  def self.test(name, &block)
    new_proc = Proc.new do
      instance_eval(&block)
      result
      @assertions.call unless @assertions.nil?
    end

    super name, &new_proc
  end

  def self.flunk(action, failure_reason, &block)
    test("FLUNKED: #{action} (#{failure_reason})", &block)
  end

  def result
    if !@result_fetched
      @result_fetched = true

      if (@username || @password)
        @headers ||= {}
        @headers["HTTP_AUTHORIZATION"] = "Basic #{Base64.encode64(@username.to_s + ":" + @password.to_s)}".strip
      end

      send @method, @path, @body, @headers

      @response = response

      assert_response @status

      if response.body.length > 2
        if response.content_type == 'application/json'
          json = ActiveSupport::JSON.decode(response.body)
          rec_symbolize( json )
          @result = json
        end
      end
    end

    @result
  end

  def path(path)
    @path = path
  end

  def method(method)
    @method = method
  end

  def username(username)
    @username = username
  end

  def password(password)
    @password = password
  end

  def ssl(ssl)
    @ssl = ssl
  end

  def body(body)
    @body = body
  end

  def header(key, value)
    @headers ||= {}
    @headers[key] = value
  end

  def param(key, value)
    @params ||= {}
    @params[key] = value
  end

  def status(status)
    @status = status
  end

  def desc(desc)
    @desc = desc
  end

  def assertions(&block)
    @assertions = block
  end

  def rec_symbolize(obj)
    if obj.class == Hash
      obj.symbolize_keys!
      obj.map {|k,v| rec_symbolize(v) }
    elsif obj.class == Array
      obj.map {|v| rec_symbolize(v) }
    end
    nil
  end

end
