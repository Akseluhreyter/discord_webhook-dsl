class DiscordWebhook
  class Poll
    PollMedia       = Struct.new(:emoji, :text) { def to_h = { emoji: emoji&.to_h, text: } }
    PollAnswer      = Struct.new(:answer_id, :poll_media) { def to_h = { answer_id:, poll_media: poll_media.to_h } }
    PollResults     = Struct.new(:is_finalized, :answer_counts)
    PollAnswerCount = Struct.new(:id, :count, :me_voted)

    Emoji = Struct.new(:id, :name, :roles, :user, :require_colons, :managed, :animated, :available)

    attr_accessor :question, :answers, :duration, :allow_multiselect,
                  :layout_type
    
    def initialize(**data)
      data = data.transform_keys(&:to_sym)

      @question          = data[:question].then { |question| PollMedia.new(**question.to_h) }
      
      @answers           = data[:answers]&.map do |answer|
                             answer_id, poll_media = answer.values.at(:answer_id, :poll_media)
                             PollAnswer.new(answer_id, PollMedia.new(**poll_media))
                           end
                           
      @duration          = data[:duration]
      @allow_multiselect = data[:allow_multiselect]
      @layout_type       = data[:layout_type]
    end

    def to_h
      {
        :question          => @question.to_h,
        :answers           => @answers.map(&:to_h),
        :duration          => @duration,
        :allow_multiselect => @allow_multiselect,
        :layout_type       => @layout_type,
      }
    end

    def to_json(...)
      to_h.to_json(...)
    end
  end

  class PollBuilder
    DEFAULTS = {
      :question          => Poll::PollMedia.new(text: ''),
      :answers           => [],
      :duration          => 24,
      :allow_multiselect => false,
      :layout_type       => 1,
    }

    CUSTOM_EMOJI = {}.tap { _1.default_proc = proc { |h, k| Poll::Emoji.new(name: k) }}
    
    def initialize(poll=nil, **kwargs, &block)
      defaults = DEFAULTS.transform_values(&:dup)
      kwargs   = kwargs.transform_keys(&:to_sym)
      
      @poll = Poll.new(**defaults.merge(kwargs)
                                 .merge(poll.to_h))

      instance_eval(&block) if block_given?
    end

    def build
      @poll.dup
    end

    def question(**kwargs)
      case kwargs
      in { is: }
        @question =  Poll::PollMedia.new(text: is)
      in {     }
        @question
      end
    end

    def answer(emoji: nil, text:)
      poll_media = Poll::PollMedia.new(emoji: CUSTOM_EMOJI[emoji], text:)
      
      @poll.answers <<  Poll::PollAnswer.new(poll_media:)
    end
  end 
end
