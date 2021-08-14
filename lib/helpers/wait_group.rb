# frozen_string_literal: true

module Fetch
  module Helper
    class WaitGroup
      def initialize
        @count = 0
        @done = false
        @cond = ConditionVariable.new
        @lock = Mutex.new
      end

      def add(n = 1)
        @lock.synchronize do
          @count += n
        end
      end

      def done(n = 1)
        @lock.synchronize do
          @count -= n
          if @count.zero?
            @done = true
            @cond.broadcast
          end
        end
      end

      def wait
        @lock.synchronize do
          @cond.wait(@lock) until @done
        end
      end
    end
  end
end
