Gem::Specification.new do |s|
  s.name = %q{fugit}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tekkub"]
  s.date = %q{2009-02-11}
  s.default_executable = %q{fugit}
  s.description = %q{A cross-platform replacement for git-gui based on wxruby}
  s.email = %q{tekkub@gmail.com}
  s.executables = ["fugit"]
  s.files = ["fugit.gemspec", "SciTE.properties", "VERSION.yml", "bin/fugit", "lib/fugit", "lib/fugit/commit.rb", "lib/fugit/console.rb", "lib/fugit/diff.rb", "lib/fugit/icon_loader.rb", "lib/fugit/index_list.rb", "lib/fugit/main_frame.rb", "lib/fugit/messages.rb", "lib/fugit/SciTE.properties", "lib/fugit.rb", "lib/icons", "lib/icons/asterisk_yellow.png", "lib/icons/disk.png", "lib/icons/folder_add.png", "lib/icons/folder_delete.png", "lib/icons/page_add.png", "lib/icons/page_delete.png", "lib/icons/page_down.gif", "lib/icons/page_up.gif", "lib/icons/plus_minus.gif", "lib/icons/script.png", "lib/icons/script_add.png", "lib/icons/script_delete.png", "lib/icons/script_edit.png", "lib/icons/text_signature.png", "lib/icons/tick.png"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/tekkub/fugit}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A cross-platform replacement for git-gui based on wxruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<wxruby>, [">= 1.9.9"])
    else
      s.add_dependency(%q<wxruby>, [">= 1.9.9"])
    end
  else
    s.add_dependency(%q<wxruby>, [">= 1.9.9"])
  end
end

