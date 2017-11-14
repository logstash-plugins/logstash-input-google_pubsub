# this is a generated file, to avoid over-writing it just delete this comment
begin
  require 'jar_dependencies'
rescue LoadError
  require 'com/google/api/grpc/proto-google-iam-v1/0.1.24/proto-google-iam-v1-0.1.24.jar'
  require 'io/netty/netty-buffer/4.1.16.Final/netty-buffer-4.1.16.Final.jar'
  require 'org/threeten/threetenbp/1.3.3/threetenbp-1.3.3.jar'
  require 'com/google/errorprone/error_prone_annotations/2.0.19/error_prone_annotations-2.0.19.jar'
  require 'com/google/api/grpc/grpc-google-cloud-pubsub-v1/0.1.24/grpc-google-cloud-pubsub-v1-0.1.24.jar'
  require 'io/netty/netty-codec-http/4.1.16.Final/netty-codec-http-4.1.16.Final.jar'
  require 'io/grpc/grpc-protobuf-lite/1.7.0/grpc-protobuf-lite-1.7.0.jar'
  require 'io/netty/netty-common/4.1.16.Final/netty-common-4.1.16.Final.jar'
  require 'com/google/auto/value/auto-value/1.2/auto-value-1.2.jar'
  require 'com/google/protobuf/protobuf-java-util/3.4.0/protobuf-java-util-3.4.0.jar'
  require 'com/google/http-client/google-http-client-jackson2/1.19.0/google-http-client-jackson2-1.19.0.jar'
  require 'com/fasterxml/jackson/core/jackson-core/2.1.3/jackson-core-2.1.3.jar'
  require 'com/google/code/findbugs/jsr305/3.0.0/jsr305-3.0.0.jar'
  require 'joda-time/joda-time/2.9.2/joda-time-2.9.2.jar'
  require 'io/netty/netty-handler/4.1.16.Final/netty-handler-4.1.16.Final.jar'
  require 'com/google/http-client/google-http-client/1.19.0/google-http-client-1.19.0.jar'
  require 'commons-logging/commons-logging/1.1.1/commons-logging-1.1.1.jar'
  require 'org/json/json/20160810/json-20160810.jar'
  require 'com/google/cloud/google-cloud-core/1.10.0/google-cloud-core-1.10.0.jar'
  require 'io/netty/netty-codec-http2/4.1.16.Final/netty-codec-http2-4.1.16.Final.jar'
  require 'com/google/guava/guava/20.0/guava-20.0.jar'
  require 'com/google/cloud/google-cloud-core-grpc/1.10.0/google-cloud-core-grpc-1.10.0.jar'
  require 'com/google/protobuf/protobuf-java/3.3.0/protobuf-java-3.3.0.jar'
  require 'com/google/api/gax/1.14.0/gax-1.14.0.jar'
  require 'org/apache/httpcomponents/httpclient/4.0.1/httpclient-4.0.1.jar'
  require 'com/google/api/gax-grpc/1.14.0/gax-grpc-1.14.0.jar'
  require 'com/google/auth/google-auth-library-credentials/0.9.0/google-auth-library-credentials-0.9.0.jar'
  require 'com/google/api/api-common/1.2.0/api-common-1.2.0.jar'
  require 'com/google/api/grpc/proto-google-common-protos/1.0.0/proto-google-common-protos-1.0.0.jar'
  require 'io/grpc/grpc-auth/1.7.0/grpc-auth-1.7.0.jar'
  require 'io/grpc/grpc-core/1.7.0/grpc-core-1.7.0.jar'
  require 'io/netty/netty-codec-socks/4.1.16.Final/netty-codec-socks-4.1.16.Final.jar'
  require 'io/grpc/grpc-protobuf/1.7.0/grpc-protobuf-1.7.0.jar'
  require 'io/grpc/grpc-context/1.7.0/grpc-context-1.7.0.jar'
  require 'io/netty/netty-transport/4.1.16.Final/netty-transport-4.1.16.Final.jar'
  require 'commons-codec/commons-codec/1.3/commons-codec-1.3.jar'
  require 'com/google/instrumentation/instrumentation-api/0.4.3/instrumentation-api-0.4.3.jar'
  require 'io/netty/netty-handler-proxy/4.1.16.Final/netty-handler-proxy-4.1.16.Final.jar'
  require 'io/netty/netty-resolver/4.1.16.Final/netty-resolver-4.1.16.Final.jar'
  require 'io/netty/netty-tcnative-boringssl-static/2.0.6.Final/netty-tcnative-boringssl-static-2.0.6.Final.jar'
  require 'com/google/code/gson/gson/2.7/gson-2.7.jar'
  require 'io/grpc/grpc-netty/1.7.0/grpc-netty-1.7.0.jar'
  require 'io/opencensus/opencensus-api/0.6.0/opencensus-api-0.6.0.jar'
  require 'org/apache/httpcomponents/httpcore/4.0.1/httpcore-4.0.1.jar'
  require 'io/netty/netty-codec/4.1.16.Final/netty-codec-4.1.16.Final.jar'
  require 'io/grpc/grpc-stub/1.7.0/grpc-stub-1.7.0.jar'
  require 'com/google/cloud/google-cloud-pubsub/0.28.0-beta/google-cloud-pubsub-0.28.0-beta.jar'
  require 'com/google/api/grpc/proto-google-cloud-pubsub-v1/0.1.24/proto-google-cloud-pubsub-v1-0.1.24.jar'
  require 'com/google/auth/google-auth-library-oauth2-http/0.9.0/google-auth-library-oauth2-http-0.9.0.jar'
