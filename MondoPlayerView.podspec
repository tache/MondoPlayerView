Pod::Spec.new do |s|
  s.name         = "MondoPlayerView"
  s.version      = "0.0.1"
  s.summary      = "A short description of MondoPlayerView."
  s.platform	 = :ios, "8.0"
  s.homepage     = "https://github.com/tache/MondoPlayerView"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "tache" => "tgs@tachegroup.com" }
  s.social_media_url   = "http://twitter.com/tache"
  s.source       = { :git => "https://github.com/tache/MondoPlayerView.git", :tag => "0.0.1" }
  s.source_files = "MondoPlayerView/**/*.{swift}"
  s.resources = "MondoPlayerView/**/*.{png,jpeg,jpg,storyboard,xib}"
  s.framework    = "AVFoundation", "CoreMedia"
  s.description  = <<-DESC
                   A longer description of MondoPlayerView in Markdown format.
                   DESC
end


#
#  Be sure to run `pod spec lint MondoPlayerView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#

