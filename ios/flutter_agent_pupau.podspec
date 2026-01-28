Pod::Spec.new do |s|
  s.name             = 'flutter_agent_pupau'
  s.version          = '1.0.1'
  s.summary          = 'A Flutter plugin that integrates Pupau AI agents into your application.'
  s.description      = <<-DESC
A Flutter plugin that integrates Pupau AI agents into your application.
                       DESC
  s.homepage         = 'https://github.com/gluelabs/flutter_agent_pupau'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Glue Labs' => 'info@glue-labs.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
