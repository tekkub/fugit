
class IO
	def get_line
		line = nil
		while c = self.read(1)
			if c == "\r" || c == "\n"
				break if line
			else
				line ||= ""
				line << c
			end
		end
		line
	end
end
