include Wx

class WingitIndexList < Panel
	attr_accessor :unstaged, :staged

	def initialize(parent)
		super(parent, ID_ANY)

		@unstaged = ListBox.new(self, ID_ANY, nil, nil, nil, LB_EXTENDED)
		@staged = ListBox.new(self, ID_ANY, nil, nil, nil, LB_EXTENDED)

		box = BoxSizer.new(VERTICAL)
		box.add(@unstaged, 1, EXPAND)
		box.add(@staged, 1, EXPAND)
		self.set_sizer(box)
	end

end
