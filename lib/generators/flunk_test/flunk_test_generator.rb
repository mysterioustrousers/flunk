class FlunkTestGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_test_file
      template "flunk_test.rb", "test/integration/#{file_name.pluralize}_test.rb"
  end
end
