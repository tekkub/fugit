
$:.unshift File.dirname(__FILE__)

require "rubygems"

require 'wx'
require "grit/lib/grit"

require "fugit/icon_loader"

require "fugit/commit_dialog"
require "fugit/commit_tab"
require "fugit/console"
require "fugit/create_branch_dialog"
require "fugit/delete_branch_dialog"
require "fugit/diff"
require "fugit/fetch_dialog"
require "fugit/graph_renderer"
require "fugit/history_list"
require "fugit/history_tab"
require "fugit/index_list"
require "fugit/io_get_line"
require "fugit/logged_dialog"
require "fugit/main_frame"
require "fugit/merge_dialog"
require "fugit/messages"
require "fugit/push_dialog"
require "fugit/revert_commit_dialog"
require "fugit/run_command_dialog"
require "fugit/tab_toolbar"


version = File.exist?(File.join(File.dirname(__FILE__), "..", ".git")) ? "Developer's alpha" : Gem.searcher.find("fugit").version.to_s rescue "Unknown"

Wx::App.run do
	self.app_name = "Fugit"
	frame = Fugit::MainFrame.new("Fugit", version)
	frame.show
end
