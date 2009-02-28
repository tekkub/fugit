include Wx
include IconLoader

module Fugit
	class CommitTabToolbar < ToolBar
		def initialize(parent)
			super(parent, ID_ANY, nil, nil, TB_HORIZONTAL|NO_BORDER|TB_NODIVIDER)

			self.set_tool_bitmap_size(Size.new(16,16))

			stage_all_button = self.add_tool(ID_ANY, "Stage all", get_icon("folder_add.png"), "Stage all")
			evt_tool(stage_all_button, :on_stage_all_clicked)

			stage_button = self.add_tool(ID_ANY, "Stage", get_icon("page_add.png"), "Stage changed files")
			evt_tool(stage_button, :on_stage_changed_clicked)

			unstage_all_button = self.add_tool(ID_ANY, "Unstage all", get_icon("folder_delete.png"), "Unstage all")
			evt_tool(unstage_all_button, :on_unstage_all_clicked)

			self.add_separator

			commit = self.add_tool(ID_ANY, "Commit", get_icon("disk.png"), "Commit")
			evt_tool(commit, :on_commit_clicked)

			self.add_separator

			push = self.add_tool(ID_ANY, "Push", get_icon("page_up.gif"), "Push")
			evt_tool(push, :on_push_clicked)

			fetch = self.add_tool(ID_ANY, "Fetch", get_icon("page_down.gif"), "Fetch")
			evt_tool(fetch, :on_fetch_clicked)

			self.add_separator

			self.add_control(@branch = Choice.new(self, ID_ANY))
			set_branches
			evt_choice(@branch, :on_branch_choice)

			merge_branch_button = self.add_tool(ID_ANY, "Merge branch", get_icon("arrow_join.png"), "Merge branch")
			self.enable_tool(merge_branch_button.get_id, false)

			delete_branch_button = self.add_tool(ID_ANY, "Delete branch", get_icon("arrow_divide_delete.png"), "Delete branch")
			evt_tool(delete_branch_button, :on_delete_branch_clicked)

			self.realize

			register_for_message(:tab_switch, :update_tools)
			register_for_message(:branch_deleted, :update_tools)
			register_for_message(:refresh, :update_tools)
			register_for_message(:save_clicked, :on_commit_clicked)
			register_for_message(:push_clicked, :on_push_clicked)
		end

		def update_tools
			return unless is_shown_on_screen
			set_branches
		end

		def set_branches
			branches = `git branch`
			current = branches.match(/\* (.+)/).to_a.last
			@branch.clear
			branches.split("\n").each {|b| @branch.append(b.split(" ").last)}
			@branch.set_string_selection(current) if current
		end

		def on_stage_all_clicked(event)
			`git add --all 2>&1`
			send_message(:index_changed)
		end

		def on_stage_changed_clicked(event)
			`git add --update 2>&1`
			send_message(:index_changed)
		end

		def on_unstage_all_clicked(event)
			`git reset 2>&1`
			send_message(:index_changed)
		end

		def on_commit_clicked
			@commit_dialog ||= CommitDialog.new(self)
			send_message(:commit_saved) if @commit_dialog.show_modal == ID_OK
		end

		def on_push_clicked
			@push_dialog ||= PushDialog.new(self)
			@push_dialog.show
		end

		def on_fetch_clicked
			@fetch_dialog ||= FetchDialog.new(self)
			@fetch_dialog.show
		end

		def on_branch_choice(event)
			branch = @branch.get_string(event.get_selection)
			err = `git checkout #{branch} 2>&1`
			if err =~ /Switched to branch "#{branch}"/
				send_message(:branch_checkout)
			else
				MessageDialog.new(self, err, "Branch checkout error", OK|ICON_ERROR).show_modal
				branches = `git branch`
				current = branches.match(/\* (.+)/).to_a.last
				@branch.set_string_selection(current) if current
			end
		end

		def on_delete_branch_clicked
			@delete_branch_dialog ||= DeleteBranchDialog.new(self)
			@delete_branch_dialog.show
		end

	end
end
