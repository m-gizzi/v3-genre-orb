# frozen_string_literal: true

RSpec.shared_context 'with a stubbed retryable error' do
  let(:exception) { Struct.new(:headers).new({ retry_after: '1' }) }
  let(:error) { error_class.new(exception) }
  let(:error_class) { raise 'Must set an error_class to use this shared context' }
  let(:recipient) { raise 'Must set an recipient to use this shared context' }
  let(:message) { raise 'Must set an message to use thisshared context' }

  before do
    call_count = 0
    method = recipient.method(message)

    allow(recipient).to receive(message) do |args|
      call_count += 1
      call_count == 1 ? raise(error) : call_original_method(method, args)
    end
  end

  def call_original_method(method, args)
    return method.call if args.blank?

    if args.is_a?(Hash)
      method.call(**args)
    else
      method.call(args)
    end
  end
end
