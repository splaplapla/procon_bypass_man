class ProconBypassMan::Bypass::ProconReadThrottling
  class TokenGenerator
    def initialize
      @tokens = [0, 1]
      @token_index = 0
      @cycle_index = 0
    end

    def current
      @tokens[@token_index]
    end

    def next
      @cycle_index += 1
      if @cycle_index > ONE_CYCLE
        @token_index += 1
        @cycle_index = 0
      end

      if(token = @tokens[@token_index])
        return token
      else
        @token_index = 0
        return @tokens[@token_index]
      end
    end
  end

  ONE_CYCLE = 71

  def initialize
    @step = (1.0 / ONE_CYCLE).floor(3) # 0.013
    @token_generator = TokenGenerator.new
    @table = ONE_CYCLE.times.reduce({}) do |acc, index|
      acc[(index*@step).floor(3)...(@step*(index+1)).floor(3)] = @token_generator.current
      next(acc)
    end
    @table[(@table.keys.last.last)..1.0 ] = @token_generator.current # 0.936..1.0
    @range_list = @table.keys
  end
  class AlreadyExecutedError < StandardError; end

  def run(&block)
    begin
      current_sec  = generate_current_position
      range_key, current_token = @table.each do |range_key, value|
        break([range_key, value]) if range_key.include?(current_sec)
      end

      list_index = @range_list.index(range_key)
      next_token_of_table = @table[@range_list[list_index + 1]] or (force_do_call = true)
      if (current_token == next_token_of_table) || force_do_call
        block.call
        @table[range_key] = @token_generator.next
        wait = range_key.last - current_sec
        sleep(wait)
      else
        wait = range_key.last - current_sec
        sleep(wait)
        run(&block)
        # raise AlreadyExecutedError
      end
    rescue AlreadyExecutedError
      retry
    end
  end

  private

  def generate_current_position
    time = Time.now
    (time.usec).floor(5) /1_000_000.0
  end
end
