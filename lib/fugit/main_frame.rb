include Wx
include IconLoader

module Wx
	class EvtHandler
		def repo
			@@repo
		end

		def repo=(val)
			@@repo = val
		end
	end
end


module Fugit
	class MainFrame < Frame
		def initialize(title, version)
			pwd = setup_working_directory
			super(nil, :title => "#{pwd} - #{title}#{version == "Developer's alpha" ? " ~~ALPHA~~" : ""}", :size => [ 800, 600 ])

			@app_verion = version

			self.repo = Grit::Repo.new(Dir.pwd)

			@notebook = Notebook.new(self, ID_ANY, :style => FULL_REPAINT_ON_RESIZE)
			@commit_panel = CommitTab.new(@notebook)
			@history_panel = HistroyTab.new(@notebook)
			@notebook.add_page(@commit_panel, "Commit", true)
			@notebook.add_page(@history_panel, "History")

			box = BoxSizer.new(VERTICAL)
			box.add(@notebook, 1, EXPAND)
			self.set_sizer(box)

			set_min_size(Size.new(400,300))

			icon_file = File.expand_path(File.join(IconBasePath, "plus_minus.gif"))
			self.icon = Icon.new(icon_file, BITMAP_TYPE_GIF)

			evt_notebook_page_changed(@notebook) {|event| send_message(:tab_switch)}

			menu_bar = MenuBar.new

			# The "file" menu
			menu_file = Menu.new
			# Using ID_EXIT standard id means the menu item will be given the right label for the platform and language, and placed in the correct platform-specific menu - eg on OS X, in the Application's menu
			menu_file.append(ID_SAVE, "&Save commit\tCtrl-S", "Save commit")
			push = menu_file.append(ID_ANY, "&Push\tCtrl-P", "Push commits to a remote repo")
			refresh = menu_file.append(ID_ANY, "&Refresh\tF5", "Refresh the index list")
			menu_file.append(ID_EXIT, "E&xit", "Quit this program")
			menu_bar.append(menu_file, "&File")

			# The "help" menu
			menu_help = Menu.new
			menu_help.append(ID_ABOUT, "&About...\tF1", "Show about dialog")
			menu_bar.append(menu_help, "&Help")

			# Assign the menubar to this frame
			self.menu_bar = menu_bar

			evt_menu(ID_SAVE) {|event| send_message(:save_clicked)}
			evt_menu(push) {|event| send_message(:push_clicked)}
			evt_menu(refresh) {|event| send_message(:refresh)}
			evt_menu(ID_EXIT) {|event| close} # End the application; it should finish automatically when the last window is closed.
			evt_menu(ID_ABOUT) do |event|
				Wx::about_box(:name => self.title, :version => @app_verion, :description => "WxRuby-based git GUI", :developers => ['tekkub - http://tekkub.github.com'])
			end
			evt_close() do |event|
				send_message(:exiting) # Notify listeners that we're closing up shop
				destroy
				exit
			end
		end

		def setup_working_directory
			orig = Dir.pwd
			last_dir = nil
			while !File.exist?(".git") && last_dir != Dir.pwd
				last_dir = Dir.pwd
				Dir.chdir("..")
			end
			Dir.chdir(orig) unless File.exist?(".git") # We got to the top level without finding a git directory
			File.basename(Dir.pwd)
		end

	end
end
