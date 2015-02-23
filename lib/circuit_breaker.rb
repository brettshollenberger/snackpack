# CircuitBreaker Pattern
#
# http://martinfowler.com/bliki/CircuitBreaker.html
#
# Stop calling unresponsive service if it continues to fail over several subsequent requests
#
class CircuitBreaker
  attr_accessor :invocation_timeout, :failure_threshold, :monitor

  def initialize(options={}, &block)
    @circuit            = block
    @invocation_timeout = options.fetch(:timeout, 5)
    @failure_threshold  = options.fetch(:failure_threshold, 5)
    # @monitor          = acquire_monitor
    reset
  end

  # Public: When circuit breaker is not tripped, attempt remote call; if tripped, or timeout, 
  # bubble up a timeout to the caller
  def call(*params)
    case state
    when :closed
      begin
        do_call(*params)
      rescue Timeout::Error
        record_failure
        raise $!
      end
    when :open then raise Timeout::Error
    else raise "Unreachable Code"
    end
  end

  def state
    (@failure_count >= @failure_threshold) ? :open : :closed
  end

private
  # Private: Attempt remote call; reset failure_count if successful
  def do_call(*params)
    result = Timeout::timeout(@invocation_timeout) do
      @circuit.call(*params)
    end

    reset
    result
  end

  def record_failure
    @failure_count += 1
  end

  def reset
    @failure_count = 0
  end
end
