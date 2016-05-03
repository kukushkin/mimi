def rake_task_config(show_all = false)
  config = Mimi::Config.new(
    Mimi::Application.manifest_filename, raise_on_missing_params: false
  )
  config.manifest.each do |param|
    next if param[:const] && !show_all
    name = param[:name]
    annotation = []
    if param[:const]
      annotation << esc_bold('[CONST]')
    else
      annotation << esc_red('[MISSING]') if config.missing_params.include?(name)
      annotation << "(default: #{param[:default].inspect})" unless param[:required]
    end
    annotation << param[:desc] if param.key?(:desc)
    annotation.unshift('  #') unless annotation.empty?
    puts "#{name}=#{config[name]}#{annotation.join(' ')}"
  end
  abort(esc_red('# configure missing parameters')) unless config.missing_params.empty?
end

def rake_task_config_manifest_generate
  config = Mimi::Config.new
  config.load(
    Mimi::Application.manifest_filename, raise_on_missing_params: false
  ) if File.exist?(Mimi::Application.manifest_filename)

  # first deep_merge to preserve key order in the existing app manifest
  manifest = config.manifest_raw.deep_merge(Mimi.loaded_modules_manifest)
  # second deep_merge to preserve key values in the existing app manifest
  manifest = manifest.deep_merge(config.manifest_raw)

  manifest.to_yaml
end

desc 'Display config manifest and current config'
task :config do
  rake_task_config(false)
end

namespace :config do
  desc 'Display config manifest and current config, including consts'
  task :all do
    rake_task_config(true)
  end

  desc 'Generate and display a combined manifest for all loaded modules'
  task :manifest do
    puts rake_task_config_manifest_generate
  end

  namespace :manifest do
    desc "Generate and write a combined manifest to: #{Mimi::Application.manifest_filename}"
    task :create do
      if File.exist?(Mimi::Application.manifest_filename)
        puts "* Found an existing application manifest, loading: #{Mimi::Application.manifest_filename}"
      end
      puts '* Generating a combined manifest'
      manifest_contents = rake_task_config_manifest_generate
      config_path = Mimi.app_path_to('config')
      puts "* Writing the combined manifest to: #{Mimi::Application.manifest_filename}"
      sh "install -d #{config_path}" unless File.directory?(config_path)
      manifest_filename = Mimi.app_path_to('config', 'manifest.yml')
      File.open(manifest_filename, 'w') do |f|
        f.puts manifest_contents
      end
    end
  end
end
