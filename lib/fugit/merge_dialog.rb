include Wx

module Fugit
	class MergeDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Merge branches", :size => Size.new(250, 300))

			@branch_list = CheckListBox.new(self, ID_ANY)
			@log_check = CheckBox.new(self, ID_ANY)
			@log_check.set_label("Include commit &log")
			@log_check.set_tool_tip("Adds a log of commit summaries to the merge commit's message")
			@commit_check = CheckBox.new(self, ID_ANY)
			@commit_check.set_label("&Commit result")
			@commit_check.set_tool_tip("If there are no merge conficts, commit the results automatically.")
			@squash_check = CheckBox.new(self, ID_ANY)
			@squash_check.set_label("&Squash result")
			@squash_check.set_tool_tip("Instead of creating a merge commit, squash all of\nthe changes together and stage them for commit.\nThis will create the same changeset a normal\nmerge would, without creating a merge commit.")
			@noff_check = CheckBox.new(self, ID_ANY)
			@noff_check.set_label("&Fast-forward when possible")
			@noff_check.set_tool_tip("Do not generate a merge commit if the merge resolved as a fast-forward, only update the branch pointer.")

			butt_sizer = create_button_sizer(OK|CANCEL)
			butt_sizer.get_children.map {|s| s.get_window}.compact.each {|b| b.set_label("Merge") if b.get_label == "OK"}
			evt_button(get_affirmative_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(StaticText.new(self, ID_ANY, "Select branches:"), 0, EXPAND|ALL, 4)
			box.add(@branch_list, 1, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@log_check, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@commit_check, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@squash_check, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@noff_check, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(butt_sizer, 0, EXPAND|BOTTOM, 4)

			self.set_sizer(box)
		end

		def show
			branches = `git branch --no-merged`
			branches = branches.split("\n").map {|b| b.strip}
			@branch_list.set(branches)

			@log_check.set_value(false)
			@commit_check.set_value(true)
			@squash_check.set_value(false)
			@noff_check.set_value(true)

			super
		end

		def on_ok
			branches = @branch_list.get_checked_items.map {|i| @branch_list.get_string(i)}
			args = []
			args << "--log" if @log_check.is_checked
			args << "--no-commit" unless @commit_check.is_checked || @squash_check.is_checked
			args << "--squash" if @squash_check.is_checked
			args << "--no-ff" unless @noff_check.is_checked
			command = "git merge #{args.empty? ? "" : "#{args.join(" ")} "}#{branches.join(" ")}"

			self.end_modal(ID_OK)

			@log_dialog ||= LoggedDialog.new(self, "Merging branches")
			@log_dialog.show
			@log_dialog.run_command(command)
		end

	end
end