end

if defined? Jars
  require_jar( 'com.google.api.grpc', 'proto-google-iam-v1', '0.1.24' )
  require_jar( 'io.netty', 'netty-buffer', '4.1.16.Final' )
  require_jar( 'org.threeten', 'threetenbp', '1.3.3' )
  require_jar( 'com.google.errorprone', 'error_prone_annotations', '2.0.19' )
  require_jar( 'com.google.api.grpc', 'grpc-google-cloud-pubsub-v1', '0.1.24' )
  require_jar( 'io.netty', 'netty-codec-http', '4.1.16.Final' )
  require_jar( 'io.grpc', 'grpc-protobuf-lite', '1.7.0' )
  require_jar( 'io.netty', 'netty-common', '4.1.16.Final' )
  require_jar( 'com.google.auto.value', 'auto-value', '1.2' )
  require_jar( 'com.google.protobuf', 'protobuf-java-util', '3.4.0' )
  require_jar( 'com.google.http-client', 'google-http-client-jackson2', '1.19.0' )
  require_jar( 'com.fasterxml.jackson.core', 'jackson-core', '2.1.3' )
  require_jar( 'com.google.code.findbugs', 'jsr305', '3.0.0' )
  require_jar( 'joda-time', 'joda-time', '2.9.2' )
  require_jar( 'io.netty', 'netty-handler', '4.1.16.Final' )
  require_jar( 'com.google.http-client', 'google-http-client', '1.19.0' )
  require_jar( 'commons-logging', 'commons-logging', '1.1.1' )
  require_jar( 'org.json', 'json', '20160810' )
  require_jar( 'com.google.cloud', 'google-cloud-core', '1.10.0' )
  require_jar( 'io.netty', 'netty-codec-http2', '4.1.16.Final' )
  require_jar( 'com.google.guava', 'guava', '20.0' )
  require_jar( 'com.google.cloud', 'google-cloud-core-grpc', '1.10.0' )
  require_jar( 'com.google.protobuf', 'protobuf-java', '3.3.0' )
  require_jar( 'com.google.api', 'gax', '1.14.0' )
  require_jar( 'org.apache.httpcomponents', 'httpclient', '4.0.1' )
  require_jar( 'com.google.api', 'gax-grpc', '1.14.0' )
  require_jar( 'com.google.auth', 'google-auth-library-credentials', '0.9.0' )
  require_jar( 'com.google.api', 'api-common', '1.2.0' )
  require_jar( 'com.google.api.grpc', 'proto-google-common-protos', '1.0.0' )
  require_jar( 'io.grpc', 'grpc-auth', '1.7.0' )
  require_jar( 'io.grpc', 'grpc-core', '1.7.0' )
  require_jar( 'io.netty', 'netty-codec-socks', '4.1.16.Final' )
  require_jar( 'io.grpc', 'grpc-protobuf', '1.7.0' )
  require_jar( 'io.grpc', 'grpc-context', '1.7.0' )
  require_jar( 'io.netty', 'netty-transport', '4.1.16.Final' )
  require_jar( 'commons-codec', 'commons-codec', '1.3' )
  require_jar( 'com.google.instrumentation', 'instrumentation-api', '0.4.3' )
  require_jar( 'io.netty', 'netty-handler-proxy', '4.1.16.Final' )
  require_jar( 'io.netty', 'netty-resolver', '4.1.16.Final' )
  require_jar( 'io.netty', 'netty-tcnative-boringssl-static', '2.0.6.Final' )
  require_jar( 'com.google.code.gson', 'gson', '2.7' )
  require_jar( 'io.grpc', 'grpc-netty', '1.7.0' )
  require_jar( 'io.opencensus', 'opencensus-api', '0.6.0' )
  require_jar( 'org.apache.httpcomponents', 'httpcore', '4.0.1' )
  require_jar( 'io.netty', 'netty-codec', '4.1.16.Final' )
  require_jar( 'io.grpc', 'grpc-stub', '1.7.0' )
  require_jar( 'com.google.cloud', 'google-cloud-pubsub', '0.28.0-beta' )
  require_jar( 'com.google.api.grpc', 'proto-google-cloud-pubsub-v1', '0.1.24' )
  require_jar( 'com.google.auth', 'google-auth-library-oauth2-http', '0.9.0' )
end
