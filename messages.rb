
module Wx
	class EvtHandler
		def register_for_message(message, method = nil, &block)
			raise "Must pass method or block" unless block || method

			block ||= Proc.new {self.send(method)}
			@@message_blocks ||= {}
			@@message_blocks[message] ||= []
			@@message_blocks[message] << block
		end

		def send_message(message)
			blocks = @@message_blocks[message] || []
			blocks.each {|block| block.call}
		end

	end
end

