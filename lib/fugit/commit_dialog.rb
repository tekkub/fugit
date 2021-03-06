include Wx
include IconLoader

module Fugit
	class CommitDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Commit changes", :size => Size.new(500, 250))

			@input = TextCtrl.new(self, ID_ANY, nil, nil, nil, TE_MULTILINE|TE_DONTWRAP)
			@amend_check = CheckBox.new(self, ID_ANY)
			@amend_check.set_label("&Amend previous commit")
			@author = TextCtrl.new(self, ID_ANY)
			@committer = TextCtrl.new(self, ID_ANY)
			@committer.disable

			evt_checkbox(@amend_check, :on_amend_checked)

			flex = FlexGridSizer.new(4,2,4,4)
			flex.add(StaticText.new(self, ID_ANY, "Committer:"), 0, ALIGN_RIGHT)
			flex.add(@committer, 0, EXPAND)
			flex.add(StaticText.new(self, ID_ANY, "Author:"), 0, ALIGN_RIGHT)
			flex.add(@author, 0, EXPAND)
			flex.add(StaticText.new(self, ID_ANY, "Commit message:"), 0, ALIGN_RIGHT)
			flex.add(@input, 0, EXPAND)
			flex.add(1,1) # Filler
			flex.add(@amend_check, 0)
			flex.add_growable_row(2)
			flex.add_growable_col(1)

			butt_sizer = create_button_sizer(OK|CANCEL)
			butt_sizer.get_children.map {|s| s.get_window}.compact.each {|b| b.set_label("Commit") if b.get_label == "OK"}
			evt_button(get_affirmative_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(flex, 1, EXPAND|ALL, 4)
			box.add(butt_sizer, 0, EXPAND|BOTTOM, 4)
			self.set_sizer(box)

			self.accelerator_table = AcceleratorTable.new(AcceleratorEntry.new(MOD_CMD, ?s, ID_OK))
		end

		def show_modal
			user = "#{repo.config["user.name"]} <#{repo.config["user.email"]}>"
			@committer.set_value(user)
			@author.set_value(user)
			@input.set_value("")
			@amend_check.set_value(false)
			@input.set_focus

			super
		end

		def on_amend_checked(event)
			return unless event.is_checked && @input.get_value.empty?

			raw_log = `git log -1 --pretty=raw`
			@author.set_value($1) if raw_log =~ /author (.+>)/
			@input.set_value($1.split("\n").map {|l| l.strip}.join("\n")) if raw_log =~ /\n\n    (.+)\n\Z/m
		end

		def on_ok
			msg = @input.get_value
			if !has_staged_changes? && !@amend_check.is_checked
				@nothing_to_commit_error ||= MessageDialog.new(self, "No changes are staged to commit.", "Commit error", OK|ICON_ERROR)
				@nothing_to_commit_error.show_modal
			elsif msg.empty?
				@no_msg_error ||= MessageDialog.new(self, "Please enter a commit message.", "Commit error", OK|ICON_ERROR)
				@no_msg_error.show_modal
			else
				vals = {:author => %Q|"#{@author.get_value}"|}
				vals[:amend] = true if @amend_check.is_checked
				repo.git.commit(vals, '-m', msg.gsub('"', '\"'))
				end_modal ID_OK
			end
		end

		def has_staged_changes?
			staged = `git ls-files --stage`
			last_commit = `git ls-tree -r HEAD`

			committed = {}
			last_commit.split("\n").map do |line|
				(info, file) = line.split("\t")
				sha = info.match(/[a-f0-9]{40}/)[0]
				committed[file] = sha
			end

			staged = staged.split("\n").map do |line|
				(info, file) = line.split("\t")
				sha = info.match(/[a-f0-9]{40}/)[0]
				[file, sha]
			end
			staged.reject! {|file, sha| committed[file] == sha}
			!staged.empty?
		end

	end
end
