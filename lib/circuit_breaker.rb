require "circuit_breaker/call_status"

class CircuitBreaker
  class Open < StandardError; end

  attr_accessor :circuit, :timeout, :recent_calls, :failure_count, :failure_threshold, :recent_count, 
                :recent_minimum, :reset_timeout, :last_failure_time, :test_time

  def initialize(options={}, &block)
    @circuit           = block
    @timeout           = options.fetch(:timeout, 0.01)
    @failure_threshold = options.fetch(:failure_threshold, 0.3)
    @recent_minimum    = options.fetch(:recent_minimum, 10)
    @recent_count      = options.fetch(:recent_count, 100)
    @reset_timeout     = options.fetch(:reset_timeout, 0.1)
    @recent_calls      = []
    @failure_count     = 0
  end

  # Public: Wrap calls to a protected method in the circuit breaker
  #
  # For calls that might fail for one reason or another (such as remote calls), the circuit breaker avoids overloading
  # the system with long delays when the calls are primarily failing.
  #
  # If the circuit breaker is :closed (mostly successful calls) or :half_open (testing whether it can become closed again),
  # it makes the protected call.
  #
  # If the circuit breaker is :open (mostly failed calls), then it alerts the caller that it will not make the call until
  # the reset_timeout, by raising CircuitBreaker::Open.
  #
  # When more time has passed since the most recent failure than the reset_timeout, the circuit tentatively becomes :half_open,
  # allowing an additional remote call. If the call succeeds, the circuit will remain :half_open until either enough calls succeed
  # to become :closed, or another call fails, resetting the reset_timeout.
  #
  def call(*args)
    case status
    when :closed, :half_open
      begin
        do_call(*args).tap do
          record_success
        end
      rescue Timeout::Error
        record_failure
        raise $!
      end
    when :open
      raise Open
    else
      raise "Unreachable Code"
    end
  end

  # Public: Wrap the remote call in a timeout.
  #
  # If the timeout passes, record a failure and bubble up the timeout error
  #
  def do_call(*args)
    result = Timeout::timeout(timeout) do
      circuit.call(*args)
    end

    result
  end

  # Public: The status of the circuit breaker
  #
  # If a minimum number of remote calls have been made (recent_calls > recent_minimum) 
  # and the percentage of recent calls that failed passes the failure threshold (a percentage),
  # then the circuit is :open, unless enough time has passed since the most recent failure, in which case
  # it is :half_open (ready to attempt another remote call).
  #
  # If enough remote calls have not been made to determine an :open or :half_open status, or 
  # enough remote calls have been successful, then the status is :closed.
  def status
    if recent_calls.count >= recent_minimum && percent_failed >= failure_threshold
      if (current_time - last_failure_time) > reset_timeout
        :half_open
      else
        :open
      end
    else
      :closed
    end
  end

  # Public: The percentage of recent_calls that failed
  #
  # The creator of the circuit breaker determines how many recent calls should be checked
  #
  # For example, if 30% of the most recent 50 calls failed, then the circuit should be :open
  def percent_failed
    if recent_calls.count == 0
      0
    else
      (recent_calls.select(&:failed?).count / recent_calls.count.to_f)
    end
  end

private
  def record_failure
    @failure_count += 1
    @last_failure_time = Time.now
    add_recent_call :failure
  end

  def record_success
    add_recent_call :success
  end

  def add_recent_call(status)
    recent_calls.push(CallStatus.new(status: status))

    recent_calls.shift if recent_calls.count > recent_count
  end

  def current_time
    @test_time || Time.now
  end
end
