# frozen_string_literal: true

begin
  gem "omniauth", ">= 1.0.0"

  require "omniauth"
rescue LoadError
  warn "Could not load 'omniauth'. Please ensure you have the omniauth gem >= 1.0.0 installed and listed in your Gemfile."
  raise
end

# Clean up the default path_prefix. It will be automatically set by Devise.
OmniAuth.config.path_prefix = nil

OmniAuth.config.on_failure = Proc.new do |env|
  message_key = env['omniauth.error.type']
  origin_query_param = env['omniauth.origin'] ? "&origin=#{CGI.escape(env['omniauth.origin'])}" : ''
  strategy_name_query_param = env['omniauth.error.strategy'] ? "&strategy=#{env['omniauth.error.strategy'].name}" : ''
  extra_params = env['omniauth.params'] ? "&#{env['omniauth.params'].to_query}" : ''
  new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{message_key}#{origin_query_param}#{strategy_name_query_param}#{extra_params}"
  Rack::Response.new(['302 Moved'], 302, 'Location' => new_path).finish
end

module Devise
  module OmniAuth
    autoload :Config,      "devise/omniauth/config"
    autoload :UrlHelpers,  "devise/omniauth/url_helpers"
  end
end
