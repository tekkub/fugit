#~ include Wx

class WingitFrame < Wx::Frame
	attr_accessor :app_verion

	def initialize(title, version)
		super(nil, :title => title, :size => [ 800, 600 ])

		self.app_verion = version

		# Set up our AUI manager
		@mgr = Wx::AuiManager.new
		@mgr.set_managed_window(self)

		@notebook_style = Wx::AUI_NB_DEFAULT_STYLE|
		Wx::AUI_NB_TAB_EXTERNAL_MOVE|Wx::NO_BORDER
		@notebook_theme = 0
		@pr_visible = true
		#~ setup_menu
		set_min_size( Wx::Size.new(400,300) )
		setup_panes
		#~ setup_events
		@mgr.update

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


	#####################
	##      Setup      ##
	#####################

	def setup_panes
		@page_bmp = Wx::ArtProvider::get_bitmap(Wx::ART_NORMAL_FILE, Wx::ART_OTHER, Wx::Size.new(16,16))

		pi = Wx::AuiPaneInfo.new
		pi.set_name('tree_content').bottom
		pi.set_layer(1).set_position(1)
		@mgr.add_pane(create_console, pi)
	end

	def create_console
		panel = Wx::Panel.new(self, Wx::ID_ANY)
		@output = Wx::TextCtrl.new(panel, Wx::ID_ANY, nil, nil, nil, Wx::NO_BORDER|Wx::TE_MULTILINE|Wx::TE_READONLY|Wx::TE_DONTWRAP)
		@console = Wx::TextCtrl.new(panel, Wx::ID_ANY, nil, nil, Wx::Size.new(20, 20))

		box = Wx::BoxSizer.new(Wx::VERTICAL)
		box.add(@output, 1, Wx::EXPAND)
		box.add(@console, 0, Wx::EXPAND)
		panel.set_sizer(box)
		return panel
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


#~ require 'yaml'
#~ require 'lexer.rb'
#~ require 'scintilla.rb'
#~ require 'treectrl.rb'

#~ Minimal_Quit = 1
#~ Minimal_About = ID_ABOUT
#~ Toggle_Whitespace = 5000
#~ Toggle_EOL = 5001

#~ class AuiFrame < Wx::Frame
	#~ def initialize(*args)
		#~ super
		#~ @mgr = Wx::AuiManager.new
		#~ @mgr.set_managed_window(self)

		#~ @notebook_style = Wx::AUI_NB_DEFAULT_STYLE|
			#~ Wx::AUI_NB_TAB_EXTERNAL_MOVE|Wx::NO_BORDER
		#~ @notebook_theme = 0
		#~ @pr_visible = true
		#~ setup_menu
		#~ set_min_size( Wx::Size.new(400,300) )
		#~ setup_panes
		#~ setup_events
		#~ @mgr.update
	#~ end
