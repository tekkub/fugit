include Wx

module Fugit
	class FetchDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Fetch remotes", :size => Size.new(250, 300))

			@remotes = CheckListBox.new(self, ID_ANY)
			@tag_check = CheckBox.new(self, ID_ANY)
			@tag_check.set_label("Include &tags")

			butt_sizer = create_button_sizer(OK|CANCEL)
			butt_sizer.get_children.map {|s| s.get_window}.compact.each {|b| b.set_label(b.get_label == "OK" ? "Fetch" : "Close")}
			evt_button(get_affirmative_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(StaticText.new(self, ID_ANY, "Fetch from:"), 0, EXPAND|ALL, 4)
			box.add(@remotes, 1, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@tag_check, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(butt_sizer, 0, EXPAND|BOTTOM, 4)

			self.set_sizer(box)
		end

		def show
			remotes = `git remote`
			remotes = remotes.split("\n")
			@remotes.set(remotes)
			@remotes.check(@remotes.find_string("origin")) if remotes.include?("origin")
			@tag_check.set_value(true)

			super
		end

		def on_ok
			remotes = @remotes.get_checked_items.map {|i| @remotes.get_string(i)}
			tags = @tag_check.is_checked ? "" : "--no-tags "

			self.end_modal(ID_OK)

			@log_dialog ||= LoggedDialog.new(self, "Fetching remotes")
			@log_dialog.show
			remotes.each {|remote| @log_dialog.run_command("git fetch #{tags}#{remote}", remote == remotes.last)}
		end

	end
end
