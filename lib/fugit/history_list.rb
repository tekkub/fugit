# encoding: utf-8
include Wx
include Fugit::GraphRenderer

module Fugit
	class HistoryList < Panel
		def initialize(parent)
			super(parent, ID_ANY)
			self.set_font(Font.new(8, FONTFAMILY_TELETYPE, FONTSTYLE_NORMAL, FONTWEIGHT_NORMAL))

			@list = ListCtrl.new(self, ID_ANY, :style => LC_REPORT|LC_VRULES|NO_BORDER)

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

			output = `git log --pretty=format:"%H\t%P\t%s" --date-order --all`
			lines = output.split("\n").map! {|line| line.split("\t")}
			log = graphify(lines)

			log.each_index do |i|
				(graph, comment, sha) = log[i]
				@list.insert_item(i, sha)
				@list.set_item(i, 0, graph)
				@list.set_item(i, 1, sha[0..7])
				@list.set_item(i, 2, (comment.nil? || comment.empty?) ? "<No comment>" : comment)
			end

			@list.set_column_width(0, -1)
			@list.set_column_width(1, -1)
			@list.set_column_width(2, -2)

			@list.show
			@has_initialized = true
		end

	end
end