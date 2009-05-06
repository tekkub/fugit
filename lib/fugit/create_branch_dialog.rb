include Wx

module Fugit
	class CreateBranchDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Create branch", :size => Size.new(300, 185))

			@name = TextCtrl.new(self, ID_ANY)
			@refs = ComboBox.new(self, ID_ANY)

      @force_check = CheckBox.new(self, ID_ANY)
      @force_check.set_label("&Force")
      @force_check.set_tool_tip("Force the creation of a new branch even if it means deleting\na branch that already exists with the same name.")

      @checkout_check = CheckBox.new(self, ID_ANY)
      @checkout_check.set_label("&Checkout")
      @checkout_check.set_tool_tip("Checkout branch after creation.")

			butt_sizer = create_button_sizer(OK|CANCEL)
			butt_sizer.get_children.map {|s| s.get_window}.compact.each {|b| b.set_label("Create") if b.get_label == "OK"}
			evt_button(get_affirmative_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(StaticText.new(self, ID_ANY, "New branch name:"), 0, EXPAND|ALL, 4)
			box.add(@name, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(StaticText.new(self, ID_ANY, "Create at:"), 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@refs, 0, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@force_check, 1, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(@checkout_check, 1, EXPAND|LEFT|RIGHT|BOTTOM, 4)
			box.add(butt_sizer, 0, EXPAND|BOTTOM, 4)

			self.set_sizer(box)
		end

		def show(ref = "HEAD")
			branches = `git branch -a`
			branches = ["HEAD"] + branches.split("\n").map {|b| b[2..-1]}
			@refs.clear
			branches.each {|b| @refs.append(b)}
			@refs.set_value(ref)
			@name.set_value("")
			@force_check.set_value(false)

			super()
			@name.set_focus
		end

		def on_ok
			force = @force_check.is_checked ? "-f " : ""
			name = @name.get_value
			ref = @refs.get_value

			if name.strip.empty?
				@no_name_dialog ||= MessageDialog.new(self, "Cannot create branch without a name.", "No branch name", ICON_EXCLAMATION)
				@no_name_dialog.show_modal
				return
			end

			err = `git branch #{force}#{name} #{ref} 2>&1`

			if err.empty?
			  if @checkout_check.is_checked
    			success, err = repo.checkout(name)
    			if success
    				send_message(:branch_checkout)
  				  end_modal(ID_OK)
    			else
    				MessageDialog.new(self, err, "Branch checkout error", OK|ICON_ERROR).show_modal
    				@branch.set_string_selection(repo.head.name)
    			end
  			else
				  send_message(:branch_created)
				  end_modal(ID_OK)
		    end
			else
				MessageDialog.new(self, err, "Error creating branch", OK|ICON_ERROR).show_modal
			end
		end

	end
end
