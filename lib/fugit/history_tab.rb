include Wx
include IconLoader

module Fugit
	class HistroyTab < Panel
		def initialize(parent)
			super

			@history_list = HistoryList.new(self)

			box = BoxSizer.new(VERTICAL)
			box.add(@history_list, 1, EXPAND)
			self.set_sizer(box)
		end
	end
end
