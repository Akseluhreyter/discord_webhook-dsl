class DiscordWebhook
  alias __delete delete
  
	def delete(id_or_message, **)
		message_id =
      if id_or_message.is_a? Message
        id_or_message.id
      else
        id_or_message
      end

    __delete(message_id, **)
	end # delete
end
