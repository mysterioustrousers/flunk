require 'rails/test_help'

class Flunk < ActionDispatch::IntegrationTest

  def self.test(resource, action, &block)
    new_proc = Proc.new do
      instance_eval(&block)
      result
      instance_eval(&@after) unless @after.nil?
    end

    if !action || !resource
      name = action || resource
    else
      name = resource + ": " + action
    end

    super name, &new_proc
  end

  def self.flunk(resource, action, failure_reason, &block)
    test("FLUNKED! #{resource}: #{action} (#{failure_reason})", nil, &block)
  end

  def result
    if !@result_fetched
      @result_fetched = true

      @username   ||= self.class.config.username
      @password   ||= self.class.config.password
      @auth_token ||= self.class.config.auth_token
      @headers    ||= self.class.config.headers
      @method     ||= self.class.config.method
      @ssl        ||= self.class.config.ssl

      if @username || @password
        @headers ||= {}
        @headers["HTTP_AUTHORIZATION"] = "Basic #{Base64.encode64(@username.to_s + ":" + @password.to_s)}".strip
      elsif @auth_token
        @headers ||= {}
        @headers["HTTP_AUTHORIZATION"] = "Token token=\"#{@auth_token}\"".strip
      end

      send @method, @path, @body, @headers

      @response = response

      assert_response @status, @response.body

      unless response.body.blank?
        if response.content_type == 'application/json'
          json = ActiveSupport::JSON.decode(response.body)
          rec_symbolize( json )
          @result = json
        end
      end
    end

    @result
  end

  attr_reader :desc
  def desc(desc)
    @desc = desc
  end

  attr_reader :path
  def path(path)
    @path = path
  end

  attr_reader :method
  def method(method)
    @method = method
  end

  attr_reader :username
  def username(username)
    @username = username
  end

  attr_reader :password
  def password(password)
    @password = password
  end

  attr_reader :auth_token
  def auth_token(auth_token)
    @auth_token = auth_token
  end

  attr_reader :ssl
  def ssl(ssl)
    @ssl = ssl
  end

  attr_reader :body
  def body(body)
    @body = body
  end

  attr_reader :status
  def status(status)
    @status = status
  end

  def header(key, value)
    @headers ||= {}
    @headers = self.class.config.headers.merge @headers
    @headers[key] = value
  end

  def headers
    @headers
  end

  def param(key, value)
    @params ||= {}
    @params[key] = value
  end

  def params
    @params
  end




  # before/after blocks

  def before(&block)
    @before = block
    instance_eval(&@before)
  end

  def after(&block)
    @after = block
  end



  # global

  def self.doc_file=(doc_file)
    @@doc_file = doc_file
  end

  def self.config
    @@config ||= self.new "FlunkConfig"
  end



  # helpers

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
