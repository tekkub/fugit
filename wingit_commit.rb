include Wx
include IconLoader

class WingitCommit < Panel
	def initialize(parent)
		super(parent, ID_ANY)

		@input = TextCtrl.new(self, ID_ANY, nil, nil, nil, TE_MULTILINE|TE_DONTWRAP)
		@author = TextCtrl.new(self, ID_ANY)
		@committer = TextCtrl.new(self, ID_ANY)

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

		setCommitter
	end

	def setCommitter
		name = `git config user.name`
		email = `git config user.email`
		@committer.set_value("#{name} <#{email}>")
		@author.set_value("#{name} <#{email}>")
	end

end
