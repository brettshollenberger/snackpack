require "rails_helper"
require "circuit_breaker"

describe CircuitBreaker do
  class LongRemoteCaller
    attr_accessor :circuit_breaker

    def initialize
      @circuit_breaker ||= CircuitBreaker.new(recent_count: 5, recent_minimum: 3) do |message|
        __call__(message)
      end
    end

    def call(message)
      begin
        @circuit_breaker.call(message)
      rescue Timeout::Error
        false
      end
    end

    def __call__(message)
      "#{message} processed"
    end
  end

  before(:each) do
    @remote_caller = LongRemoteCaller.new
  end

  it "processes the call under happy path circumstances" do
    expect(@remote_caller.call("Work")).to eq "Work processed"
  end

  it "adds a recent call to after success" do
    @remote_caller.call("Work")

    expect(@remote_caller.circuit_breaker.recent_calls.count).to eq 1
    expect(@remote_caller.circuit_breaker.recent_calls.last.status).to eq :success
  end

  it "adds to the failure count after an unsuccessful call" do
    allow(@remote_caller.circuit_breaker).to receive(:do_call).and_raise(Timeout::Error)

    expect { @remote_caller.call("Work") }.to change(@remote_caller.circuit_breaker, :failure_count).by(1)
  end

  it "adds a recent call after failure" do
    allow(@remote_caller.circuit_breaker).to receive(:do_call).and_raise(Timeout::Error)

    @remote_caller.call("Work")

    expect(@remote_caller.circuit_breaker.recent_calls.count).to eq 1
    expect(@remote_caller.circuit_breaker.recent_calls.last.status).to eq :failure
  end

  it "pushes out recent calls when greater than recent_count" do
    5.times do
      @remote_caller.call("Work")
    end

    expect(@remote_caller.circuit_breaker.recent_calls.count).to be 5

    @remote_caller.call("Work")

    expect(@remote_caller.circuit_breaker.recent_calls.count).to be 5
  end

  it "becomes open if the number of failures passes the threshold and there have been at least as many calls as the recent_minimum" do
    allow(@remote_caller.circuit_breaker).to receive(:do_call).and_raise(Timeout::Error)

    @remote_caller.call("Work")

    expect(@remote_caller.circuit_breaker.status).to eq :closed

    @remote_caller.call("Work")

    expect(@remote_caller.circuit_breaker.status).to eq :closed

    @remote_caller.call("Work")

    expect(@remote_caller.circuit_breaker.status).to eq :open
  end

  it "raises CircuitBreaker::Open if the breaker is open, rather than making the call" do
    allow(@remote_caller.circuit_breaker).to receive(:do_call).and_raise(Timeout::Error)

    3.times do
      @remote_caller.call("Work")
    end

    expect { @remote_caller.call("Work") }.to raise_error CircuitBreaker::Open
  end

  it "becomes :half_open after becoming :open && passing the reset timeout" do
    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(3).times.and_raise(Timeout::Error)

    3.times do
      @remote_caller.call("Work")
    end

    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(1).times.and_call_original

    @remote_caller.circuit_breaker.test_time = Time.now + 1.minute

    expect(@remote_caller.circuit_breaker.status).to be :half_open
  end

  it "calls the block when :half_open as a test" do
    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(3).times.and_raise(Timeout::Error)

    3.times do
      @remote_caller.call("Work")
    end

    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(1).times.and_call_original

    @remote_caller.circuit_breaker.test_time = Time.now + 1.minute

    expect(@remote_caller.call("Work")).to eq "Work processed"
  end

  it "is still :half_open after successful call" do
    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(3).times.and_raise(Timeout::Error)

    3.times do
      @remote_caller.call("Work")
    end

    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(1).times.and_call_original

    @remote_caller.circuit_breaker.test_time = Time.now + 1.minute

    @remote_caller.call("Work")

    expect(@remote_caller.circuit_breaker.status).to be :half_open
  end

  it "resets to :closed after enough successful calls to pass the failure_threshold" do
    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(3).times.and_raise(Timeout::Error)

    3.times do
      @remote_caller.call("Work")
    end

    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(4).times.and_call_original

    @remote_caller.circuit_breaker.test_time = Time.now + 1.minute

    3.times do
      @remote_caller.call("Work")
      expect(@remote_caller.circuit_breaker.status).to be :half_open
    end

    @remote_caller.call("Work")
    expect(@remote_caller.circuit_breaker.status).to be :closed
  end

  it "opens again if a call fails before becoming closed again" do
    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(3).times.and_raise(Timeout::Error)

    3.times do
      @remote_caller.call("Work")
    end

    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(3).times.and_call_original

    @remote_caller.circuit_breaker.test_time = Time.now + 0.1

    3.times do
      @remote_caller.call("Work")
      expect(@remote_caller.circuit_breaker.status).to be :half_open
    end

    allow(@remote_caller.circuit_breaker).to receive(:do_call).exactly(1).times.and_raise(Timeout::Error)

    @remote_caller.call("Work")

    expect(@remote_caller.circuit_breaker.status).to be :open
  end
end
