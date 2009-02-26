
$:.unshift File.dirname(__FILE__)

require 'wx'

require "fugit/icon_loader"

require "fugit/commit_dialog"
require "fugit/commit_tab"
require "fugit/commit_tab_toolbar"
require "fugit/console"
require "fugit/diff"
require "fugit/graph_renderer"
require "fugit/history_list"
require "fugit/history_tab"
require "fugit/index_list"
require "fugit/io_get_line"
require "fugit/main_frame"
require "fugit/messages"
require "fugit/push_dialog"


version = File.exist?(File.join(File.dirname(__FILE__), "..", ".git")) ? "Developer's alpha" : Gem.searcher.find("fugit").version.to_s rescue "Unknown"

Wx::App.run do
	self.app_name = "Fugit"
	frame = Fugit::MainFrame.new("Fugit", version)
	frame.show
end
