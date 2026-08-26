Pod::Spec.new do |s|
  s.name             = 'gymsas_payments'
  s.version          = '0.1.0'
  s.summary          = 'Provider-neutral payment checkout module for GymSAS.'
  s.description      = 'GymSAS payment ports and native checkout adapters.'
  s.homepage         = 'https://gymsas.local'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'GymSAS' => 'dev@gymsas.local' }
  s.source           = { :path => '.' }
  s.source_files     = 'gymsas_payments/Sources/gymsas_payments/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
