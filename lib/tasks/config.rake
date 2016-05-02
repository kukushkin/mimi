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

desc 'Display config manifest and current config'
task :config do
  rake_task_config(false)
end

namespace :config do
  desc 'Display config manifest and current config, including consts'
  task :all do
    rake_task_config(true)
  end
end
