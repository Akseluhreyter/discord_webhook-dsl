Gem::Specification.new do |s|
  s.name     = 'discord_webhook-dsl'
  s.license  = 'MIT'
  s.version  = '0.0.1'
  s.summary  = "DSL for the Discord's webhook API."
  s.authors  = ['Akseluhreyter']
  s.files    = Dir['lib/**/*']
  #s.homepage = 'https://rubygems.org/gems/discord_webhook-dsl'
  #s.metadata = { "source_code_uri" => 'https://github.com/Akseluhreyter/discord_webhook-dsl' }
  s.required_ruby_version = '>= 3.2'
  s.add_dependency 'discord_webhook', '~> 0.0.1'
end
