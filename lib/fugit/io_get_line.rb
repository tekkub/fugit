
class IO
	def get_line
		line = nil
		ending = nil
		while c = self.read(1)
			line ||= ""
			line << c
			if c == "\r" || c == "\n"
				break
			end
		end
		line
	end
end
