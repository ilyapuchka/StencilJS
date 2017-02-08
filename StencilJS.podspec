Pod::Spec.new do |s|

  s.name         = "StencilJS"
  s.version      = "0.0.1"
  s.summary      = "JavaScriptCore extension for Stencil"

  s.description  = <<-DESC
                   This pod contains [Stencil](https://github.com/kylef/Stencil) Extension
                   that allows extending Stencil template engine with custom tags and filters
                   written in JavaScript.
                   DESC

  s.homepage     = "https://github.com/ilyapuchka/StencilJS"
  s.license      = "MIT"
  s.author       = { "Ilya Puchka" => "ilya@puchka.me" }
  s.social_media_url = "https://twitter.com/ilyapuchka"

  s.platform = :osx, '10.9'

  s.source       = { :git => "https://github.com/ilyapuchka/StencilJS.git", :tag => s.version.to_s }

  s.source_files = "Sources/**/*.swift"

  s.dependency 'Stencil', '~> 0.7.0'
  s.framework  = "Foundation"
end
