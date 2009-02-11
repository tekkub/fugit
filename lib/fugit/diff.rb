include Wx

module Fugit
	class Diff < Panel
		def initialize(parent)
			super(parent, ID_ANY)
			self.set_font(Font.new(8, FONTFAMILY_TELETYPE, FONTSTYLE_NORMAL, FONTWEIGHT_NORMAL))

			@list = TreeCtrl.new(self, ID_ANY, nil, nil, NO_BORDER|TR_MULTIPLE|TR_HIDE_ROOT|TR_FULL_ROW_HIGHLIGHT|TR_NO_LINES)
			@root = @list.add_root("root")
			@list.hide

			@list_menu = Menu.new
			@menu_stage_chunk = @list_menu.append('Stage this chunk')
			evt_menu(@menu_stage_chunk, :on_menu_stage_chunk)

			@text = TextCtrl.new(self, ID_ANY, nil, nil, nil, TE_MULTILINE|TE_DONTWRAP|TE_READONLY)
			@text.hide

			@box = BoxSizer.new(VERTICAL)
			@box.add(@list, 1, EXPAND)
			@box.add(@text, 1, EXPAND)
			self.set_sizer(@box)

			#~ evt_tree_sel_changed(@list.get_id, :on_click)
			evt_tree_item_menu(@list.get_id, :on_item_menu_request)
			evt_tree_item_activated(@list.get_id, :on_double_click)

			register_for_message(:commit_saved, :clear)
			register_for_message(:diff_clear, :clear)
			register_for_message(:diff_set, :set_diff)
			register_for_message(:diff_raw, :change_value)
			register_for_message(:exiting) {self.hide} # Things seem to run smoother if we hide before destruction
		end

		def set_diff(value, type)
			chunks = value.split("\n@@")
			header = chunks.slice!(0)
			chunks.map! {|line| "@@"+line}

			@text.hide
			@list.hide

			@list.delete_children(@root)

			chunks.each do |chunk|
				diff = header + "\n" + chunk
				diff = diff + "\n" if diff[-1..-1] != "\n" # git bitches if we don't have a proper newline at the end of the diff
				chunk.split("\n").each do |line|
					id = @list.append_item(@root, line.gsub("\t", "        "), -1, -1, [diff, type])

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
						when "@"
							Colour.new(220, 220, 225)
						end
					@list.set_item_text_colour(id, color) if color
					@list.set_item_background_colour(id, bgcolor) if bgcolor
				end
			end

			@list.show
			@list.set_focus
			@box.layout
		end

		def clear
			@list.hide
			@text.hide
		end

		def change_value(value)
			@list.hide
			@text.set_value(value)
			@text.show
			@text.set_focus
			@box.layout
		end

		def on_item_menu_request(event)
			i = event.get_item
			@menu_data = nil
			unless @root == i
				@menu_data = @list.get_item_data(i)
				@list_menu.set_label(@menu_stage_chunk.get_id, (@menu_data[1] == :staged ? "Unstage chunk" : "Stage chunk"))
				@list.popup_menu(@list_menu)
			end
		end

		def on_menu_stage_chunk(event)
			apply_diff(*@menu_data) if @menu_data
		end

		def on_double_click(event)
			i = event.get_item
			apply_diff(*@list.get_item_data(i)) unless @root == i
		end

		def apply_diff(diff, type)
			reverse = (type == :staged ? "--reverse" : "")
			diff_file = File.join(Dir.pwd, ".git", "fugit_partial.diff")
			File.open(diff_file, "wb") {|f| f << diff} # Write out in binary mode to preserve newlines, otherwise git freaks out
			`git apply --cached #{reverse} .git/fugit_partial.diff`
			File.delete(diff_file)
			send_message(:index_changed)
		end
	end
end
