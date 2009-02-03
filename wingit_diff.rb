include Wx

class WingitDiff < StyledTextCtrl
	def initialize(parent)
		super(parent, ID_ANY)

		self.set_margin_left(5)
		self.set_margin_width(1, 0)

		self.style_clear_all

		(0..6).each {|i| self.style_set_face_name(i, "Courier New")}
		{
			2 => [0, 150, 150], # Header
			3 => [150, 150, 0], # File
			4 => [0, 0, 150], # Hunk
			5 => [160, 0, 0], # Removed
			6 => [0, 96, 0], # Added
		}.each{|num, c| self.style_set_foreground(num, Wx::Colour.new(c[0], c[1], c[2]))}

		{
			5 => [255, 220, 220], # Removed
			6 => [220, 255, 220], # Added
		}.each do|num, c|
			self.style_set_background(num, Wx::Colour.new(c[0], c[1], c[2]))
			self.style_set_eol_filled(num, true)
		end
	end

	def set_diff(value)
		value = value.split("\n")[4..-1].join("\n")
		self.set_lexer(STC_LEX_DIFF)
		self.write_value(value)
	end

	def clear
		self.write_value("")
	end

	def change_value(value)
		self.set_lexer(0)
		self.write_value(value)
	end

	def write_value(value)
		self.set_read_only(false)
		self.set_text(value)
		self.set_read_only(true)
	end

end
