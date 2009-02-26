include Wx
include IconLoader

module Fugit
	class CommitTabToolbar < ToolBar
		def initialize(parent)
			super(parent, ID_ANY, nil, nil, TB_HORIZONTAL|NO_BORDER|TB_NODIVIDER)

			self.set_tool_bitmap_size(Size.new(16,16))
			stage_all_button = self.add_tool(ID_ANY, "Stage all", get_icon("folder_add.png"), "Stage all")
			stage_button = self.add_tool(ID_ANY, "Stage", get_icon("page_add.png"), "Stage file")
			self.add_separator
			unstage_button = self.add_tool(ID_ANY, "Unstage", get_icon("page_delete.png"), "Unstage file")
			unstage_all_button = self.add_tool(ID_ANY, "Unstage all", get_icon("folder_delete.png"), "Unstage all")
			self.enable_tool(stage_button.get_id, false)
			self.enable_tool(unstage_button.get_id, false)
			self.realize

			evt_tool(stage_all_button, :on_stage_all_clicked)
			evt_tool(unstage_all_button, :on_unstage_all_clicked)
		end

		def on_stage_all_clicked(event)
			`git add --update 2>&1`
			send_message(:index_changed)
		end

		def on_unstage_all_clicked(event)
			`git reset 2>&1`
			send_message(:index_changed)
		end

	end
end
