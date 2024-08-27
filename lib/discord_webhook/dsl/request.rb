class DiscordWebhook
  AllowedMentions = Struct.new(:parse, :roles, :users)
  
  class Request
    attr_accessor :content, :username, :avatar_url, :tts, :thread_name,
                  :embeds, :attachments, :components, :allowed_mentions,
                  :flags, :payload_json, :files, :poll

    def self.from_json(...)
      new **JSON.parse(...)
    end

    def self.from_message(message)
      request = self.new

      # A discord message doesn't track the url used for the author image so we're forced to leave it as default.
      request.content     = message.content.dup
      request.username    = message.author.username.dup
      request.tts         = message.tts.dup # should be the singleton true or false but we'll dup for parity with the surrounding code.
    # request.thread_name = message.channel_id.dup
      request.embeds      = message.embeds.map(&:dup)
      request.attachments = message.attachments.map(&:dup)
    # request.poll        = message.poll

      request
    end

    def initialize(**data)
      data = data.transform_keys(&:to_sym)
      
      @content          = data[:content]
      @username         = data[:username]
      @avatar_url       = data[:avatar_url]
      @tts              = data[:tts]
      @embeds           = data[:embeds]          &.map  { Embed          .new(**_1.to_h) } 
      @attachments      = data[:attachments]     &.map  { Attachment     .new(**_1.to_h) }
      @allowed_mentions = data[:allowed_mentions]&.then { AllowedMentions.new(**_1.to_h) } # If this is set, it will override Discord's default behavior. Arguably, that might be a good thing.
      @poll             = data[:poll]            &.then { Poll           .new(**_1.to_h) }
      @flags            = data[:flags]
      @thread_name      = data[:thread_name]
      @files            = data[:files]
      @applied_tags     = data[:applied_tags]
    end

    def [](value)
      instance_variable_get("@#{value}")
    end

    def raw
      DiscordWebhook.generate_request(to_h)
    end

    def embed(**kwargs, &block)
      e = Embed.new(**kwargs)
      
      block.call(e) if block_given?
      
      @embeds << e
    end

    def to_h
      {
        :content          => @content,
        :username         => @username,
        :avatar_url       => @avatar_url,
        :tts              => @tts,
        :embeds           => @embeds&.map(&:to_h),
        :allowed_mentions => @allowed_mentions&.to_h,
        :attachments      => @attachments&.map(&:to_h),
        :poll             => @poll&.to_h,
        :flags            => @flags,
        :thread_name      => @thread_name,
        :files            => @files
      }
    end
    alias to_hash to_h

    def to_json(*args)
      to_h.to_json(*args)
    end
  end # Request
end #Webhook
