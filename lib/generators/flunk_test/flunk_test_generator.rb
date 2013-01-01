class FlunkTestGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_test_file
      copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
