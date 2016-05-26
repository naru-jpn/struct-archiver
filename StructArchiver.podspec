
Pod::Spec.new do |s|
  s.name         = "StructArchiver"
  s.version      = "0.0.1"
  s.summary      = "Archive struct into NSData and unarchive in Swift."
  s.homepage     = "https://github.com/naru-jpn/struct-archiver"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author       = { "naru-jpn" => "tus.naru@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/naru-jpn/struct-archiver.git", :tag => "0.0.1" }
  s.source_files  = "Sources/*.swift"
end
