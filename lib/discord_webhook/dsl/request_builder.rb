class DiscordWebhook
  class RequestBuilder
    DEFAULTS = {
      :content          => '',
      :username         => nil,
      :avatar_url       => '',
      :tts              => false,
      :embeds           => [],
      :allowed_mentions => nil, # If this is set, it will override Discord's default behavior.
      :attachments      => [],
      :flag             => 0,
      :thread_name      => '',
      :files            => [],
    }
    
    def build
      @request.dup
    end
    
    def initialize(request=nil, **kwargs, &block)
      kwargs   = kwargs.transform_keys(&:to_sym)
      defaults = DEFAULTS.transform_values(&:dup).merge(kwargs)

      @request = Request.new(**defaults.merge(request.to_h))

      instance_eval(&block) if block_given?
    end

    def to_json(...)
      @request.to_json(...)
    end
    
    [:content, :username, :avatar_url, :thread_name].each do |field|
      define_method(field) do |**kwargs|
        case kwargs
        in { is: } then @request.instance_variable_set("@#{field}", is)
        in {     } then @request.instance_variable_get("@#{field}")
        end
      end
    end

    def tts(**kwargs)
      case kwargs
      in { is: } then @request.tts = is
      in {     } then @request.tts
      end
    end

    def flags(**kwargs)
      case kwargs
      in { is: } then @request.flags = is
      in {     } then @request.flags
      end
    end

    def replace(**kwargs, &)
      case kwargs
      in { embed:, **args }
        e = @request.embeds[embed]

        if e.nil?
          raise ArgumentError, "Embed at position #{embed} doesn't exist!"
        end
        
        eb = EmbedBuilder.new(e)

        eb.replace(**args)
        eb.instance_eval(&) if block_given?
        
        return e
      in { attachment:, **args } then @request.attachments[attachment]
      in { mention:       args } then @request.allowed_mention
      in {              **args } then @request
      end => context

      args.each do |k, v|
        context.send("#{k}=", v)
      end

      context
    end

    def files
      @request.files
    end

    def attachment(**kwargs)
      case kwargs
      in { is:                          } then @request.attachments << Attachment.new(**is.to_h)
      in { id:, filename:, description: } then @request.attachments << Attachment.new(**kwargs)
      end
    end

    def attachments
      @request.attachments
    end
           
    def attach(file:, name: nil, description: '')
      @request.files << File.read(file)
      @request.attachments << Attachment.new(
        id: @request.files.size - 1,
        filename: name || File.basename(file),
        description:
      )
    end

    def mention(**kwargs)
      @request.allowed_mentions = AllowedMentions.new(**kwargs)
    end

    def embeds
      @request.embeds
    end

    def embed(**kwargs, &block)
      builder = EmbedBuilder.new(**kwargs)

      builder.instance_eval(&block) if block_given?

      embed = builder.instance_variable_get(:@embed)

      @request.embeds << embed

      # The following is really a hack imo to facilitate grouping images in
      # embeds. Discord doesn't document this feature anywhere I'm aware of,
      # but nonetheless is commonly seen.
      #
      # The way it works is you can group up to 4 images in a "single" embed
      # if the embeds share a url value. In other words, each image is placed
      # into its own embed with its own url and image fields set.
      #
      # If the user set a embed's image url field to an array, it's assumed
      # they wish to group the images.
      if embed.image.url.is_a? Array      
        image, *rest = embed.image.url
        embed.image.url = image

        rest.each do |url|
          @request.embeds << Embed.new(url: embed.url, image: { url: })
        end
      end

      # It's important the embed builder is returned in order to not
      # break encapsulation.
      builder
    end

    def poll(question=nil, **kwargs, &block)
      kwargs[:question] = Poll::PollMedia.new(text: question)
      builder = PollBuilder.new(**kwargs)

      @request.poll = builder.build

      builder.instance_eval(&block) if block_given?
    end
  end # RequestBuilder
  #end
end
