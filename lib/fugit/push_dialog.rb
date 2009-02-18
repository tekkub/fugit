include Wx

module Fugit
	class PushDialog < Dialog
		def initialize(parent)
			super(parent, ID_ANY, "Push branches", :size => Size.new(400, 400))

			@branch_list = CheckListBox.new(self, ID_ANY)
			@log = TextCtrl.new(self, ID_ANY, :size => Size.new(20, 100), :style => TE_MULTILINE|TE_DONTWRAP|TE_READONLY)
			@progress = Gauge.new(self, ID_ANY, 100, :size => Size.new(20, 20))

			butt_sizer = create_button_sizer(OK|CANCEL)
			ok_id = get_affirmative_id
			evt_button(ok_id, :on_ok)

			box = BoxSizer.new(VERTICAL)
			box.add(StaticText.new(self, ID_ANY, "Select branches:"), 0, EXPAND)
			box.add(@branch_list, 1, EXPAND)
			box.add_spacer(4)
			box.add(@log, 0, EXPAND)
			box.add(@progress, 0, EXPAND)
			box.add(butt_sizer, 0, EXPAND)
			self.set_sizer(box)
		end

		def show
			branches = `git branch`
			current = branches.match(/\* (.+)/).to_a.last
			branches = branches.split("\n").map {|b| b.split(" ").last}
			@branch_list.set(branches)
			@branch_list.check(@branch_list.find_string(current)) if current

			@progress.set_value(0)
			@log.clear

			super
		end

		def on_ok
			@progress.set_value(0)
			failed = false
			branches = @branch_list.get_checked_items.map {|i| @branch_list.get_string(i)}
			command = "git push origin #{branches.join(" ")}"
			@log.append_text("\n> #{command}")
			last_line_type = nil
			IO.popen("#{command} 2>&1") do |io|
				while line = io.get_line
					last_line_type = case line
						when "Everything up-to-date"
							@progress.set_value(100)
							update_log(last_line_type, nil, line)
						when /Counting objects: \d+, done./
							@progress.set_value(10)
							update_log(last_line_type, :counting, line)
						when /Counting objects: \d+/
							update_log(last_line_type, :counting, line)
						when /Compressing objects:\s+\d+% \((\d+)\/(\d+)\)/
							@progress.set_value(10 + (45*$1.to_f/$2.to_f).to_i)
							update_log(last_line_type, :compressing, line)
						when /Writing objects:\s+\d+% \((\d+)\/(\d+)\)/
							@progress.set_value(55 + (45*$1.to_f/$2.to_f).to_i)
							update_log(last_line_type, :writing, line)
						when /\[rejected\]/
							failed = true
							@progress.set_value(100)
							update_log(last_line_type, nil, line)
						else
							update_log(last_line_type, nil, line)
						end
				end
			end

			#~ end_modal(ID_OK) if success
		end

		def update_log(last, current, line)
			if last == current && !last.nil?
				@log.replace(@log.xy_to_position(0, @log.get_number_of_lines - 1), @log.get_last_position, line)
			else
				@log.append_text("\n" + line)
			end
			current
		end

	end
end
