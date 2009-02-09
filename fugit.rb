#!/usr/bin/env ruby

begin
	require 'rubygems'
rescue LoadError
end
require 'wx'

require "messages"
require "icon_loader"
require "main_frame"
require "commit"
require "console"
require "diff"
require "index_list"


Wx::App.run do
	self.app_name = "Fugit"
	frame = Fugit::MainFrame.new("Fugit", "0.0.1 Alpha")
	frame.show
end
