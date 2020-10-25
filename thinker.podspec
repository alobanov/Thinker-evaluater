Pod::Spec.new do |s|
  s.name                      = "thinker"
  s.version                   = "1.0.0"
  s.summary                   = "thinker"
  s.homepage                  = "https://alobanov@github.com/alobanov/Thinker-evaluater"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Lobanov Aleksey" => "lobanov.aw@gmail.com" }
  s.source                    = { :git => "https://alobanov@github.com/alobanov/Thinker-evaluater.git", :tag => s.version.to_s }
  s.swift_version             = "5.1"
  s.ios.deployment_target     = "8.0"
  s.tvos.deployment_target    = "9.0"
  s.watchos.deployment_target = "2.0"
  s.osx.deployment_target     = "10.10"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"
end
