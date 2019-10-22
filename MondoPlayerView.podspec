Pod::Spec.new do |s|
  s.name         = "MondoPlayerView"
  s.version      = "0.0.18"
  s.summary      = "Provides a custom class and view for iOS AVPlayer."
  s.tvos.deployment_target = '10.3'
  s.ios.deployment_target = '10.3'
  s.homepage     = "https://github.com/tache/MondoPlayerView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "tache" => "tgs@tachegroup.com" }
  s.social_media_url   = "http://twitter.com/tache"
  s.source       = { :git => "https://github.com/tache/MondoPlayerView.git", :tag => "#{s.version}"}
  s.source_files = "MondoPlayerView/**/*.{swift,h}"
  s.frameworks    = ['AVFoundation', 'CoreMedia']
  s.description  = <<-DESC
                   A longer description of MondoPlayerView in Markdown format.
                   DESC
end


#
#  Be sure to run `pod spec lint MondoPlayerView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#

