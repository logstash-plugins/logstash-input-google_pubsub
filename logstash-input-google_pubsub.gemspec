Gem::Specification.new do |s|
  s.name = 'logstash-input-google_pubsub'
  s.version         = '1.1.0'
  s.licenses = ['Apache-2.0']
  s.summary = "Consume events from a Google Cloud PubSub service"
  s.description = "This gem is a Logstash input plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program."
  s.authors = ["Eric Johnson"]
  s.email = 'erjohnso@google.com'
  s.homepage = "https://cloud.google.com/pubsub/overview"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir["lib/**/*","spec/**/*","*.gemspec","*.md","CONTRIBUTORS","Gemfile","LICENSE","NOTICE.TXT", "vendor/jar-dependencies/**/*.jar", "vendor/jar-dependencies/**/*.rb", "VERSION", "docs/**/*"]
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'stud', '>= 0.0.22'
  # Google dependencies
  # google-api-client >= 0.9 requires ruby2 which is not currently compatible
  # with JRuby
  s.add_runtime_dependency 'google-api-client', '~> 0.8.6', '< 0.9'
  s.add_development_dependency 'logstash-devutils'
end
