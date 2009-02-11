
$:.unshift File.dirname(__FILE__)

require 'wx'

require "fugit/messages"
require "fugit/icon_loader"
require "fugit/main_frame"
require "fugit/commit"
require "fugit/console"
require "fugit/diff"
require "fugit/index_list"


Wx::App.run do
	self.app_name = "Fugit"
	frame = Fugit::MainFrame.new("Fugit", "0.0.1 Alpha")
	frame.show
end
