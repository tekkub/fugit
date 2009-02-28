include Wx

module Fugit
	class LoggedDialog < Dialog
		def initialize(parent, title)
			super(parent, ID_ANY, title, :size => Size.new(600, 300))

			@log = TextCtrl.new(self, ID_ANY, :size => Size.new(20, 150), :style => TE_MULTILINE|TE_DONTWRAP|TE_READONLY)
			@current_line = StaticText.new(self, ID_ANY, "")
			@progress = Gauge.new(self, ID_ANY, 100, :size => Size.new(20, 20))

			box = BoxSizer.new(VERTICAL)
			box.add(@log, 1, EXPAND|TOP|LEFT|RIGHT, 4)
			box.add(@current_line, 0, EXPAND|ALL, 4)
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
				last_cr = true
				while (line = io.get_line)
					@log.append_text(@current_line.get_label) unless last_cr
					@current_line.set_label(line)
					@progress.pulse
					last_cr = (line[-1..-1] == "\r")
				end
			end
			@progress.set_value(0)
			if $?.success? && close_on_success
				@log.append_text(@current_line.get_label)
				@current_line.set_label("This window will close in 5 seconds")
				Timer.after(5000) {self.end_modal(ID_OK)}
			end
		end

	end
end
