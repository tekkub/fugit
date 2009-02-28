include Wx

module Fugit
	class LoggedDialog < Dialog
		def initialize(parent, title)
			super(parent, ID_ANY, title, :size => Size.new(600, 300))

			@log = TextCtrl.new(self, ID_ANY, :size => Size.new(20, 150), :style => TE_MULTILINE|TE_DONTWRAP|TE_READONLY)
			@progress = Gauge.new(self, ID_ANY, 100, :size => Size.new(20, 20))

			box = BoxSizer.new(VERTICAL)
			box.add(@log, 1, EXPAND|TOP|LEFT|RIGHT, 4)
			box.add(@progress, 0, EXPAND|ALL, 4)
			self.set_sizer(box)
		end

		def show()
			@progress.set_value(0)
			@log.clear
			super
		end

		def run_command(command, close_on_success = true)
			@log.append_text("#{@log.get_last_position == 0 ? "" : "\n"}> #{command}\n")

			ret = IO.popen("#{command} 2>&1") do |io|
				last_cr = nil
				while (line = io.get_line)
					this_cr = (line[-1..-1] == "\r")
					line = line[0..-2] if this_cr
					if last_cr
						@log.replace(@log.xy_to_position(0, @log.get_number_of_lines - 1), @log.get_last_position, line)
					else
						@log.append_text(line)
					end
					@progress.pulse
					last_cr = this_cr
				end
			end
			@progress.set_value(0)
			if $?.success? && close_on_success
				@log.append_text("\n\nThis window will close in 5 seconds\n")
				Timer.after(5000) {self.end_modal(ID_OK)}
			end
		end

	end
end
