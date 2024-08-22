class DiscordWebhook
  class EmbedBuilder
    DEFAULTS = {
      'type'        => 'rich',
      'title'       => '',
      'author'      => { name: '', url: '', icon_url: ''},
      'url'         => '',
      'description' => '',
    # 'color'       => 0x00000, # We don't define this key in order to use Discord's default
      'fields'      => [],
      'thumbnail'   => { url:  '' },
      'image'       => { url:  '' },
      'footer'      => { text: '', icon_url: '' },
    }

    COLORS = {
      # offical Discord colors from: https://discord.com/branding
      blurple: 0x5865F2,
      green:   0x57F287,
      yellow:  0xFEE75C,
      fuchsia: 0xEB459E,
      red:     0xED4245,
      white:   0xFFFFFF,
      black:   0x000000,
      
      # other colors
      ruby:    0xCC342D,
    }.tap { _1.default_proc = proc { |h, k| k }}

    def initialize(embed=nil, **kwargs)
      defaults = DEFAULTS.transform_values(&:dup).merge(kwargs)
      
      @embed = embed || Embed.new(**defaults)
    end
  
    [:title, :url, :description,].each do |field|
      define_method(field) do |**kwargs|
        case kwargs
        in { is: value } then @embed.send("#{field}=", value)
        in {           } then @embed.send("#{field}")
        end
      end
    end

    def color(**kwargs)
      case kwargs
      in { is: value } then @embed.color = COLORS[value]
      in {           } then @embed.color
      end
    end

    def author(**kwargs)
      case kwargs
      in { name: String } | { url: String } | { icon_url: String }
        @embed.author = Embed::Author.new(**kwargs)
      in { is:   value  }
        @embed.author = Embed::Author.new(**value.to_h)
      in {              }
        @embed.author
      end
    end

    def image(**kwargs)
      case kwargs
      in { url: } then @embed.image = Embed::Image.new(url:)
      in {      } then @embed.image
      end
    end

    def thumbnail(**kwargs)
      case kwargs
      in { url: } then @embed.thumbnail = Embed::Thumbnail.new(url:)
      in {      } then @embed.thumbnail
      end
    end

    def footer(**kwargs)
      case kwargs
      in { text: String } | { icon_url: String }
        @embed.footer = Embed::Footer.new(**kwargs)
      in {              }
        @embed.footer
      end
    end

    def field(name:, value:, inline: false)
      @embed.fields << Embed::Field.new(name, value, inline)
    end

    def replace(**kwargs)
      case kwargs
      in { author:    args } then @embed.author
      in { field:,  **args } then @embed.fields[field]
      in { thumbnail: args } then @embed.thumbnail
      in { image:     args } then @embed.image
      in { footer:    args } then @embed.footer
      in {          **args } then @embed            
      end => context

      args.each { |key, value| context.send("#{key}=", value) }

      context
    end
  end
end
