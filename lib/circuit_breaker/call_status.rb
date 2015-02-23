class CircuitBreaker
  class CallStatus
    attr_accessor :status

    def initialize(options={})
      @status = options.fetch(:status)
    end

    def failed?
      @status == :failure
    end

    def succeeded?
      @status == :success
    end
  end
end
