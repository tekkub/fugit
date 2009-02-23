
module IconLoader
	IconBasePath = File.expand_path(File.join(File.dirname(__FILE__), "..", "icons"))

	def get_icon(name)
		icon = File.join(IconBasePath, name)
		case name[-3..-1].downcase
		when "png"
			bitmap_type = BITMAP_TYPE_PNG
		else
			bitmap_type = BITMAP_TYPE_GIF
		end

		Wx::Bitmap.new(icon, bitmap_type)
	end

end
