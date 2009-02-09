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

			evt_tree_item_collapsing(@index.get_id) {|event| event.veto}

			register_for_message(:refresh, :update_tree)
			register_for_message(:commit_saved, :update_tree)
			register_for_message(:index_changed, :update_tree)

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
			staged.reject! {|file, sha| committed[file] == sha}

			@index.hide
			@index.delete_all_items
			root = @index.add_root("root")
			uns = @index.append_item(root, "Unstaged", 0)
			stg = @index.append_item(root, "Staged", 1)

			others.split("\n").each {|file| @index.append_item(uns, file, 2, -1, [file, :new, :unstaged])}
			modified.split("\n").each {|file| @index.append_item(uns, file, 3, -1, [file, :modified, :unstaged]) unless deleted.include?(file)}
			deleted.each {|file| @index.append_item(uns, file, 4, -1, [file, :deleted, :unstaged])}
			staged.each {|file, sha| @index.append_item(stg, file, 5, -1, [file, :modified, :staged])}

			@index.get_root_items.each do |i|
				@index.set_item_bold(i)
				@index.sort_children(i)
			end

			@index.expand_all
			@index.show
			self.enable
		end


		def on_click(event)
			#~ @staged.deselect(-1) # Clear the other box's selection

			i = event.get_item
			return if i == 0 || !self.enabled?

			if @index.get_root_items.include?(i)
				send_message(:diff_clear)
			else
				(file, change, status) = @index.get_item_data(i)
				case status
				when :unstaged
					case change
					when :new
						val = File.read(file)
						send_message(:diff_raw, val)
					when :modified, :deleted
						val = `git diff -- #{file}`
						send_message(:diff_set, val)
					else
						send_message(:diff_clear)
					end
				when :staged
					val = `git diff --cached -- #{file}`
					send_message(:diff_set, val)
				end
			end
		end


		def on_double_click(event)
			i = event.get_item
			unless @index.get_root_items.include?(i)
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

	end
end
