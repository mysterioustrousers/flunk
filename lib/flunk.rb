require 'rails/test_help'

class Flunk < ActionDispatch::IntegrationTest

  def self.test(resource, action, &block)

    if action.class == Hash
      name    = action[:name]
      action  = action[:action]
    end
  
    new_proc = Proc.new do
      @resource ||= resource
      @action   ||= action
      instance_eval(&block)
      result
      instance_eval(&@after) unless @after.nil?
    end

    name = resource + ": " + action if name.nil?
    super name, &new_proc
  end

  def self.flunk(resource, action, failure_reason, &block)
    name = "Flunked #{resource}: #{action} (#{failure_reason})"
    test(resource, { action: action, name: name }, &block)
  end


  def result
    if !@result_fetched
      @result_fetched = true

      @username   ||= self.class.config.read_username
      @password   ||= self.class.config.read_password
      @auth_token ||= self.class.config.read_auth_token
      @headers    ||= self.class.config.read_headers
      @method     ||= self.class.config.read_method
      @ssl        ||= self.class.config.read_ssl

      if @username || @password
        @headers ||= {}
        @headers["HTTP_AUTHORIZATION"] = "Basic #{Base64.encode64(@username.to_s + ":" + @password.to_s)}".strip
      elsif @auth_token
        @headers ||= {}
        @headers["HTTP_AUTHORIZATION"] = "Token token=\"#{@auth_token}\"".strip
      end

      send @method, @path, @body, @headers

      @response = response

      # if response.status == 422
      #   puts "VALIDATION ERRORS:"
      #   puts JSON.pretty_generate(JSON.parse(response.body))
      # end
      
      assert_response @status, @response.body

      unless response.body.blank?
        if response.content_type == 'application/json'
          begin
            json = ActiveSupport::JSON.decode(response.body)
            rec_symbolize( json )
            @result = json
          rescue => e
            @result = response.body
          end
        end
      end

      if not @desc.nil?
        make_doc @resource, @action, @desc, @path, @method, @auth_token, @headers, @body, @status, @result
      end
      
    end

    @result
  end

  def desc(desc)
    @desc = desc
  end
  
  def read_desc
    @desc
  end

  def base_url(base_url)
    @base_url
  end

  def read_base_url
    @base_url
  end

  def path(path)
    @path = path
  end

  def read_path
    @path
  end

  def method(method)
    @method = method
  end

  def read_method
    @method
  end

  def username(username)
    @username = username
  end

  def read_username
    @username
  end

  def password(password)
    @password = password
  end

  def read_password
    @password
  end

  def auth_token(auth_token)
    @auth_token = auth_token
  end

  def read_auth_token
    @auth_token
  end

  def ssl(ssl)
    @ssl = ssl
  end

  def read_ssl
    @ssl
  end

  def body(body)
    @body = body
  end

  def read_body
    @body
  end

  def status(status)
    @status = status
  end

  def read_status
    @status
  end

  def header(key, value)
    @headers ||= {}
    @headers = self.class.config.read_headers.merge @headers if self.class.config.read_headers
    @headers[key] = value
  end

  def read_headers
    @headers
  end

  def param(key, value)
    @params ||= {}
    @params[key] = value
  end

  def read_params
    @params
  end

  def doc_directory(doc_directory)
    FileUtils.rm_r(doc_directory) if File.exists?(doc_directory)
    FileUtils.mkdir_p(doc_directory) 
    @doc_directory = doc_directory
  end

  def read_config_doc_directory
    @doc_directory
  end

  def read_doc_directory
    @doc_directory = self.class.config.read_config_doc_directory || "docs/flunk"
    FileUtils.mkdir_p(@doc_directory) unless File.exists?(@doc_directory)
    @doc_directory
  end
  
  def doc_base_url(doc_base_url)
    @doc_base_url = doc_base_url
  end
  
  def read_config_doc_base_url
    @doc_base_url
  end

  def read_doc_base_url
    self.class.config.read_config_doc_base_url 
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

  def make_doc resource, action, desc, path, method, auth_token, headers, body, status, response
    body = body.class == String ? JSON.parse(body) : body
    url = File.join(@@config.read_base_url.to_s, path.to_s)
    
    contents = ""
    
    contents += "# #{action.humanize}\n\n"
    
    contents += "#{desc.humanize}\n\n"
    
    contents += "## Request\n\n"
    
    if not auth_token.nil?
      contents += "- **Requires Authentication**\n"
    end
    
    contents += "- **Method:** #{method.to_s.upcase}\n"
    
    # if not headers.nil?
    #   headers_strings = headers.map {|k,v| "  - #{k}: #{v}" }
    #   contents += "- **Headers:**\n#{headers_strings.join("\n")}\n"
    # end
    
    contents += "- **URL:** #{url}\n"
    
    if not body.nil?
      contents += "- **Body:**\n\n```json\n#{pretty(body)}\n```\n\n"
    else
      contents += "\n"
    end
    
    contents += "## Response\n\n"
    
    contents += "- **Status:** #{Rack::Utils::SYMBOL_TO_STATUS_CODE[status]} #{status.to_s.humanize}\n"
    
    if not response.nil?
      contents += "- **Body:**\n\n```json\n#{pretty(response)}\n```\n\n"
    else
      contents += "\n"
    end
    
    contents += "## Example\n\n"
    
    contents += 
"```bash
curl -X #{method.to_s.upcase} \\\n"
    headers.to_h.each do |key, value|      
      contents += 
"     -H \'#{key}: #{value}\' \\\n"
    end
    if not body.nil?
      contents += 
"     -d '#{pretty(body).gsub /\n/, " \\\n         "}' \\\n"
    end
    contents += 
"     \"#{ URI::join(read_doc_base_url, url) }\"
```"
    
    save_doc resource, action, contents
  end
  
  
  # custom attributes must follow this form:
  # customer_attributes =
  #   key:
  #     kind: [text | code]
  #     content: [text]
  def make_custom_doc resource, action, desc, custom_attributes
    contents = ""
    contents += "# #{action.humanize}\n\n"
    contents += "#{desc.humanize}\n\n"
    
    custom_attributes.each do |key, value|
      if value[:kind] == :text
        contents += "- **#{key.to_s.humanize}:** #{value[:content]}\n"
      elsif value[:kind] == :code
        contents += "- **#{key.to_s.humanize}:**\n\n```\n#{value[:content]}\n```\n\n"
      end
    end
    
    save_doc resource, action, contents
  end
  
  
  def save_doc resource, action, contents
    resource_directory = File.join( read_doc_directory, resource.pluralize.capitalize )
    FileUtils.mkdir_p(resource_directory) unless File.exists?( resource_directory )
    file_path = File.join( resource_directory, "#{action.capitalize}.md" )
    File.open(file_path, 'w') {|f| f.write(contents) }
  end
  
  def pretty json
    begin
      pretty_json = JSON.pretty_generate(json)
    rescue => e
      pretty_json = json
    end
  end

end
