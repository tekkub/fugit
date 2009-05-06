# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fugit}
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tekkub"]
  s.date = %q{2009-05-06}
  s.default_executable = %q{fugit}
  s.description = %q{A cross-platform replacement for git-gui based on wxruby}
  s.email = %q{tekkub@gmail.com}
  s.executables = ["fugit"]
  s.files = [
    "Rakefile",
     "VERSION.yml",
     "bin/fugit",
     "lib/fugit.rb",
     "lib/fugit/commit_dialog.rb",
     "lib/fugit/commit_tab.rb",
     "lib/fugit/console.rb",
     "lib/fugit/create_branch_dialog.rb",
     "lib/fugit/delete_branch_dialog.rb",
     "lib/fugit/diff.rb",
     "lib/fugit/fetch_dialog.rb",
     "lib/fugit/graph_renderer.rb",
     "lib/fugit/history_list.rb",
     "lib/fugit/history_tab.rb",
     "lib/fugit/icon_loader.rb",
     "lib/fugit/index_list.rb",
     "lib/fugit/io_get_line.rb",
     "lib/fugit/logged_dialog.rb",
     "lib/fugit/main_frame.rb",
     "lib/fugit/merge_dialog.rb",
     "lib/fugit/messages.rb",
     "lib/fugit/push_dialog.rb",
     "lib/fugit/revert_commit_dialog.rb",
     "lib/fugit/run_command_dialog.rb",
     "lib/fugit/tab_toolbar.rb",
     "lib/grit/API.txt",
     "lib/grit/History.txt",
     "lib/grit/PURE_TODO",
     "lib/grit/README.txt",
     "lib/grit/Rakefile",
     "lib/grit/VERSION.yml",
     "lib/grit/benchmarks.rb",
     "lib/grit/benchmarks.txt",
     "lib/grit/examples/ex_add_commit.rb",
     "lib/grit/examples/ex_index.rb",
     "lib/grit/grit.gemspec",
     "lib/grit/lib/grit.rb",
     "lib/grit/lib/grit/actor.rb",
     "lib/grit/lib/grit/blame.rb",
     "lib/grit/lib/grit/blob.rb",
     "lib/grit/lib/grit/commit.rb",
     "lib/grit/lib/grit/commit_stats.rb",
     "lib/grit/lib/grit/config.rb",
     "lib/grit/lib/grit/diff.rb",
     "lib/grit/lib/grit/errors.rb",
     "lib/grit/lib/grit/git-ruby.rb",
     "lib/grit/lib/grit/git-ruby/commit_db.rb",
     "lib/grit/lib/grit/git-ruby/file_index.rb",
     "lib/grit/lib/grit/git-ruby/git_object.rb",
     "lib/grit/lib/grit/git-ruby/internal/loose.rb",
     "lib/grit/lib/grit/git-ruby/internal/mmap.rb",
     "lib/grit/lib/grit/git-ruby/internal/pack.rb",
     "lib/grit/lib/grit/git-ruby/internal/raw_object.rb",
     "lib/grit/lib/grit/git-ruby/object.rb",
     "lib/grit/lib/grit/git-ruby/repository.rb",
     "lib/grit/lib/grit/git.rb",
     "lib/grit/lib/grit/index.rb",
     "lib/grit/lib/grit/lazy.rb",
     "lib/grit/lib/grit/merge.rb",
     "lib/grit/lib/grit/ref.rb",
     "lib/grit/lib/grit/repo.rb",
     "lib/grit/lib/grit/status.rb",
     "lib/grit/lib/grit/submodule.rb",
     "lib/grit/lib/grit/tag.rb",
     "lib/grit/lib/grit/tree.rb",
     "lib/grit/lib/open3_detach.rb",
     "lib/icons/application_go.png",
     "lib/icons/arrow_divide.png",
     "lib/icons/arrow_divide_add.png",
     "lib/icons/arrow_divide_delete.png",
     "lib/icons/arrow_join.png",
     "lib/icons/arrow_refresh.png",
     "lib/icons/arrow_undo.png",
     "lib/icons/asterisk_yellow.png",
     "lib/icons/cherry.png",
     "lib/icons/cross.png",
     "lib/icons/disk.png",
     "lib/icons/folder_add.png",
     "lib/icons/folder_delete.png",
     "lib/icons/page_add.png",
     "lib/icons/page_delete.png",
     "lib/icons/page_down.gif",
     "lib/icons/page_up.gif",
     "lib/icons/plus_minus.gif",
     "lib/icons/script.png",
     "lib/icons/script_add.png",
     "lib/icons/script_delete.png",
     "lib/icons/script_edit.png",
     "lib/icons/text_signature.png",
     "lib/icons/tick.png"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/tekkub/fugit}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A cross-platform replacement for git-gui based on wxruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<wxruby>, [">= 1.9.9"])
      s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
      s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
    else
      s.add_dependency(%q<wxruby>, [">= 1.9.9"])
      s.add_dependency(%q<mime-types>, [">= 1.15"])
      s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
    end
  else
    s.add_dependency(%q<wxruby>, [">= 1.9.9"])
    s.add_dependency(%q<mime-types>, [">= 1.15"])
    s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  end
end
