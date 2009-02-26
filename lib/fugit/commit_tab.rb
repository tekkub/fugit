include Wx
include IconLoader

module Fugit
	class CommitTab < Panel
		def initialize(parent)
			super

			@vsplitter = SplitterWindow.new(self, ID_ANY)
			@vsplitter.set_minimum_pane_size(150)

			@hsplitter = SplitterWindow.new(@vsplitter, ID_ANY)
			@hsplitter.set_minimum_pane_size(150)
			@hsplitter.set_sash_gravity(1.0)

			@toolbar = CommitTabToolbar.new(self)
			@diff = Diff.new(@hsplitter)
			@commit = Commit.new(@hsplitter)
			@hsplitter.split_horizontally(@diff, @commit)

			@index = IndexList.new(@vsplitter)
			@vsplitter.split_vertically(@index, @hsplitter, 200)

			box = BoxSizer.new(VERTICAL)
			box.add(@toolbar, 0, EXPAND)
			box.add_spacer(3)
			box.add(@vsplitter, 1, EXPAND)
			self.set_sizer(box)

			self.accelerator_table = AcceleratorTable.new(AcceleratorEntry.new(MOD_CMD, ?w, ID_EXIT))
		end
	end
end
