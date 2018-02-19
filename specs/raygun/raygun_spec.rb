require_relative '../spec_helper'
require 'stringio'

describe Raygun do
  let(:failsafe_logger) { FakeLogger.new }

  describe '#track_exception' do
    context 'send in background' do
      before do
        Raygun.setup do |c|
          c.send_in_background = true
          c.api_url = 'http://example.api'
          c.api_key = 'foo'
          c.debug = true
          c.failsafe_logger = failsafe_logger
        end
      end

      context 'request times out' do
        before do
          stub_request(:post, 'http://example.api/entries').to_timeout
        end

        it 'logs the failure to the failsafe logger' do
          error = StandardError.new

          Raygun.track_exception(error)

          failsafe_logger.get.must_match /Problem reporting exception to Raygun/
        end
      end
    end
  end
end
