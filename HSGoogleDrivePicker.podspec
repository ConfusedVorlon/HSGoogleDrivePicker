
Pod::Spec.new do |s|

  s.name         = "HSGoogleDrivePicker"
  s.version      = "0.1.4"
  s.summary      = "A sane and simple file picker for Google Drive."

  s.homepage     = "https://github.com/ConfusedVorlon/HSGoogleDrivePicker"
  #s.screenshots  = "https://raw.githubusercontent.com/ConfusedVorlon/RCBRightClick/master/images/simpleItem.png"

  s.license      = "MIT"

  s.author             = { "Rob" => "Rob@HobbyistSoftware.com" }

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/ConfusedVorlon/RCBRightClick.git", :tag => "0.0.1" } 
  s.source_files  = "HSGoogleDrivePicker/HSGoogleDrivePicker"
 
  s.requires_arc = true
  #s.dependency 'AsyncImageView'

end
