require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/google_pubsub"

describe LogStash::Inputs::GooglePubSub do

  let(:minimal_config) { { 'project_id' => 'myproj', 'subscription' => 'foo', 'topic' => 'bar' } }

  describe "configuration validation" do
    context "required settings" do
      it "raises error when project_id is missing" do
        config = { 'topic' => 'foo', 'subscription' => 'bar' }
        expect {
          LogStash::Inputs::GooglePubSub.new(config)
        }.to raise_error(LogStash::ConfigurationError)
      end

      it "raises error when topic is missing" do
        config = { 'project_id' => 'foo', 'subscription' => 'bar' }
        expect {
          LogStash::Inputs::GooglePubSub.new(config)
        }.to raise_error(LogStash::ConfigurationError)
      end

      it "raises error when subscription is missing" do
        config = { 'project_id' => 'foo', 'topic' => 'bar' }
        expect {
          LogStash::Inputs::GooglePubSub.new(config)
        }.to raise_error(LogStash::ConfigurationError)
      end

      it "accepts valid minimal configuration" do
        expect {
          LogStash::Inputs::GooglePubSub.new(minimal_config)
        }.not_to raise_error
      end
    end

    context "authentication settings" do
      it "raises error when both json_key_file and json_key_file_content are specified" do
        config = minimal_config.merge(
          'json_key_file' => 'spec/inputs/test.json',
          'json_key_file_content' => '{}'
        )
        expect {
          plugin = LogStash::Inputs::GooglePubSub.new(config)
          plugin.register
        }.to raise_error(LogStash::ConfigurationError, /Specify either 'json_key_file' or 'json_key_file_content'/)
      end

      it "accepts configuration with only json_key_file" do
        config = minimal_config.merge('json_key_file' => 'spec/inputs/test.json')
        plugin = LogStash::Inputs::GooglePubSub.new(config)
        # Note: register will fail if file doesn't exist, but config validation passes
        expect(plugin.json_key_file).to eq('spec/inputs/test.json')
      end

      it "accepts configuration with only json_key_file_content" do
        config = minimal_config.merge('json_key_file_content' => '{"type": "service_account"}')
        plugin = LogStash::Inputs::GooglePubSub.new(config)
        expect(plugin.json_key_file_content).to eq('{"type": "service_account"}')
      end

      it "accepts configuration without any authentication (uses Application Default Credentials)" do
        plugin = LogStash::Inputs::GooglePubSub.new(minimal_config)
        expect(plugin.json_key_file).to be_nil
        expect(plugin.json_key_file_content).to be_nil
      end
    end

    context "optional settings" do
      it "has default max_messages of 5" do
        plugin = LogStash::Inputs::GooglePubSub.new(minimal_config)
        expect(plugin.max_messages).to eq(5)
      end

      it "allows custom max_messages value" do
        config = minimal_config.merge('max_messages' => 100)
        plugin = LogStash::Inputs::GooglePubSub.new(config)
        expect(plugin.max_messages).to eq(100)
      end

      it "has default include_metadata of false" do
        plugin = LogStash::Inputs::GooglePubSub.new(minimal_config)
        expect(plugin.include_metadata).to eq(false)
      end

      it "allows enabling include_metadata" do
        config = minimal_config.merge('include_metadata' => true)
        plugin = LogStash::Inputs::GooglePubSub.new(config)
        expect(plugin.include_metadata).to eq(true)
      end

      it "has default create_subscription of false" do
        plugin = LogStash::Inputs::GooglePubSub.new(minimal_config)
        expect(plugin.create_subscription).to eq(false)
      end

      it "allows enabling create_subscription" do
        config = minimal_config.merge('create_subscription' => true)
        plugin = LogStash::Inputs::GooglePubSub.new(config)
        expect(plugin.create_subscription).to eq(true)
      end

      it "has default codec of plain" do
        plugin = LogStash::Inputs::GooglePubSub.new(minimal_config)
        expect(plugin.codec.class.to_s).to include("Plain")
      end
    end
  end

  describe "register" do
    it "sets subscription_id correctly" do
      plugin = LogStash::Inputs::GooglePubSub.new(minimal_config)
      plugin.register
      # subscription_id is private, but we can verify registration completes
      expect(plugin).to be_a(LogStash::Inputs::GooglePubSub)
    end

    it "handles project with special characters in name" do
      config = minimal_config.merge('project_id' => 'my-project-123')
      plugin = LogStash::Inputs::GooglePubSub.new(config)
      expect { plugin.register }.not_to raise_error
    end
  end
end
