
module IconLoader
	def get_icon(name, type = "png")
		icon = File.join(File.dirname(__FILE__), "icons", name)
		case name[-3..-1].downcase
		when "png"
			bitmap_type = BITMAP_TYPE_PNG
		else
			bitmap_type = BITMAP_TYPE_GIF
		end

		Wx::Bitmap.new(icon, bitmap_type)
	end

end
