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

# This is a https://github.com/elastic/logstash[Logstash] input plugin for 
# https://cloud.google.com/pubsub/[Google Pub/Sub]. The plugin can subscribe 
# to a topic and ingest messages.
#
# The main motivation behind the development of this plugin was to ingest 
# https://cloud.google.com/logging/[Stackdriver Logging] messages via the 
# https://cloud.google.com/logging/docs/export/using_exported_logs[Exported Logs] 
# feature of Stackdriver Logging.
#
# ==== Prerequisites
#
# You must first create a Google Cloud Platform project and enable the the 
# Google Pub/Sub API. If you intend to use the plugin ingest Stackdriver Logging 
# messages, you must also enable the Stackdriver Logging API and configure log 
# exporting to Pub/Sub. There is plentiful information on 
# https://cloud.google.com/ to get started: 
#
# - Google Cloud Platform Projects and https://cloud.google.com/docs/overview/[Overview]
# - Google Cloud Pub/Sub https://cloud.google.com/pubsub/[documentation]
# - Stackdriver Logging https://cloud.google.com/logging/[documentation]
#
# ==== Cloud Pub/Sub
#
# Currently, this module requires you to create a `topic` manually and specify 
# it in the logstash config file. You must also specify a `subscription`, but 
# the plugin will attempt to create the pull-based `subscription` on its own. 
#
# All messages received from Pub/Sub will be converted to a logstash `event` 
# and added to the processing pipeline queue. All Pub/Sub messages will be 
# `acknowledged` and removed from the Pub/Sub `topic` (please see more about 
# https://cloud.google.com/pubsub/overview#concepts)[Pub/Sub concepts]. 
#
# It is generally assumed that incoming messages will be in JSON and added to 
# the logstash `event` as-is. However, if a plain text message is received, the 
# plugin will return the raw text in as `raw_message` in the logstash `event`. 
#
# ==== Authentication
#
# You have two options for authentication depending on where you run Logstash. 
#
# 1. If you are running Logstash outside of Google Cloud Platform, then you will 
# need to create a Google Cloud Platform Service Account and specify the full 
# path to the JSON private key file in your config. You must assign sufficient 
# roles to the Service Account to create a subscription and to pull messages 
# from the subscription. Learn more about GCP Service Accounts and IAM roles 
# here:
#
#   - Google Cloud Platform IAM https://cloud.google.com/iam/[overview]
#   - Creating Service Accounts https://cloud.google.com/iam/docs/creating-managing-service-accounts[overview]
#   - Granting Roles https://cloud.google.com/iam/docs/granting-roles-to-service-accounts[overview]
#
# 1. If you are running Logstash on a Google Compute Engine instance, you may opt 
# to use Application Default Credentials. In this case, you will not need to 
# specify a JSON private key file in your config.
#
# ==== Stackdriver Logging (optional)
#
# If you intend to use the logstash plugin for Stackdriver Logging message 
# ingestion, you must first manually set up the Export option to Cloud Pub/Sub and 
# the manually create the `topic`. Please see the more detailed instructions at, 
# https://cloud.google.com/logging/docs/export/using_exported_logs [Exported Logs] 
# and ensure that the https://cloud.google.com/logging/docs/export/configure_export#manual-access-pubsub[necessary permissions] 
# have also been manually configured.
#
# Logging messages from Stackdriver Logging exported to Pub/Sub are received as 
# JSON and converted to a logstash `event` as-is in 
# https://cloud.google.com/logging/docs/export/using_exported_logs#log_entries_in_google_pubsub_topics[this format].
#
# ==== Sample Configuration
#
# Below is a copy of the included `example.conf-tmpl` file that shows a basic 
# configuration for this plugin.
#
# [source,ruby]
# ----------------------------------
# input {
#     google_pubsub {
#         # Your GCP project id (name)
#         project_id => "my-project-1234"
#
#         # The topic name below is currently hard-coded in the plugin. You
#         # must first create this topic by hand and ensure you are exporting
#         # logging to this pubsub topic.
#         topic => "logstash-input-dev"
#
#         # The subscription name is customizeable. The plugin will attempt to
#         # create the subscription (but use the hard-coded topic name above).
#         subscription => "logstash-sub"
#
#         # If you are running logstash within GCE, it will use
#         # Application Default Credentials and use GCE's metadata
#         # service to fetch tokens.  However, if you are running logstash
#         # outside of GCE, you will need to specify the service account's
#         # JSON key file below.
#         #json_key_file => "/home/erjohnso/pkey.json"
#     }
# }
# output { stdout { codec => rubydebug } }
# ----------------------------------
#
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

  # Google Cloud Pub/Sub Acknowledgement Deadline in seconds.
  # The message is sent again if your code doesn't acknowledge the message
  # before the deadline to ensure at least once delivery.
  config :ack_deadline_seconds, :validate => :number, :required => true, :default => 15

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
      :application_version => '1.1.0'
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
      @logger.info("Client authorization with JSON key ready")
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
          :ackDeadlineSeconds => @ack_deadline_seconds
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
            @codec.decode(decoded_msg) do |event|
              decorate(event)
              queue << event
            end
          end
        end

        ack_ids = messages.map{ |msg| msg["ackId"] }
        next if ack_ids.empty?

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
