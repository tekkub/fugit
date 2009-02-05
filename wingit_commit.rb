include Wx
include IconLoader

class WingitCommit < Panel
	def initialize(parent)
		super(parent, ID_ANY)

		@input = TextCtrl.new(self, ID_ANY, nil, nil, nil, TE_MULTILINE|TE_DONTWRAP)
		@author = TextCtrl.new(self, ID_ANY)
		@committer = TextCtrl.new(self, ID_ANY)
		@committer.disable

		@toolbar = ToolBar.new(self, ID_ANY)
		@toolbar.set_tool_bitmap_size(Size.new(16,16))
		@toolbar.add_tool(101, "Commit", get_icon("disk.png"), "Commit")
		@toolbar.add_tool(102, "Sign off", get_icon("text_signature.png"), "Sign off")
		@toolbar.add_separator
		@toolbar.add_tool(103, "Push", get_icon("page_up.gif"), "Push")
		@toolbar.add_tool(104, "Pull", get_icon("page_down.gif"), "Pull")
		@toolbar.realize

		box = BoxSizer.new(HORIZONTAL)
		box.add(@committer, 1, EXPAND)
		box.add(@author, 1, EXPAND)

		flex = FlexGridSizer.new(2,2,0,0)
		flex.add(StaticText.new(self, ID_ANY, "Committer/Author:"), 0, EXPAND)
		flex.add(box, 0, EXPAND)
		flex.add(StaticText.new(self, ID_ANY, "Commit message:"), 0, EXPAND)
		flex.add(@input, 0, EXPAND)
		flex.add_growable_row(1)
		flex.add_growable_col(1)

		box = BoxSizer.new(VERTICAL)
		box.add(@toolbar, 0, EXPAND)
		box.add_spacer(4)
		box.add(flex, 1, EXPAND)
		self.set_sizer(box)

		evt_tool(101, :on_commit_clicked)

		register_for_message(:commit_saved, :on_commit_saved)
		register_for_message(:refresh, :update)

		name = `git config user.name`
		email = `git config user.email`
		@committer.set_value("#{name.chomp} <#{email.chomp}>")
		@author.set_value("#{name.chomp} <#{email.chomp}>")
	end

	def on_commit_clicked
		msg = @input.get_value
		if msg.empty?
			@no_msg_error ||= MessageDialog.new(self, "Please enter a commit message.", "Commit error", OK|ICON_ERROR)
			@no_msg_error.show_modal
		elsif self.get_parent.index.staged.get_count == 0
			@nothing_to_commit_error ||= MessageDialog.new(self, "No changes are staged to commit.", "Commit error", OK|ICON_ERROR)
			@nothing_to_commit_error.show_modal
		else
			File.open(File.join(Dir.pwd, ".git", "wingit_commit.txt"), "w") {|f| f << msg}
			`git commit --file=.git/wingit_commit.txt --author="#{@author.get_value}"`
			send_message(:commit_saved)
		end
	end

	def on_commit_saved
		name = `git config user.name`
		email = `git config user.email`
		@author.set_value("#{name.chomp} <#{email.chomp}>")
		@input.set_value("")
	end

end
