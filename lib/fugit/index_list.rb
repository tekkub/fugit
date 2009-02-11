include Wx
include IconLoader

module Fugit
	class IndexList < Panel
		def initialize(parent)
			super(parent, ID_ANY)

			@index = TreeCtrl.new(self, ID_ANY, nil, nil, NO_BORDER|TR_MULTIPLE|TR_HIDE_ROOT|TR_FULL_ROW_HIGHLIGHT|TR_NO_LINES)

			imagelist = ImageList.new(16, 16)
			imagelist << get_icon("asterisk_yellow.png")
			imagelist << get_icon("tick.png")
			imagelist << get_icon("script_add.png")
			imagelist << get_icon("script_edit.png")
			imagelist << get_icon("script_delete.png")
			imagelist << get_icon("script.png")
			@index.set_image_list(imagelist)

			root = @index.add_root("root")
			@unstaged = @index.append_item(root, "Unstaged", 0)
			@staged = @index.append_item(root, "Staged", 1)
			@index.set_item_bold(@unstaged)
			@index.set_item_bold(@staged)

			@toolbar = ToolBar.new(self, ID_ANY, nil, nil, TB_HORIZONTAL|NO_BORDER|TB_NODIVIDER)
			@toolbar.set_tool_bitmap_size(Size.new(16,16))
			@toolbar.add_tool(101, "Stage all", get_icon("folder_add.png"), "Stage all")
			@toolbar.add_tool(102, "Stage", get_icon("page_add.png"), "Stage file")
			@toolbar.add_separator
			@toolbar.add_tool(103, "Unstage", get_icon("page_delete.png"), "Unstage file")
			@toolbar.add_tool(104, "Unstage all", get_icon("folder_delete.png"), "Unstage all")
			@toolbar.realize

			box = BoxSizer.new(VERTICAL)
			box.add(@toolbar, 0, EXPAND)
			box.add(@index, 1, EXPAND)
			self.set_sizer(box)

			evt_tree_sel_changed(@index.get_id, :on_click)
			evt_tree_item_activated(@index.get_id, :on_double_click)

			evt_tool(101, :on_stage_all_clicked)
			evt_tool(104, :on_unstage_all_clicked)

			evt_tree_item_collapsing(@index.get_id) {|event| event.veto}

			register_for_message(:refresh, :update_tree)
			register_for_message(:commit_saved, :update_tree)
			register_for_message(:index_changed, :update_tree)
			register_for_message(:exiting) {self.hide} # Things seem to run smoother if we hide before destruction

			update_tree
		end


		def update_tree()
			self.disable

			others = `git ls-files --others --exclude-standard`
			deleted = `git ls-files --deleted`
			modified = `git ls-files --modified`
			staged = `git ls-files --stage`
			last_commit = `git ls-tree -r HEAD`

			committed = {}
			last_commit.split("\n").map do |line|
				(info, file) = line.split("\t")
				sha = info.match(/[a-f0-9]{40}/)[0]
				committed[file] = sha
			end

			deleted = deleted.split("\n")
			staged = staged.split("\n").map do |line|
				(info, file) = line.split("\t")
				sha = info.match(/[a-f0-9]{40}/)[0]
				[file, sha]
			end
			committed.each_pair do |file, sha|
				staged << [file, ""] unless staged.assoc(file)
			end
			staged.reject! {|file, sha| committed[file] == sha}

			@index.hide
			selection = @index.get_selections.map {|i| @index.get_item_data(i)}
			@index.delete_children(@unstaged)
			@index.delete_children(@staged)

			others.split("\n").each {|file| @index.append_item(@unstaged, file, 2, -1, [file, :new, :unstaged])}
			modified.split("\n").each {|file| @index.append_item(@unstaged, file, 3, -1, [file, :modified, :unstaged]) unless deleted.include?(file)}
			deleted.each {|file| @index.append_item(@unstaged, file, 4, -1, [file, :deleted, :unstaged])}
			staged.each {|file, sha| @index.append_item(@staged, file, 5, -1, [file, :modified, :staged])}

			@index.sort_children(@unstaged)
			@index.sort_children(@staged)
			@index.select_item(@unstaged, false)
			@index.select_item(@staged, false)

			to_select = []
			@index.each {|i| to_select << i if selection.include?(@index.get_item_data(i))}
			to_select.each {|i| @index.select_item(i)}
			if to_select.size == 1
				set_diff(*@index.get_item_data(to_select[0]))
			else
				send_message(:diff_clear)
			end

			@index.expand_all
			@index.ensure_visible(to_select.empty? ? @unstaged : to_select[0])
			@index.set_scroll_pos(HORIZONTAL, 0)
			@index.show
			self.enable
			self.set_focus unless to_select.size == 1
		end


		def on_click(event)
			#~ @staged.deselect(-1) # Clear the other box's selection

			i = event.get_item
			return if i == 0 || !self.enabled?

			if i == @unstaged || i == @staged || @index.get_selections.size != 1
				send_message(:diff_clear)
			else
				set_diff(*@index.get_item_data(i))
			end
		end


		def on_double_click(event)
			i = event.get_item
			unless i == @unstaged || i == @staged
				(file, change, status) = @index.get_item_data(i)
				case status
				when :unstaged
					case change
					when :deleted
						`git rm --cached "#{file}"`
					else
						`git add "#{file}"`
					end
				when :staged
					`git reset "#{file}"`
				end

				send_message(:index_changed)
			end
		end

		def on_stage_all_clicked(event)
			children = @index.get_children(@unstaged).map {|child| @index.get_item_data(child)}
			to_delete = children.reject {|file, change, status| change != :deleted}.map {|f,c,s| f}
			to_add = children.map {|f,c,s| f} - to_delete
			`git rm --cached "#{to_delete.join('" "')}"` unless to_delete.empty?
			`git add "#{to_add.join('" "')}"` unless to_add.empty?
			send_message(:index_changed)
		end

		def on_unstage_all_clicked(event)
			children = @index.get_children(@staged).map {|child| @index.get_item_data(child)[0]}
			`git reset "#{children.join('" "')}"` unless children.empty?
			send_message(:index_changed)
		end

		def set_diff(file, change, status)
			case status
			when :unstaged
				case change
				when :new
					val = File.read(file)
					send_message(:diff_raw, val)
				when :modified, :deleted
					val = `git diff -- #{file}`
					send_message(:diff_set, val, :unstaged)
				else
					send_message(:diff_clear)
				end
			when :staged
				val = `git diff --cached -- #{file}`
				send_message(:diff_set, val, :staged)
			end
		end

	end
end
