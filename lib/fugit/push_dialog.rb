include Wx

module Fugit
	class PushDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Push branches", :size => Size.new(250, 300))

			@branch_list = CheckListBox.new(self, ID_ANY)
			@tag_check = CheckBox.new(self, ID_ANY)
			@tag_check.set_label("Include &tags")
			@force_check = CheckBox.new(self, ID_ANY)
			@force_check.set_label("&Force update")
			@remote = ComboBox.new(self, ID_ANY)

			butt_sizer = create_button_sizer(OK|CANCEL)
			butt_sizer.get_children.map {|s| s.get_window}.compact.each {|b| b.set_label(b.get_label == "OK" ? "Push" : "Close")}
			evt_button(get_affirmative_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(StaticText.new(self, ID_ANY, "Push to:"), 0, EXPAND|ALL, 4)
			box.add(@remote, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(StaticText.new(self, ID_ANY, "Select branches:"), 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@branch_list, 1, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@tag_check, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@force_check, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(butt_sizer, 0, EXPAND|BOTTOM, 4)

			self.set_sizer(box)
		end

		def show
			branches = `git branch`
			remotes = `git remote`
			@remote.clear
			remotes = remotes.split("\n")
			remotes.each {|r| @remote.append(r)}
			@remote.set_value(remotes.include?("origin") ? "origin" : remotes[0])
			current = branches.match(/\* (.+)/).to_a.last
			branches = branches.split("\n").map {|b| b.split(" ").last}
			@branch_list.set(branches)
			@branch_list.check(@branch_list.find_string(current)) if current

			super
		end

		def on_ok
			branches = @branch_list.get_checked_items.map {|i| @branch_list.get_string(i)}
			tags = @tag_check.is_checked ? "--tags " : ""
			force = @force_check.is_checked ? "--force " : ""
			remote = @remote.get_value
			command = "git push #{tags}#{force}#{remote} #{branches.join(" ")}"

			self.end_modal(ID_OK)

			@log_dialog ||= LoggedDialog.new(self, "Pushing branches")
			@log_dialog.show
			@log_dialog.run_command(command)
		end

	end
end
