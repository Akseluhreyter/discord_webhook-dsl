class DiscordWebhook
  class Embed
    Author    = Struct.new(:url, :name, :icon_url, :proxy_icon_url)
    Field     = Struct.new(:name, :value, :inline)
    Image     = Struct.new(:url, :proxy_url, :height, :width)
    Thumbnail = Struct.new(:url, :proxy_url, :height, :width)
    Provider  = Struct.new(:url, :name)
    Video     = Struct.new(:url, :proxy_url, :height, :width)
    Footer    = Struct.new(:text, :icon_url, :proxy_icon_url)

    attr_accessor :type, :title, :url, :description, :color, :fields,
                  :author, :thumbnail, :image, :footer

    def self.from_json(string)
      new(**JSON.parse(string))
    end

    def initialize(**data)
      data = data.transform_keys(&:to_sym)
    
      @type        = data[:type]
      @title       = data[:title]
      @url         = data[:url]
      @description = data[:description]
      @color       = data[:color]       
      @fields      = data[:fields]     &.map  { Field    .new(**_1.to_h) } # to_h may appear unnecessary,
      @author      = data[:author]     &.then { Author   .new(**_1.to_h) } # however, this allows users
      @thumbnail   = data[:thumbnail]  &.then { Thumbnail.new(**_1.to_h) } # to pass Structs that don't
      @image       = data[:image]      &.then { Image    .new(**_1.to_h) } # have to_hash defined.
      @footer      = data[:footer]     &.then { Footer   .new(**_1.to_h) } #
    end

    def initialize_copy(original)
      initialize(**JSON.parse(original.to_json))
    end

    def [](value)
      instance_variable_get("@#{value}")
    end

    def to_h
      {
        :type        => @type,
        :title       => @title,
        :author      => @author.to_h,
        :url         => @url,
        :description => @description,
        :color       => @color,
        :fields      => @fields&.map(&:to_h),
        :thumbnail   => @thumbnail.to_h,
        :image       => @image.to_h,
        :footer      => @footer.to_h,
      }
    end
    alias to_hash to_h

    def to_json(*args)
      to_h.to_json(*args)
    end
  end # Embed
end # Webhook
