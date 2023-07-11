if (version = Gem::Version.new(Bundler::VERSION)) < Gem::Version.new('2.3.15')
  abort "Bundler version >= 2.3.15 is required. You are running #{version}"
end

source 'https://rubygems.org'
ruby '2.6.4'

gem 'cocoapods'
gem 'bundler', '~> 2.3.15'

gem 'nokogiri'

gem 'fastlane'

gem 'rubyzip'
gem 'zip-zip'

# gem 'axlsx'
gem 'lexeme'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
