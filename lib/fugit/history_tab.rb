include Wx
include IconLoader

module Fugit
	class HistroyTab < Panel
		def initialize(parent)
			super

			@history_list = HistoryList.new(self)
			@toolbar = TabToolbar.new(self, false)

			box = BoxSizer.new(VERTICAL)
			box.add(@toolbar, 0, EXPAND)
			box.add_spacer(3)
			box.add(@history_list, 1, EXPAND)
			self.set_sizer(box)
		end
	end
end
