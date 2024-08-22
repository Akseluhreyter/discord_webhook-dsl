class DiscordWebhook
  alias __patch patch
  alias __edit edit

  # Note: We can't forward positional args like we do with the other
  # endpoint methods because we might create a request from a Message
  # object
  def patch(id_or_message, request=nil, **, &)
    # Generate a request from a message or create a "blank" one so we 
    # can replace the message specified by the id
    
    if id_or_message.is_a? Message
      message_id = id_or_message.id

      # Create a request from the Message if we weren't passed one
      request ||= Request.from_message(id_or_message)
    else # Assume we're given something that behaves as the id
      message_id = id_or_message
    end

    request_builder = RequestBuilder.new(request, &)

    __patch(message_id, request_builder.build, **)
  end # patch

  alias edit patch
end
