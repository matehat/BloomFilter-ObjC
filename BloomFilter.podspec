Pod::Spec.new do |s|
  s.name         =  'BloomFilter'
  s.version      =  '0.10.1'
  s.license      =  'MIT'
  s.summary      =  'A Simple Bloom Filter implementation, wrapped in an Objective-C class.'
  s.homepage     =  'https://github.com/matehat/BloomFilter-ObjC'
  s.authors      =  'Mathieu D\'Amours'
  
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  
  s.source       =  { :git => 'https://github.com/matehat/BloomFilter-ObjC.git', :tag => 'v0.10.1' }
  s.source_files =  'Classes/*.{h,m,c}'
end