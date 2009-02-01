#!/usr/bin/env ruby

begin
	require 'rubygems'
rescue LoadError
end
require 'wx'
require 'wingit_frame'


Wx::App.run do
	self.app_name = 'Wingit'
	frame = WingitFrame.new("Wingit", "0.1 Alpha")
	frame.show
end
