require_relative 'boot'

require 'rails/all'
require 'salesforce_bulk'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AngularExample
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
        address:              'smtp.gmail.com',
        port:                 587,
        domain:               'enzigma.in',
        user_name:            'monika.pingale@enzigma.in',
        password:             'arya@1994',
        authentication:       'plain',
        enable_starttls_auto: true  }
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
