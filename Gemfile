if (version = Gem::Version.new(Bundler::VERSION)) < Gem::Version.new('2.1.4')
  abort "Bundler version >= 2.1.4 is required. You are running #{version}"
end

source 'https://rubygems.org'
ruby '2.6.4'

gem 'cocoapods', '~> 1.10.0.beta.2'
gem 'bundler', '~> 2.1.4'


gem 'nokogiri'

gem 'fastlane'

gem 'rubyzip'
gem 'zip-zip'

# gem 'axlsx'
gem 'lexeme'

gem "xcode-install"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
