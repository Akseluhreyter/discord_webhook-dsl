require_relative 'request_builder'

class DiscordWebhook
  alias __post post
  alias __execute execute

  def post(*, **, &)    
    request_builder = RequestBuilder.new(*, &)

    __post(request_builder.build, **)
  end # post

  alias execute post
end # Webhook
