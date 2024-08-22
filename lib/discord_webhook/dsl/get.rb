class DiscordWebhook
  alias __get get
  
  def get(id_or_message, **)
    message_id =
      if id_or_message.is_a? Message
        id_or_message.id
      else
        id_or_message
      end
  
    __get(message_id, **)
  end
end
