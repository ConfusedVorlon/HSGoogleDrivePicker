
Pod::Spec.new do |s|

  s.name         = "HSGoogleDrivePicker"
  s.version      = "2.1.0"
  s.summary      = "A sane and simple file picker for Google Drive."

  s.homepage     = "https://github.com/ConfusedVorlon/HSGoogleDrivePicker"
  s.screenshots  = "https://raw.githubusercontent.com/ConfusedVorlon/HSGoogleDrivePicker/master/images/iPadPicker.png"

  s.license      = "MIT"

  s.author             = { "Rob" => "Rob@HobbyistSoftware.com" }

  s.platform     = :ios, "11.0"
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/ConfusedVorlon/HSGoogleDrivePicker.git", :tag => "2.1.0" }
  s.source_files  = "HSGoogleDrivePicker/HSGoogleDrivePicker"

  s.requires_arc = true
  s.dependency 'AsyncImageView'

  s.static_framework = true
  
  s.dependency 'GoogleAPIClient/Drive'
  s.dependency 'GoogleSignIn'


  s.dependency 'SVPullToRefresh'

end
