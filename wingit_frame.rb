#~ include Wx

require "wingit_console"
require "wingit_diff"
require "wingit_index_list"

class WingitFrame < Wx::Frame
	attr_accessor :app_verion

	def initialize(title, version)
		super(nil, :title => title, :size => [ 800, 600 ])

		self.app_verion = version

		# Set up our AUI manager
		@mgr = Wx::AuiManager.new
		@mgr.set_managed_window(self)

		set_min_size(Wx::Size.new(400,300))
		setup_panes

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

		evt_menu(Wx::ID_EXIT, :on_quit)
		evt_menu(Wx::ID_ABOUT, :on_about)

		@mgr.update
	end


	#####################
	##      Setup      ##
	#####################

	def setup_panes
		pi = Wx::AuiPaneInfo.new
		size = Wx::Size.new(800, 75)
		pi.bottom.set_name('console').set_caption("Console").set_layer(1).set_position(1).set_best_size(size).set_min_size(size).set_floating_size(size).set_maximize_button.set_minimize_button
		@mgr.add_pane(WingitConsole.new(self), pi)

		pi = Wx::AuiPaneInfo.new
		size = Wx::Size.new(200, 350)
		pi.left.set_name('index').set_caption("Index").set_layer(1).set_position(1).set_best_size(size).set_min_size(size).set_floating_size(size)
		index = WingitIndexList.new(self)
		@mgr.add_pane(index, pi)

		pi = Wx::AuiPaneInfo.new
		size = Wx::Size.new(200, 350)
		pi.center_pane.set_name('diff')
		diff = WingitDiff.new(self)
		@mgr.add_pane(diff, pi)

		index.diff = diff
	end


	######################
	##      Events      ##
	######################

	# End the application; it should finish automatically when the last window is closed.
	def on_quit
		close()
	end

	def on_about
		Wx::about_box(:name => self.title, :version => self.app_verion, :description => "WxRuby-based git GUI", :developers => ['tekkub - http://tekkub.github.com'])
	end

end
