include Wx
include IconLoader

module Fugit
	class Commit < Panel
		def initialize(parent)
			super(parent, ID_ANY)

			@input = TextCtrl.new(self, ID_ANY, nil, nil, nil, TE_MULTILINE|TE_DONTWRAP)
			@author = TextCtrl.new(self, ID_ANY)
			@committer = TextCtrl.new(self, ID_ANY)
			@committer.disable

			box = BoxSizer.new(HORIZONTAL)
			box.add(@committer, 1, EXPAND)
			box.add(@author, 1, EXPAND)

			flex = FlexGridSizer.new(2,2,0,0)
			flex.add(StaticText.new(self, ID_ANY, "Committer/Author:"), 0, EXPAND)
			flex.add(box, 0, EXPAND)
			flex.add(StaticText.new(self, ID_ANY, "Commit message:"), 0, EXPAND)
			flex.add(@input, 0, EXPAND)
			flex.add_growable_row(1)
			flex.add_growable_col(1)

			box = BoxSizer.new(VERTICAL)
			box.add(flex, 1, EXPAND)
			self.set_sizer(box)

			register_for_message(:make_commit, :on_commit_clicked)
			register_for_message(:commit_saved, :on_commit_saved)
			register_for_message(:refresh, :update)

			name = `git config user.name`
			email = `git config user.email`
			@committer.set_value("#{name.chomp} <#{email.chomp}>")
			@author.set_value("#{name.chomp} <#{email.chomp}>")
		end

		def on_commit_clicked
			msg = @input.get_value
			if !has_staged_changes?
				@nothing_to_commit_error ||= MessageDialog.new(self, "No changes are staged to commit.", "Commit error", OK|ICON_ERROR)
				@nothing_to_commit_error.show_modal
			elsif msg.empty?
				@no_msg_error ||= MessageDialog.new(self, "Please enter a commit message.", "Commit error", OK|ICON_ERROR)
				@no_msg_error.show_modal
			else
				commit_file = File.join(Dir.pwd, ".git", "fugit_commit.txt")
				File.open(commit_file, "w") {|f| f << msg}
				`git commit --file=.git/fugit_commit.txt --author="#{@author.get_value}"`
				File.delete(commit_file)
				send_message(:commit_saved)
			end
		end

		def on_commit_saved
			name = `git config user.name`
			email = `git config user.email`
			@author.set_value("#{name.chomp} <#{email.chomp}>")
			@input.set_value("")
		end

		def has_staged_changes?
			staged = `git ls-files --stage`
			last_commit = `git ls-tree -r HEAD`

			committed = {}
			last_commit.split("\n").map do |line|
				(info, file) = line.split("\t")
				sha = info.match(/[a-f0-9]{40}/)[0]
				committed[file] = sha
			end

			staged = staged.split("\n").map do |line|
				(info, file) = line.split("\t")
				sha = info.match(/[a-f0-9]{40}/)[0]
				[file, sha]
			end
			staged.reject! {|file, sha| committed[file] == sha}
			!staged.empty?
		end

	end
end
