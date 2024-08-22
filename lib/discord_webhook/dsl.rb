require 'net/http'
require 'json'
require 'time'

require 'discord_webhook'

require_relative 'dsl/request'
require_relative 'dsl/request_builder'
require_relative 'dsl/embed'
require_relative 'dsl/embed_builder'
require_relative 'dsl/poll_builder'
require_relative 'dsl/error'
require_relative 'dsl/handle_response'
require_relative 'dsl/message'

require_relative 'dsl/post'
require_relative 'dsl/get'
require_relative 'dsl/patch'
require_relative 'dsl/delete'

class DiscordWebhook
  Attachment =
  	Struct.new(
      :id, :filename, :description, :content_type, :size, :url, :proxy_url,
      :height, :width, :placeholder, :placeholder_version
    )
end # Webhook
