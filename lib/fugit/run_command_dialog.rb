include Wx

module Fugit
	class RunCommandDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Run command", :size => Size.new(300, 100))

			@cmd = TextCtrl.new(self, ID_ANY)

			butt_sizer = create_button_sizer(OK|CANCEL)
			butt_sizer.get_children.map {|s| s.get_window}.compact.each {|b| b.set_label("Run") if b.get_label == "OK"}
			evt_button(get_affirmative_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(StaticText.new(self, ID_ANY, "Command:"), 0, EXPAND|ALL, 4)
			box.add(@cmd, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(butt_sizer, 0, EXPAND|BOTTOM, 4)

			self.set_sizer(box)
		end

		def show()
			@cmd.set_value("")

			super()
			@cmd.set_focus
		end

		def on_ok
			command = @cmd.get_value

			end_modal(ID_OK)

			@log_dialog ||= LoggedDialog.new(self, "Run command")
			@log_dialog.show
			@log_dialog.run_command(command)
		end

	end
end
