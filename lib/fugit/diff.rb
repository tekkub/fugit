include Wx

module Fugit
	class Diff < Panel
		def initialize(parent)
			super(parent, ID_ANY)
			self.set_font(Font.new(8, FONTFAMILY_TELETYPE, FONTSTYLE_NORMAL, FONTWEIGHT_NORMAL))

			@list = ListCtrl.new(self, ID_ANY, :style => LC_REPORT|LC_VRULES|NO_BORDER|LC_NO_HEADER)
			@list.hide

			@list_menu = Menu.new
			@menu_stage_chunk = @list_menu.append('Stage this chunk')
			@menu_stage_line = @list_menu.append('Stage this line')
			evt_menu(@menu_stage_chunk, :on_menu_stage_chunk)
			evt_menu(@menu_stage_line, :on_menu_stage_line)

			@text = TextCtrl.new(self, ID_ANY, nil, nil, nil, TE_MULTILINE|TE_DONTWRAP|TE_READONLY)
			@text.hide

			@box = BoxSizer.new(VERTICAL)
			@box.add(@list, 1, EXPAND)
			@box.add(@text, 1, EXPAND)
			self.set_sizer(@box)

			#~ evt_tree_sel_changed(@list.get_id, :on_click)
			evt_list_item_right_click(@list.get_id, :on_item_menu_request)
			evt_list_item_activated(@list.get_id, :on_double_click)

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

			@list.clear_all
			@list.insert_column(0, "Graph")

			reverse_diff = type == :staged ? ["-", "\\+"] : ["+", "-"]
			last_id = -1
			chunks.each do |chunk|
				chunk_diff = header + "\n" + chunk
				chunk_diff += "\n" if chunk_diff[-1..-1] != "\n" # git bitches if we don't have a proper newline at the end of the diff
				lines = chunk.split("\n")
				lines.each_index do |i|
					line = lines[i]
					line_diff = case line[0..0]
						when "+", "-"
							chunk_lines = chunk.split("\n")
							diff_val = chunk_lines.first.match(/\A@@ -\d+,(\d+)/)[1].to_i + (line[0..0] == "+" ? 1 : -1)
							chunk_lines[0] = chunk_lines.first.gsub(/\+(\d+),\d+/, '+\1,' + diff_val.to_s)
							chunk_lines.delete_at(i)
							chunk_lines.map! {|l| l[0..0] == reverse_diff[0] ? "#{line}~~~DELETE~~~" : l.gsub(/\A#{reverse_diff[1]}/, " ")}
							chunk_lines.insert(i, line)
							chunk_lines.reject! {|l| l == "#{line}~~~DELETE~~~"}
							header + "\n" + chunk_lines.join("\n") + "\n"
						else
							""
						end

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

					item = ListItem.new
					item.set_id(last_id += 1)
					item.set_column(0)
					item.set_data([chunk_diff, line_diff, type])
					item.set_text(line.gsub("\t", "        "))
					item.set_text_colour(color) if color
					item.set_background_colour(bgcolor) if bgcolor

					@list.insert_item(item)
				end
			end

			@list.set_column_width(0, -1)
			@list.set_column_width(0, [@list.get_column_width(0), self.size.width].max)

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
			@menu_data = event.get_item.get_data
			@list_menu.set_label(@menu_stage_chunk.get_id, (@menu_data[2] == :staged ? "Unstage chunk" : "Stage chunk"))
			@list_menu.set_label(@menu_stage_line.get_id, (@menu_data[2] == :staged ? "Unstage line" : "Stage line"))
			@menu_stage_line.enable(!@menu_data[1].empty?)
			@list.popup_menu(@list_menu)
		end

		def on_menu_stage_chunk(event)
			apply_diff(@menu_data[0], @menu_data[2]) if @menu_data
		end

		def on_menu_stage_line(event)
			apply_diff(@menu_data[1], @menu_data[2]) if @menu_data
		end

		def on_double_click(event)
			menu_data = event.get_item.get_data
			apply_diff(menu_data[1], menu_data[2]) if menu_data
		end

		def apply_diff(diff, type)
			return if !diff or diff.empty?
			reverse = (type == :staged ? "--reverse" : "")
			diff_file = File.join(Dir.pwd, ".git", "fugit_partial.diff")
			File.open(diff_file, "wb") {|f| f << diff} # Write out in binary mode to preserve newlines, otherwise git freaks out
			err = `git apply --cached #{reverse} .git/fugit_partial.diff  2>&1`
			if err.empty?
				send_message(:index_changed)
			else
				MessageDialog.new(self, err, "Error applying diff", OK|ICON_ERROR).show_modal
			end
		end
	end
end
