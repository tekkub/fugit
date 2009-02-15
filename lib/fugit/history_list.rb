include Wx

module Fugit
	class HistoryList < Panel
		def initialize(parent)
			super(parent, ID_ANY)
			self.set_font(Font.new(8, FONTFAMILY_TELETYPE, FONTSTYLE_NORMAL, FONTWEIGHT_NORMAL))

			@list = ListCtrl.new(self, ID_ANY, :style => LC_REPORT|LC_HRULES|LC_VRULES)

			@box = BoxSizer.new(VERTICAL)
			@box.add(@list, 1, EXPAND)
			self.set_sizer(@box)

			register_for_message(:history_tab_shown) do
				update_list unless @has_initialized
				@list.set_focus
			end
			register_for_message(:exiting) {self.hide} # Things seem to run smoother if we hide before destruction
		end

		def update_list
			@list.hide
			@list.clear_all

			@list.insert_column(0, "Graph")
			@list.insert_column(1, "SHA1")
			@list.insert_column(2, "Commit note")

			mono_font = Font.new(8, FONTFAMILY_TELETYPE, FONTSTYLE_NORMAL, FONTWEIGHT_NORMAL)

			log = `git log --all --pretty=oneline --graph`
			lines = log.split("\n")
			lines.each_index do |i,line|
				line = lines[i]
				(match, graph, sha, comment) = line.match(/\A(.+) ([a-f0-9]{40}) (.+)\Z/).to_a
				if graph
					@list.insert_item(i, sha)
					@list.set_item(i, 0, graph)
					@list.set_item(i, 1, sha[0..7])
					@list.set_item(i, 2, comment)
				else
					@list.insert_item(i, line)
				end
			end

			@list.set_column_width(0, -1)
			@list.set_column_width(1, -1)
			@list.set_column_width(2, -2)

			@list.show
			@has_initialized = true
		end

	end
end
