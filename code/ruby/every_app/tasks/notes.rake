require "code_notes"
desc "Enumerate all annotations (use notes:optimize, :fixme, :todo for focus)"
task :notes do
  CodeNotes::SourceAnnotationExtractor.enumerate "OPTIMIZE|FIXME|TODO", tag: true
end

namespace :notes do
  ["OPTIMIZE", "FIXME", "TODO"].each do |annotation|
    # desc "Enumerate all #{annotation} annotations"
    task annotation.downcase.intern do
      CodeNotes::SourceAnnotationExtractor.enumerate annotation
    end
  end

  desc "Enumerate a custom annotation, specify with ANNOTATION=CUSTOM"
  task :custom do
    CodeNotes::SourceAnnotationExtractor.enumerate ENV["ANNOTATION"]
  end
end
