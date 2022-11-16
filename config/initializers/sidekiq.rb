# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username),
                                                ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_USERNAME', nil))) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password),
                                                  ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_PASSWORD', nil)))
  end
end
