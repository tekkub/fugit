include Wx

module Fugit
	class MergeDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Merge branches", :size => Size.new(250, 300))

			@branch_list = CheckListBox.new(self, ID_ANY)

			butt_sizer = create_button_sizer(OK|CANCEL)
			butt_sizer.get_children.map {|s| s.get_window}.compact.each {|b| b.set_label("Merge") if b.get_label == "OK"}
			evt_button(get_affirmative_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(StaticText.new(self, ID_ANY, "Select branches:"), 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@branch_list, 1, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(butt_sizer, 0, EXPAND|BOTTOM, 4)

			self.set_sizer(box)
		end

		def show
			branches = `git branch --no-merged`
			branches = branches.split("\n").map {|b| b.strip}
			@branch_list.set(branches)

			super
		end

		def on_ok
			branches = @branch_list.get_checked_items.map {|i| @branch_list.get_string(i)}
			command = "git merge #{branches.join(" ")}"

			self.end_modal(ID_OK)

			@log_dialog ||= LoggedDialog.new(self, "Pushing branches")
			@log_dialog.show
			@log_dialog.run_command(command)
		end

	end
end
