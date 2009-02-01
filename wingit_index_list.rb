include Wx

class WingitIndexList < Panel

	attr_accessor :unstaged, :staged, :diff


	def initialize(parent)
		super(parent, ID_ANY)

		@unstaged = ListBox.new(self, ID_ANY, nil, nil, nil, LB_EXTENDED)
		@staged = ListBox.new(self, ID_ANY, nil, nil, nil, LB_EXTENDED)

		box = BoxSizer.new(VERTICAL)
		box.add(@unstaged, 1, EXPAND)
		box.add(@staged, 1, EXPAND)
		self.set_sizer(box)

		evt_listbox(@unstaged.get_id, :on_unstaged_click)
		evt_listbox(@staged.get_id, :on_staged_click)
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

		others.split("\n").each {|file| @unstaged.append(file + " (N)", [file, "N"])}
		deleted.split("\n").each {|file| @unstaged.append(file + " (D)", [file, "D"])}
		modified.split("\n").each {|file| @unstaged.append(file + " (M)", [file, "M"])}
		staged.split("\n").each do |line|
			(info, file) = line.split("\t")
			diff = `git diff --cached -- #{file}`
			@staged.append(file) unless diff.empty?
		end
	end


	def on_unstaged_click(event)
		@staged.deselect(-1) # Clear the other box's selection

		i = event.get_index
		(file, change) = @unstaged.get_item_data(i)

		case change
		when "N"
			val = `cat #{file}`
		when "M"
			val = `git diff -- #{file}`
		else
			val = ""
		end

		@diff.change_value(val)
	end


	def on_staged_click(event)
		@unstaged.deselect(-1) # Clear the other box's selection

		i = event.get_index
		file = @staged.get_string(i)

		val = `git diff --cached -- #{file}`
		@diff.change_value(val)
	end


	def on_unstaged_double_click(event)
		(file, change) = @unstaged.get_item_data(event.get_index)
		`git add #{file}`
		update
	end


	def on_staged_double_click(event)
		file = @staged.get_string(event.get_index)
		`git reset #{file}`
		update
	end

end
