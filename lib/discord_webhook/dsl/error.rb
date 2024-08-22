class DiscordWebhook
	class RequestError < StandardError
		def initialize(**data)
			@data = data
			super(@data.to_s)
		end

    def to_h
      @data.dup
    end
    alias to_hash to_h

		def [](value)
			@data[value]
	  end

    def decontruct_keys(...)
      to_h
    end
	end # RequestError
end
