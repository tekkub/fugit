# encoding: utf-8
include Wx
include IconLoader
include Fugit::GraphRenderer

module Fugit
	class HistoryList < Panel
		def initialize(parent)
			super(parent, ID_ANY)
			self.set_font(Font.new(8, FONTFAMILY_TELETYPE, FONTSTYLE_NORMAL, FONTWEIGHT_NORMAL))

			@list = ListCtrl.new(self, ID_ANY, :style => LC_REPORT|LC_VRULES|NO_BORDER)

			@list_menu = Menu.new
			@menu_create_branch = MenuItem.new(@list_menu, ID_ANY, 'Create new branch here')
			@menu_create_branch.set_bitmap(get_icon("arrow_divide.png"))
			@list_menu.append_item(@menu_create_branch)
			evt_menu(@menu_create_branch, :on_menu_create_branch)

			@menu_cherry_pick = MenuItem.new(@list_menu, ID_ANY, 'Cherry-pick this commit')
			@menu_cherry_pick.set_bitmap(get_icon("cherry.png"))
			@list_menu.append_item(@menu_cherry_pick)
			evt_menu(@menu_cherry_pick, :on_menu_cherry_pick)

			@list_menu.append_separator

			@menu_soft_reset = @list_menu.append('Soft-reset branch to here')
			evt_menu(@menu_soft_reset, :on_menu_soft_reset)

			@menu_mixed_reset = @list_menu.append('Mixed-reset branch to here')
			evt_menu(@menu_mixed_reset, :on_menu_mixed_reset)

			@menu_hard_reset = MenuItem.new(@list_menu, ID_ANY, 'Hard-reset branch to here')
			@menu_hard_reset.set_bitmap(get_icon("arrow_undo.png"))
			@list_menu.append_item(@menu_hard_reset)
			evt_menu(@menu_hard_reset, :on_menu_hard_reset)

			@box = BoxSizer.new(VERTICAL)
			@box.add(@list, 1, EXPAND)
			self.set_sizer(@box)

			evt_list_item_right_click(@list.get_id, :on_list_menu_request)

			register_for_message(:history_tab_shown, :update_list)
			register_for_message(:tab_switch, :update_list)
			register_for_message(:refresh, :update_list)
			register_for_message(:exiting) {self.hide} # Things seem to run smoother if we hide before destruction
		end

		def update_list
			return unless is_shown_on_screen
			@list.hide
			@list.clear_all

			@list.insert_column(0, "")
			@list.insert_column(1, "Branches")
			@list.insert_column(2, "SHA1")
			@list.insert_column(3, "Commit note")

			mono_font = Font.new(8, FONTFAMILY_TELETYPE, FONTSTYLE_NORMAL, FONTWEIGHT_NORMAL)

			branches = `git branch -v -a --no-abbrev`
			branches = branches.split("\n").map {|b| [b[2..-1].split(" ")[0..1], b[0..0] == "*"].flatten}

			output = `git log --pretty=format:"%H\t%P\t%s" --date-order --all`
			lines = output.split("\n").map! {|line| line.split("\t")}
			current_sha = branches.reject {|b| !b.last}.first[1]
			lines.insert(0, ["uncomitted", current_sha, "<Uncomitted changes>"]) if has_uncomitted_changes?
			log = graphify(lines, branches)

			log.each_index do |i|
				(graph, comment, sha) = log[i]
				comment_branches = branches.reject {|b| b[1] != sha}.map {|b| (b.last ? "*" : "") + b.first}
				@list.insert_item(i, sha)
				@list.set_item(i, 0, graph)
				@list.set_item(i, 1, comment_branches.join(" "))
				@list.set_item(i, 2, sha == "uncomitted" ? "" : sha[0..7])
				@list.set_item(i, 3, (comment.nil? || comment.empty?) ? "<No comment>" : comment)
				@list.set_item_data(i, sha)
				@list.set_item_background_colour(i, Colour.new(255, 220, 220)) if sha == "uncomitted"
			end

			@list.set_column_width(0, -1)
			@list.set_column_width(0, [150, @list.get_column_width(0)].min)
			@list.set_column_width(1, -1)
			@list.set_column_width(1, [150, @list.get_column_width(1)].min)
			@list.set_column_width(2, -1)
			@list.set_column_width(3, -1)

			@list.show
			@list.set_focus
		end

		def on_list_menu_request(event)
			@menu_data = event.get_item.get_data
			@list.popup_menu(@list_menu)
		end

		def on_menu_create_branch(event)
			@new_branch_dialog ||= TextEntryDialog.new(self, "New branch name:", "Create branch")
			@new_branch_dialog.set_value("")
			if @new_branch_dialog.show_modal == ID_OK
				err = `git branch #{@new_branch_dialog.get_value} #{@menu_data} 2>&1`
				if err.empty?
					send_message(:refresh)
				else
					MessageDialog.new(self, err, "Error creating branch", OK|ICON_ERROR).show_modal
				end
			end
		end

		def on_menu_cherry_pick(event)
			err = `git cherry-pick  #{@menu_data} 2>&1`
			if err =~ /Automatic cherry-pick failed/
				MessageDialog.new(self, err, "Error cherry-picking", OK|ICON_ERROR).show_modal
			else
				send_message(:refresh)
			end
		end

		def on_menu_soft_reset(event)
			err = `git reset --soft  #{@menu_data} 2>&1`
			if !err.empty?
				MessageDialog.new(self, err, "Error resetting", OK|ICON_ERROR).show_modal
			else
				send_message(:refresh)
			end
		end

		def on_menu_mixed_reset(event)
			err = `git reset --mixed  #{@menu_data} 2>&1`
			#~ if !(err =~ /HEAD is now at/)
				#~ MessageDialog.new(self, err, "Error resetting", OK|ICON_ERROR).show_modal
			#~ else
				send_message(:refresh)
			#~ end
		end

		def on_menu_hard_reset(event)
			if has_uncomitted_changes?
				@uncomitted_hard_dialog ||= MessageDialog.new(self, "Uncommitted changes will be lost, continue?", "Uncomitted changes", YES_NO|NO_DEFAULT|ICON_EXCLAMATION)
				return if @uncomitted_hard_dialog.show_modal != ID_YES
			end

			err = `git reset --hard  #{@menu_data} 2>&1`
			if !(err =~ /HEAD is now at/)
				MessageDialog.new(self, err, "Error resetting", OK|ICON_ERROR).show_modal
			else
				send_message(:refresh)
			end
		end

		def has_uncomitted_changes?
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
			modified = modified.split("\n")
			staged = staged.split("\n").map do |line|
				(info, file) = line.split("\t")
				sha = info.match(/[a-f0-9]{40}/)[0]
				[file, sha]
			end
			committed.each_pair do |file, sha|
				staged << [file, ""] unless staged.assoc(file)
			end
			staged.reject! {|file, sha| committed[file] == sha}

			return !(deleted + modified + staged).empty?
		end

	end
end
