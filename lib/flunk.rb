# require 'rails/test_help'

class Flunk < ActionDispatch::IntegrationTest

  def self.test(resource, action, &block)
    if action.class == Hash
      hash          = action
      name          = hash[:name]
      action        = hash[:action]
      flunk_reason  = hash[:flunk_reason]
    end

    new_proc = Proc.new do
      @resource     ||= resource
      @action       ||= action
      @flunk_reason ||= flunk_reason
      instance_eval(&block)
      result
      instance_eval(&@after) unless @after.nil?
    end

    name = resource + ": " + action if name.nil?
    super name, &new_proc
  end

  def self.flunk(resource, action, failure_reason, &block)
    name = "Flunked #{resource}: #{action} (#{failure_reason})"
    test(resource, { action: action, name: name, flunk_reason: failure_reason }, &block)
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

      @headers = {
        "CONTENT_TYPE" => "application/json",
        # "HTTP_ACCEPT" => "application/json"
      }.merge!(@headers || {})
      # @headers ||= {}

      if @username || @password
        @headers["HTTP_AUTHORIZATION"] = "Basic #{Base64.encode64(@username.to_s + ":" + @password.to_s)}".strip
      elsif @auth_token
        @headers["HTTP_AUTHORIZATION"] = "Token token=\"#{@auth_token}\"".strip
      end

      @body = @body.to_json if @body.present?

      send @method, @path, params: @body, headers: @headers

      @response = response


      expected_status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[@status]

      if response.status == 422 and expected_status_code != 422
        puts "VALIDATION ERRORS:"
        puts JSON.pretty_generate(JSON.parse(response.body))
      end

      if response.status.to_i != expected_status_code
        puts "STATUS MISMATCH:"
        puts "path: #{@path}"
        puts "headers: #{@headers.to_json}"
        puts "body: #{@body}"
      end

      assert_response @status

      unless response.body.blank?
        @result = response.body
        if response.content_type.to_s.include? 'json'
          begin
            json = ActiveSupport::JSON.decode(response.body)
            if json.class == Hash
              json = json.with_indifferent_access
            elsif json.class == Array
              json = json.map {|h| h.with_indifferent_access }
            end
            @result = json
          rescue => e
          end
        end
      end
      if not @desc.nil?
        make_doc @resource, @action, @desc, @path, @method, @auth_token, @headers, @body, @status, @result, @flunk_reason
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
    uri = URI.parse path
    uri.path = uri.path[0] == "/" ? uri.path : "/#{uri.path}"
    # uri.path = uri.path[-5..-1] == ".json" ? uri.path : "#{uri.path}.json"
    @path = uri.to_s
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
    self.class.config.read_config_doc_base_url || "http://www.example.com/"
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



  # docs

  @@type_token = "<<type>>"

  def make_doc resource, action, desc, path, method, auth_token, headers, body, status, response, flunk_reason
    path =  path.to_s.gsub(/\/\d+\b/, "/:id")
    body = body.class == String ? JSON.parse(body) : body
    url = File.join(@@config.read_base_url.to_s, path)

    headers ||= {}
    headers["Content-Type"] = "application/json"
    headers["Accept"]       = "application/json"

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
      # take token out of header
      if key == "HTTP_AUTHORIZATION"
        value = "Token token=\"<access_token>\""
      end
      contents +=
"     -H \'#{key}: #{value}\' \\\n"
    end
    if not body.nil?
      contents +=
"     -d '#{pretty(body).gsub /\n/, "\n         "}' \\\n"
    end
    contents +=
"     \"#{ URI::join(read_doc_base_url, url) }\"
```"

    save_doc resource, action, contents, flunk_reason
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


  def save_doc resource, action, contents, flunk_reason = nil
    resource_directory = File.join( read_doc_directory, resource.pluralize.capitalize )
    FileUtils.mkdir_p(resource_directory) unless File.exists?( resource_directory )
    file_path = File.join( resource_directory, "#{action.capitalize}#{flunk_reason.present? ? " - " + flunk_reason.chomp(".").gsub(/[\/]/, ",") : ""}.md" )
    File.open(file_path, 'w') {|f| f.write(contents) }
  end

  def pretty json
    simplified = simplify json
    generic = values_to_types simplified
    begin
      pretty_json = JSON.pretty_generate(generic).gsub(/"#{@@type_token}(.*?)#{@@type_token}"/, "\\1")
    rescue => e
      pretty_json = generic
    end
  end

  # instead of data, show the type, this prevents the docs from changing every time tests are run.
  def values_to_types json
    copy = Marshal.load(Marshal.dump(json))
    queue = [{parent: nil, key: nil, value: copy}]
    while queue.count > 0
      current = queue.shift

      parent = current[:parent]
      key    = current[:key]
      value  = current[:value]

      if value.kind_of?(Hash)
        for k,v in value
          queue.push parent: value, key: k, value: v
        end

      elsif value.kind_of?(Array)
        value.each_with_index do |v, i|
          queue.push parent: value, key: i, value: v
        end

      elsif parent
        parent[key] = value_to_type value

      end
    end

    copy
  end

  # makes sure that lists of things only have 1 copy, so docs don't get huge and redundent
  def simplify(json)
    copy = Marshal.load(Marshal.dump(json))
    queue = [{parent: nil, key: nil, value: copy}]
    while queue.count > 0
      current = queue.shift

      parent = current[:parent]
      key    = current[:key]
      value  = current[:value]

      if value.kind_of?(Hash)
        for k,v in value
          queue.push parent: value, key: k, value: v
        end

      elsif value.kind_of?(Array) and value.count > 0
        value.slice!(1, value.count - 1)
        value.each_with_index do |v, i|
          queue.push parent: value, key: i, value: v
        end

      end
    end

    copy

  end

  def value_to_type(value)
    if value.class == Fixnum
      return "#{@@type_token}Integer#{@@type_token}"
    elsif value.class == FalseClass || value.class == TrueClass
      return "#{@@type_token}Boolean#{@@type_token}"
    end
    return "#{@@type_token}#{value.class}#{@@type_token}"
  end

end
