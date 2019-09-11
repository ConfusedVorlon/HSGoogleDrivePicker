
Pod::Spec.new do |s|

  s.name         = "HSGoogleDrivePicker"
  s.version      = "3.0.1"
  s.summary      = "A sane and simple file picker for Google Drive."

  s.homepage     = "https://github.com/ConfusedVorlon/HSGoogleDrivePicker"
  s.screenshots  = "https://raw.githubusercontent.com/ConfusedVorlon/HSGoogleDrivePicker/master/images/iPadPicker.png"

  s.license      = "MIT"

  s.author             = { "Rob" => "Rob@HobbyistSoftware.com" }

  s.platform     = :ios, "11.0"
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/ConfusedVorlon/HSGoogleDrivePicker.git", :tag => s.version.to_s }
  s.source_files  = "HSGoogleDrivePicker/HSGoogleDrivePicker"

  s.requires_arc = true
  s.dependency 'AsyncImageView'

  s.static_framework = true

  #1.3.x causes error where methods on GTLRDriveService are unavailable
  s.dependency 'GoogleAPIClientForREST/Drive', '~> 1.2.1'
  s.dependency 'GoogleSignIn', '~> 5.0.0'

end
