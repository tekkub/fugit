include Wx

module Fugit
	class Console < Panel
		attr_accessor :input, :output

		def initialize(parent)
			super(parent, ID_ANY)

			@input = TextCtrl.new(self, ID_ANY, nil, nil, Size.new(20, 20), TE_PROCESS_ENTER)
			@output = TextCtrl.new(self, ID_ANY, nil, nil, Size.new(20, 20), NO_BORDER|TE_MULTILINE|TE_READONLY|TE_DONTWRAP)

			box = BoxSizer.new(VERTICAL)
			box.add(@output, 1, EXPAND)
			box.add(@input, 0, EXPAND)
			self.set_sizer(box)

			evt_text_enter(@input.get_id(), :on_run_command)
		end

		def on_run_command(event)
			cmd = @input.get_value
			begin
				result = IO.popen(cmd).readlines
				@output.append_text("> #{cmd}\n#{result}\n")
			rescue
				@output.append_text("> #{cmd}\nThere was an error running the command\n")
			end
			@input.clear
		end

	end
end
