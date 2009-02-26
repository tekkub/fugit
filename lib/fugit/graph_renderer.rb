# encoding: utf-8

module Fugit
	module GraphRenderer
		def graphify(commits, branch_refs)
			branch_refs = branch_refs.map {|b| b[1]}.uniq

			graph = []
			branch_parents = [commits.first[0]]
			commits.each do |sha, parents, comment|
				parents = parents.split(" ")
				branches = []
				parent_found = false
				children = branch_parents.select {|b| b == sha}
				branch_parents.each do |parent|
					indicator = "│"
					indicator = " " if parent.empty?
					indicator = "┼" if parent_found && children.size > 1 && !parent.empty?
					indicator = "○" if sha == parent && !parent_found
					indicator = "□" if sha == "uncomitted"
					indicator = "┘" if sha == parent && parent_found
					children.shift if sha == parent && parent_found
					parent_found = true if sha == parent
					branches << indicator
				end
				sha_found = false
				branch_parents.map! do |b|
					match = sha_found && sha == b
					sha_found = sha == b if !sha_found
					match ? "" : b
				end
				if parents.empty?
					branch_parents.delete(sha)
				else
					sha_index = branch_parents.index(sha)
					branch_parents[sha_index] = parents.shift if sha_index
					parents.each do |p|
						branch_parents << p
						branches << "┐" if sha_index
					end
					branches << "○" unless sha_index
					if parents.empty?
						found = false
						branchoffs = branches.select{|b| b == "┘"}
						branches.map! do |b|
							val = !found ? b : case b
								when "┘"
									branchoffs.shift
									"┴"
								when " "
									branchoffs.empty? ? " " : "─"
								else
									b
								end
							found ||= b == "○"
							val
						end
						branches.reverse!
						found = false
						branches.map! do |b|
							was_found = !found && b == "┴"
							found = was_found if !found
							was_found ? "┘" : b
						end
						branches.reverse!
					else
						found = false
						branches.map! do |b|
							val = !found ? b : case b
								when "│"
									"┼"
								when "┘"
									"┴"
								when " "
									"─"
								else
									b
								end
							found = b == "○" if !found
							val
						end
					end
				end
				branch_parents.reverse!
				matched = false
				branch_parents.reject! do |parent|
					match = !matched && parent == ""
					matched = parent != "" if !matched
					match
				end
				branch_parents.reverse!
				branches.map! {|b| b == "○" ? "●" : b} if branch_refs.include?(sha)
				graph << [branches.join, comment, sha]
			end
			graph
		end
	end
end
