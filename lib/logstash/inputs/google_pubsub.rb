# encoding: utf-8

# Author: Eric Johnson <erjohnso@google.com>
# Date: 2016-06-01
#
# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require "logstash/inputs/base"
require "logstash/namespace"

# Google deps
require "google/api_client"

# Consume events from https://cloud.google.com/pubsub/docs/overview[Google Cloud Pub/Sub] service.
class LogStash::Inputs::GooglePubSub < LogStash::Inputs::Base
  config_name "google_pubsub"

  # Google Cloud Project ID (name, not number)
  config :project_id, :validate => :string, :required => true

  # Google Cloud Pub/Sub Topic and Subscription.
  # Note that the topic must be created manually with Cloud Logging
  # pre-configured export to PubSub configured to use the defined topic.
  # The subscription will be created automatically by the plugin.
  config :topic, :validate => :string, :required => true
  config :subscription, :validate => :string, :required => true
  config :max_messages, :validate => :number, :required => true, :default => 5

  # If logstash is running within Google Compute Engine, the plugin will use
  # GCE's Application Default Credentials. Outside of GCE, you will need to
  # specify a Service Account JSON key file.
  config :json_key_file, :validate => :path, :required => false

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

  private
  def request(options)
    begin
      @logger.debug("Sending an API request")
      result = @client.execute(options)
    rescue ArgumentError => e
      @logger.debug("Authorizing...")
      @client.authorization.fetch_access_token!
      @logger.debug("...authorized")
      request(options)
    rescue Faraday::TimeoutError => e
      @logger.debug("Request timeout, re-trying request")
      request(options)
    end
  end # def request

  public
  def register
    @logger.debug("Registering Google PubSub Input: project_id=#{@project_id}, topic=#{@topic}, subscription=#{@subscription}")
    @topic = "projects/#{@project_id}/topics/#{@topic}"
    @subscription = "projects/#{@project_id}/subscriptions/#{@subscription}"
    @subscription_exists = false

    # TODO(erjohnso): read UA data from the gemspec
    @client = Google::APIClient.new(
      :application_name => 'logstash-input-google_pubsub',
      :application_version => '0.9.0'
    )

    # Initialize the pubsub API client
    @pubsub = @client.discovered_api('pubsub', 'v1')

    # Handle various kinds of auth (JSON or Application Default Creds)
    # NOTE: Cannot use 'googleauth' gem since there are dependency conflicts
    #       - googleauth ~> 0.5 requires mime-data-types that requires ruby2
    #       - googleauth ~> 0.3 requires multi_json 1.11.0 that conflicts
    #         with logstash-2.3.2's multi_json 1.11.3
    if @json_key_file
      @logger.debug("Authorizing with JSON key file: #{@json_key_file}")
      file_path = File.expand_path(@json_key_file)
      key_json = File.open(file_path, "r", &:read)
      key_json = JSON.parse(key_json)
      unless key_json.key?("client_email") || key_json.key?("private_key")
        raise Google::APIClient::ClientError, "Invalid JSON credentials data."
      end
      signing_key = ::Google::APIClient::KeyUtils.load_from_pem(key_json["private_key"], "notasecret")
      @client.authorization = Signet::OAuth2::Client.new(
        :audience => "https://accounts.google.com/o/oauth2/token",
        :auth_provider_x509_cert_url => "https://www.googleapis.com/oauth2/v1/certs",
        :client_x509_cert_url => "https://www.googleapis.com/robot/v1/metadata/x509/#{key_json['client_email']}",
        :issuer => "#{key_json['client_email']}",
        :scope => %w(https://www.googleapis.com/auth/cloud-platform),
        :signing_key => signing_key,
        :token_credential_uri => "https://accounts.google.com/o/oauth2/token"
      )
      @logger.info("Client authorizataion with JSON key ready")
    else
      # Assume we're running in GCE and can use metadata tokens, if the host
      # GCE instance was not created with the PubSub scope, then the plugin
      # will not be authorized to read from pubsub.
      @logger.info("Authorizing with application default credentials")
      @client.authorization = :google_app_default
    end # if @json_key_file...
  end # def register

  def run(queue)
    # Attempt to create the subscription
    if !@subscription_exists
      @logger.debug("Creating subscription #{subscription}")
      result = request(
        :api_method => @pubsub.projects.subscriptions.create,
        :parameters => {'name' => @subscription},
        :body_object => {
          :topic => @topic,
          :ackDeadlineSeconds => 15
        }
      )
      if result.error? and result.status != 409
        raise Google::APIClient::ClientError, "Error #{result.status}: #{result.error_message}"
      end
      @subscription_exists = true
    end # if !@subscription

    @logger.debug("Pulling messages from sub '#{subscription}'")
    while !stop?
      # Pull and queue messages
      messages = []
      result = request(
        :api_method => @pubsub.projects.subscriptions.pull,
        :parameters => {'subscription' => @subscription},
        :body_object => {
          :returnImmediately => false,
          :maxMessages => @max_messages
        }
      )

      if !result.error?
        messages = JSON.parse(result.body)
        if messages.key?("receivedMessages")
          messages = messages["receivedMessages"]
        end
      else
        @logger.error("Error pulling messages:'#{result.error_message}'")
      end

      if messages
        messages.each do |msg|
          if msg.key?("message") and msg["message"].key?("data")
            decoded_msg = Base64.decode64(msg["message"]["data"])
            begin
              parsed_msg = JSON.parse(decoded_msg)
            rescue
              parsed_msg = { :raw_message => decoded_msg }
            end
            event = LogStash::Event.new(parsed_msg)
            decorate(event)
            queue << event
          end
        end

        ack_ids = messages.map{ |msg| msg["ackId"] }
        result = request(
          :api_method => @pubsub.projects.subscriptions.acknowledge,
          :parameters => {'subscription' => @subscription},
          :body_object => {
            :ackIds => ack_ids
          }
        )
        if result.error?
          @logger.error("Error #{result.status}: #{result.error_message}")
        end
      end # if messages
    end # loop
  end # def run
end # class LogStash::Inputs::GooglePubSub
