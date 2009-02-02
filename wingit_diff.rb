include Wx

class WingitDiff < RichTextCtrl
	def initialize(parent)
		super(parent, ID_ANY, nil, nil, nil, NO_BORDER|TE_MULTILINE|TE_READONLY|TE_DONTWRAP)
	end

	def set_diff(value)
		self.clear

		red = Colour.new(256*3/4, 0, 0)
		green = Colour.new(0, 128, 0)

		lines = value.split("\n")[4..-1]
		lines.each do |line|
			case line[0..0]
			when "@"
				begin_text_colour(BLUE)
			when "-"
				begin_text_colour(red)
			when "+"
				begin_text_colour(green)
			else
				begin_text_colour(BLACK)
			end

			self.write_text(line+"\n")
		end
	end

end
