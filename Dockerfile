FROM logstash:5

MAINTAINER Sergey Melnik <sergey.melnik@commercetools.com>

ENV PATH=/usr/share/logstash/vendor/jruby/bin/:$PATH

COPY ./ /opt/logstash-plugin

RUN cd /opt/logstash-plugin/ && gem build logstash-input-google_pubsub.gemspec

RUN logstash-plugin install /opt/logstash-plugin/logstash-input-google_pubsub-0.9.1.gem