include Wx

class WingitDiff < TextCtrl
	def initialize(parent)
		super(parent, ID_ANY, nil, nil, nil, NO_BORDER|TE_MULTILINE|TE_READONLY|TE_DONTWRAP)
	end

end
