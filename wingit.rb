#!/usr/bin/env ruby

begin
  require 'rubygems'
rescue LoadError
end
require 'wx'


class WingitFrame < Wx::Frame
  attr_accessor :app_verion

  def initialize(title, version)
    super(nil, :title => title, :size => [ 800, 600 ])

    self.app_verion = version

    # PNG can be used on all platforms, but icon type must be specified to work on Windows. Note that OS X doesn't have "Frame" icons.
    #~ icon_file = File.join( File.dirname(__FILE__), "mondrian.png")
    #~ self.icon = Wx::Icon.new(icon_file, Wx::BITMAP_TYPE_PNG)

    menu_bar = Wx::MenuBar.new

    # The "file" menu
    menu_file = Wx::Menu.new
    # Using Wx::ID_EXIT standard id means the menu item will be given the right label for the platform and language, and placed in the correct platform-specific menu - eg on OS X, in the Application's menu
    menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menu_bar.append(menu_file, "&File")

    # The "help" menu
    menu_help = Wx::Menu.new
    menu_help.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    menu_bar.append(menu_help, "&Help")

    # Assign the menubar to this frame
    self.menu_bar = menu_bar

    # Create a status bar at the bottom of the frame
    create_status_bar(2)
    self.status_text = "Welcome to Wingit!"

    # Set it up to handle menu events using the relevant methods.
    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about
  end

  # End the application; it should finish automatically when the last window is closed.
  def on_quit
    close()
  end

  def on_about
    Wx::about_box(:name => self.title, :version => self.app_verion, :description => "WxRuby-based git GUI", :developers => ['tekkub - http://tekkub.github.com'])
  end
end


Wx::App.run do
  self.app_name = 'Wingit'
  frame = WingitFrame.new("Wingit", "0.1 Alpha")
  frame.show
end
