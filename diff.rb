include Wx

module Fugit
	class Diff < Panel
		def initialize(parent)
			super(parent, ID_ANY)

			@list = TreeCtrl.new(self, ID_ANY, nil, nil, NO_BORDER|TR_MULTIPLE|TR_HIDE_ROOT|TR_FULL_ROW_HIGHLIGHT|TR_NO_LINES)
			@list.hide

			@styled = StyledTextCtrl.new(self, ID_ANY)
			@styled.hide
			@styled.set_margin_left(5)
			@styled.set_margin_width(1, 0)

			@box = BoxSizer.new(VERTICAL)
			@box.add(@list, 1, EXPAND)
			@box.add(@styled, 1, EXPAND)
			self.set_sizer(@box)

			#~ evt_tree_sel_changed(@list.get_id, :on_click)

			register_for_message(:commit_saved, :clear)
			register_for_message(:index_changed, :clear)
			register_for_message(:diff_clear, :clear)
			register_for_message(:diff_set, :set_diff)
			register_for_message(:diff_raw, :change_value)
		end

		def set_diff(value)
			value.gsub!(/[+-]{3} [ab]\/[^\n]+\n/, "")
			value.gsub!(/\nindex [a-fA-F0-9]{7}\.\.[a-fA-F0-9]{7}[^\n]*/, "")
			value.gsub!(/\Adiff[^\n]+\n/, "")

			@styled.hide
			@list.hide

			@list_font ||= Font.new(8, FONTFAMILY_TELETYPE, FONTSTYLE_NORMAL, FONTWEIGHT_NORMAL)

			@list.delete_all_items
			root = @list.add_root("root")
			value.split("\n").each do |line|
				id = @list.append_item(root, line.gsub("\t", "        "))
				@list.set_item_font(id, @list_font)

				color = case line[0..0]
					when "+"
						Colour.new(0, 96, 0)
					when "-"
						Colour.new(160, 0, 0)
					when "@"
						Colour.new(0, 0, 150)
					end
				bgcolor = case line[0..0]
					when "+"
						Colour.new(220, 255, 220)
					when "-"
						Colour.new(255, 220, 220)
					end
				@list.set_item_text_colour(id, color) if color
				@list.set_item_background_colour(id, bgcolor) if bgcolor
			end

			@list.show
			@box.layout
		end

		def clear
			@list.hide
			@styled.hide
		end

		def change_value(value)
			@list.hide
			write_value(value)
			@styled.show
			@box.layout
		end

		def write_value(value)
			@styled.set_read_only(false)
			@styled.set_text(value)
			@styled.set_read_only(true)
		end

	end
end
