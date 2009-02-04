include Wx

class WingitFrame < Frame
	attr_accessor :app_verion, :index, :commit, :diff

	def initialize(title, version)
		super(nil, :title => title, :size => [ 800, 600 ])

		self.app_verion = version

		# Set up our AUI manager
		@mgr = AuiManager.new
		@mgr.set_managed_window(self)

		set_min_size(Size.new(400,300))
		setup_panes

		icon_file = File.join(File.dirname(__FILE__), "icons", "plus_minus.gif")
		self.icon = Icon.new(icon_file, BITMAP_TYPE_GIF)

		menu_bar = MenuBar.new

		# The "file" menu
		menu_file = Menu.new
		# Using ID_EXIT standard id means the menu item will be given the right label for the platform and language, and placed in the correct platform-specific menu - eg on OS X, in the Application's menu
		menu_file.append(ID_SAVE, "&Save commit\tCtrl-S", "Save commit")
		refresh = menu_file.append(ID_ANY, "&Refresh\tF5", "Refresh the index list")
		menu_file.append(ID_EXIT, "E&xit\tAlt-X", "Quit this program")
		menu_bar.append(menu_file, "&File")

		# The "help" menu
		menu_help = Menu.new
		menu_help.append(ID_ABOUT, "&About...\tF1", "Show about dialog")
		menu_bar.append(menu_help, "&Help")

		# Assign the menubar to this frame
		self.menu_bar = menu_bar

		evt_menu(ID_SAVE) {|event| @commit.on_commit_clicked}
		evt_menu(refresh) {|event| update}
		evt_menu(ID_EXIT, :on_quit)
		evt_menu(ID_ABOUT, :on_about)

		@mgr.update
	end


	#####################
	##      Setup      ##
	#####################

	def setup_panes
		pi = AuiPaneInfo.new
		size = Size.new(800, 150)
		pi.bottom.set_name('commit').set_caption("Commit").set_layer(1).set_position(1).set_best_size(size).set_min_size(size).set_floating_size(size)
		@commit = WingitCommit.new(self)
		@mgr.add_pane(@commit, pi)

		#~ pi = AuiPaneInfo.new
		#~ size = Size.new(800, 75)
		#~ pi.bottom.set_name('console').set_caption("Console").set_layer(3).set_position(1).set_best_size(size).set_min_size(size).set_floating_size(size).set_maximize_button.set_minimize_button
		#~ @mgr.add_pane(WingitConsole.new(self), pi)

		pi = AuiPaneInfo.new
		size = Size.new(150, 350)
		pi.left.set_name('index').set_caption("Index").set_layer(2).set_position(1).set_best_size(size).set_min_size(size).set_floating_size(size)
		@index = WingitIndexList.new(self)
		@mgr.add_pane(@index, pi)

		pi = AuiPaneInfo.new
		size = Size.new(200, 350)
		pi.center_pane.set_name('diff')
		@diff = WingitDiff.new(self)
		@mgr.add_pane(@diff, pi)
	end


	def update()
		@index.update
		@commit.update
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
