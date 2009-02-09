
module Wx
	class EvtHandler
		def register_for_message(message, method = nil, &block)
			raise "Must pass method or block" unless block || method

			block ||= Proc.new {|*args| self.send(method, *args)}
			@@message_blocks ||= {}
			@@message_blocks[message] ||= []
			@@message_blocks[message] << block
		end

		def send_message(message, *args)
			blocks = @@message_blocks[message] || []
			blocks.each {|block| block.call(*args)}
		end

	end
end

