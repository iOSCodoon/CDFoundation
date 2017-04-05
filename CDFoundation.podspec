Pod::Spec.new do |s|
  s.name = 'CDFoundation'
  s.version = '0.0.2'
  s.license = 'MIT'
  s.summary = 'Basic toolset for CodoonSport.'
  s.homepage = 'https://github.com/iOSCodoon'
  s.authors = { 'iOSCodoon' => 'ios@codoon.com' }
  s.source = { :git => 'https://github.com/iOSCodoon/CDFoundation.git', :tag => s.version.to_s, :submodules => true }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.public_header_files = 'CDFoundation/*.h'
  s.source_files = 'CDFoundation/*.{h,m}'
  
  s.subspec 'CDCoreData' do |ss|
    ss.source_files = 'CDFoundation/CDCoreData/*.{h,m}'
    ss.public_header_files = 'CDFoundation/CDCoreData/*.h'
    ss.framework = 'CoreData'
  end

  s.subspec 'CDDateFormatter' do |ss|
    ss.source_files = 'CDFoundation/CDDateFormatter/*.{h,m}'
    ss.public_header_files = 'CDFoundation/CDDateFormatter/*.h'
  end

  s.subspec 'CDDefer' do |ss|
    ss.source_files = 'CDFoundation/CDDefer/*.{h,m}'
    ss.public_header_files = 'CDFoundation/CDDefer/*.h'
  end
  
  s.subspec 'CDGlobalTimer' do |ss|
    ss.source_files = 'CDFoundation/CDGlobalTimer/*.{h,m}'
    ss.public_header_files = 'CDFoundation/CDGlobalTimer/*.h'
  end    
  
  s.subspec 'CDSoundManager' do |ss|
    ss.source_files = 'CDFoundation/CDSoundManager/*.{h,m}'
    ss.public_header_files = 'CDFoundation/CDSoundManager/*.h'
    ss.dependency 'CDFoundation/CDDefer'
  end
  
end
