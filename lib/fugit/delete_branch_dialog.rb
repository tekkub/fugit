include Wx

module Fugit
	class DeleteBranchDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Delete branches", :size => Size.new(250, 300))

			@branch_list = CheckListBox.new(self, ID_ANY)

			butt_sizer = create_button_sizer(OK|CANCEL)
			butt_sizer.get_children.map {|s| s.get_window}.compact.each {|b| b.set_label("Delete") if b.get_label == "OK"}
			evt_button(get_affirmative_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(StaticText.new(self, ID_ANY, "Select branches:"), 0, EXPAND|ALL, 4)
			box.add(@branch_list, 1, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(butt_sizer, 0, EXPAND|BOTTOM, 4)

			self.set_sizer(box)
		end

		def show
			branches = `git branch`
			branches = branches.split("\n").reject {|b| b[0..0] == "*"}.map {|b| b.strip}
			@branch_list.set(branches)

			super
		end

		def on_ok
			unmerged = `git branch --no-merged`
			unmerged.split("\n").map {|b| b.strip}

			branches = @branch_list.get_checked_items.map {|i| @branch_list.get_string(i)}
			unless (unmerged_to_delete = branches.reject {|b| !unmerged.include?(b)}).empty?
				dialog = MessageDialog.new(self, "These branches are not merged into the current HEAD:\n    #{unmerged_to_delete.join("\n    ")}\n\nDeleting them may cause data loss, continue?",
					"Unmerged branches", YES_NO|ICON_EXCLAMATION)
				return if dialog.show_modal != ID_YES
			end
			`git branch -D #{branches.join(" ")} 2>&1`

			send_message(:branch_deleted)

			end_modal(ID_OK)
		end

	end
end
