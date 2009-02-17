
$:.unshift File.dirname(__FILE__)

require 'wx'

require "fugit/messages"
require "fugit/icon_loader"
require "fugit/main_frame"
require "fugit/commit_tab"
require "fugit/commit"
require "fugit/console"
require "fugit/diff"
require "fugit/index_list"
require "fugit/history_tab"
require "fugit/graph_renderer"
require "fugit/history_list"


version = File.exist?(File.join(File.dirname(__FILE__), "..", ".git")) ? "Developer's alpha" : Gem.searcher.find("fugit").version.to_s rescue "Unknown"

Wx::App.run do
	self.app_name = "Fugit"
	frame = Fugit::MainFrame.new("Fugit", version)
	frame.show
end
