Pod::Spec.new do |s|
  s.name         = "MondoPlayerView"
  s.version      = "0.0.8"
  s.summary      = "Provides a custom class and view for iOS AVPlayer."
  s.platform	 = :ios, "8.0"
  s.homepage     = "https://www.moltenviper.com"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "tache" => "tgs@tachegroup.com" }
  s.social_media_url   = "http://twitter.com/tache"
  # s.source       = { :path => '~/GitHub/MondoPlayerView'}
  s.source       = { :git => "https://github.com/tache/MondoPlayerView.git", :tag => "#{s.version}"}
  s.source_files = "MondoPlayerView/**/*.{swift,h}"
  # s.resources = "MondoPlayerView/**/*.{png,jpeg,jpg,storyboard,xib}"
  s.framework    = "AVFoundation", "CoreMedia"
  s.description  = <<-DESC
                   A longer description of MondoPlayerView in Markdown format.
                   DESC
end


#
#  Be sure to run `pod spec lint MondoPlayerView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#

