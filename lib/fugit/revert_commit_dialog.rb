include Wx

module Fugit
	class RevertCommitDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Revert commit", :size => Size.new(300, 120))

			@name = TextCtrl.new(self, ID_ANY)

			@commit_check = CheckBox.new(self, ID_ANY)
			@commit_check.set_label("&Commit")
			@commit_check.set_tool_tip("Commit the results of the revert")

			butt_sizer = create_button_sizer(OK|CANCEL)
			butt_sizer.get_children.map {|s| s.get_window}.compact.each {|b| b.set_label("Create") if b.get_label == "OK"}
			evt_button(get_affirmative_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(StaticText.new(self, ID_ANY, "Ref:"), 0, EXPAND|ALL, 4)
			box.add(@name, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@commit_check, 1, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(butt_sizer, 0, EXPAND|BOTTOM, 4)

			self.set_sizer(box)
		end

		def show(ref = "HEAD")
			@name.set_value(ref)
			@commit_check.set_value(true)

			super()
			@name.set_focus
		end

		def on_ok
			ref = @name.get_value

			opts = {:no_edit => true}
			opts[:no_commit] = true unless @commit_check.is_checked
			repo.git.revert(opts, ref)

			if repo.git.last_status.success?
				send_message(:commit_saved)
				end_modal(ID_OK)
			else
				MessageDialog.new(self, repo.git.last_err, "Error reverting commit", OK|ICON_ERROR).show_modal
			end
		end

	end
end
