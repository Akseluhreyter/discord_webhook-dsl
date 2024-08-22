class DiscordWebhook
  # https://discord.com/developers/docs/resources/channel#message-object
  class Message
    User = Struct.new(:bot, :id, :username, :avatar, :discriminator,
                      :public_flags, :flags, :global_name, :clan)

    attr_reader :id, :type, :content, :channel_id, :author, :attachments,
                :components, :embeds, :mentions, :mention_roles, :pinned,
                :mention_everyone, :tts, :timestamp, :edited_timestamp,
                :flags, :webhook_id

    def initialize(**data)    
      @id               = data[:id]
      @type             = data[:type]
      @content          = data[:content]
      @channel_id       = data[:channel_id]
      @author           = data[:author]&.then { User.new(**data['author']) }
      @attachments      = data[:attachments].map { |a| Attachment.new(**a) }
      @components       = data[:components] # should always be an empty array.
      @embeds           = data[:embeds].map { |e| Embed.new(**e) }
      @mentions         = data[:mentions]
      @mention_roles    = data[:mention_roles]
      @pinned           = data[:pinned]
      @mention_everyone = data[:mention_everyone]
      @tts              = data[:tts]
      @timestamp        = data[:timestamp].then { |t| Time.parse(t) }
      @edited_timestamp = data[:edited_timestamp]&.then { |t| Time.parse(t) }
      @flags            = data[:flags]
      @webhook_id       = data[:webhook_id]
    end

    # TODO: Message and its internals should probably be frozen
    # Maybe we should use Data.define instead?
    #def freeze
    #end

    def pinned?
      @pinned
    end

    def [](value)
      instance_variable_get("@#{value}")
    end

    def to_h
      {
        :id               => @id,
        :type             => @type,
        :content          => @content,
        :channel_id       => @channel_id,
        :author           => @author.to_h,
        :attachments      => @attachments.map(&:to_h),
        :components       => @components.map(&:to_h),
        :embeds           => @embeds.map(&:to_h),
        :mentions         => @mentions.map(&:to_h),
        :mention_roles    => @mention_roles.map(&:to_h),
        :pinned           => @pinned,
        :mention_everyone => @mention_everyone,
        :tts              => @tts,
        :timestamp        => @timestamp.to_s,        # I'm not entirely convinced these Time objects should be made into
        :edited_timestamp => @edited_timestamp.to_s, # Strings, but this keeps parity with a default JSON#parse
        :flags            => @flags,      
        :webhook_id       => @webhook_id,             
      }
    end
    alias to_hash to_h

    def decontruct_keys(...)
      to_h
    end

    def to_json(*args)
      to_h.to_json(*args)
    end
  end # Message
end #Webhook
