include Wx

class WingitIndexList < Panel
	attr_accessor :unstaged, :staged

	def initialize(parent)
		super(parent, ID_ANY)

		@unstaged = ListBox.new(self, ID_ANY, nil, nil, nil, LB_EXTENDED)
		@staged = ListBox.new(self, ID_ANY, nil, nil, nil, LB_EXTENDED)

		box = BoxSizer.new(VERTICAL)
		box.add(@unstaged, 1, EXPAND)
		box.add(@staged, 1, EXPAND)
		self.set_sizer(box)

		evt_listbox_dclick(@unstaged.get_id, :on_unstaged_double_click)
		evt_listbox_dclick(@staged.get_id, :on_staged_double_click)

		update
	end

	def update()
		others = `git ls-files --others --exclude-standard`
		deleted = `git ls-files --deleted`
		modified = `git ls-files --modified`
		staged = `git ls-files --stage`

		@unstaged.clear
		@staged.clear

		others.split("\n").each {|file| @unstaged.append(file + " (N)")}
		deleted.split("\n").each {|file| @unstaged.append(file + " (D)")}
		modified.split("\n").each {|file| @unstaged.append(file + " (M)")}
		staged.split("\n").each do |line|
			(info, file) = line.split("\t")
			@staged.append(file)
		end
	end

	def on_unstaged_double_click(event)
		i = event.get_index
		file = @unstaged.get_string(i)
		@staged.append(file)
		@unstaged.delete(i)
	end

	def on_staged_double_click(event)
		i = event.get_index
		file = @staged.get_string(i)
		@unstaged.append(file)
		@staged.delete(i)
	end

end
