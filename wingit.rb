#!/usr/bin/env ruby

begin
	require 'rubygems'
rescue LoadError
end
require 'wx'

require "messages"
require "icon_loader"
require 'wingit_frame'
require "wingit_commit"
require "wingit_console"
require "wingit_diff"
require "wingit_index_list"


Wx::App.run do
	self.app_name = 'Wingit'
	frame = WingitFrame.new("Wingit", "0.1 Alpha")
	frame.show
end
