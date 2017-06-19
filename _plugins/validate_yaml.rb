# Plugin to validate the YAML headers of lesson pages.
# Inspired by a very useful answer from Christian: http://stackoverflow.com/a/43909411/3547541

module MyModule

  class WarningGenerator < Jekyll::Generator
    def generate(site)

      # Empty array to collect all errors across the site
      total_errors = Array.new

      # ANSI codes to color the warnings red
      red = "\e[31m"
      clear = "\e[0m"

      # Find all the pages that represent non-deprecated lessons
      lessons = site.pages.select{|i| i.data["lesson"] && !i.data["deprecated"]}

      lessons.each do |p|

        page_errors = Array.new

        # Collect all valid topics
        valid_topics = site.data["topics"].map{|t| t["type"]}

        # Collect all valid activities
        valid_activites = ["acquiring", "analyzing", "transforming", "presenting", "preserving"]

        valid_difficulties = [1, 2, 3]

        # For each required field, check if it is missing on the page. If so, log an error.
        required_fields = ["layout", "reviewers", "authors", "date", "title", "difficulty", "activity", "topics"]

        required_fields.each do |f|
          if p.data[f].nil?
            page_errors.push("'#{f}' is missing.")
          end
        end

        # For each activity, topic, or difficulty, check that it is within allowed ranges

        lesson_activity = p.data["activity"]

        unless lesson_activity.nil?
          if !valid_activites.include?(lesson_activity)
              page_errors.push("'#{lesson_activity}' is not a valid lesson activity.")
          end
        end

        lesson_topics = p.data["topics"]

        unless lesson_topics.nil?
          lesson_topics.each do |t|
            if !valid_topics.include?(t)
              page_errors.push("'#{t}' is not a valid lesson topic.")
            end
          end
        end

        lesson_difficulty = p.data["difficulty"]

        unless lesson_difficulty.nil?
          if !valid_difficulties.include?(lesson_difficulty)
            page_errors.push("'#{lesson_difficulty}' is not a valid lesson difficulty.'")
          end
        end

        # Spanish required fields
        es_required_fields = ["translator", "translation-reviewer", "redirect_from"]

        if p.data["translated-lesson"]
          es_required_fields.each do |f|
            if p.data[f].nil?
              page_errors.push("'#{f}' is missing.")
            end
          end
        end

        # English required fields
        en_required_fields = ["editors"]
        if p.data["translated-lesson"].nil?
          en_required_fields.each do |f|
            if p.data[f].nil?
              page_errors.push("'#{f}' is missing.")
            end
          end
        end

        unless page_errors.empty?
          # Throw a warning with the filename
          warn "#{red}In #{p.dir}#{p.name}:#{clear}"
          
          # Add some formatting to the errors and then throw them
          unit_errors = page_errors.map{|e| "\t - #{e}"}

          unit_errors.each do |e|
            warn "#{red}#{e}#{clear}"
          end

          # Finally, add all errors on the page to the master error list
          total_errors.concat(page_errors)
        end
      end

      # Iff there were page errors, raise an exception that will halt the build
      unless total_errors.empty?
        raise "#{red}There were YAML errors.#{clear}"
      end
    end
  end
end