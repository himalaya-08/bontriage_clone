module Fastlane
  module Actions
    module SharedValues
      FL_CHANGELOG ||= :FL_CHANGELOG # originally defined in ChangelogFromGitCommitsAction
    end

    class MakeChangelogFromJenkinsAction < Action
      def self.run(params)
        require 'json'
        require 'net/http'

        changelog = ""

        if Helper.ci? || Helper.test?
          # The "BUILD_URL" environment variable is set automatically by Jenkins in every build
          jenkins_api_url = URI(ENV["BUILD_URL"] + "api/json\?wrapper\=changes\&xpath\=//changeSet//comment")
          begin
            json = JSON.parse(Net::HTTP.get(jenkins_api_url))
            json['changeSet']['items'].each do |item|
              comment = params[:include_commit_body] ? item['comment'] : item['msg']
              changelog << comment.strip + "\n"
            end
          rescue => ex
            UI.error("Unable to read/parse changelog from jenkins: #{ex.message}")
          end
        end

        Actions.lane_context[SharedValues::FL_CHANGELOG] = changelog.strip.length > 0 ? changelog : params[:fallback_changelog]
      end

      def self.description
        "Generate a changelog using the Changes section from the current Jenkins build"
      end

      def self.details
        "This is useful when deploying automated builds. The changelog from Jenkins lists all the commit messages since the last build."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :fallback_changelog,
                                       description: "Fallback changelog if there is not one on Jenkins, or it couldn't be read",
                                       optional: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :include_commit_body,
                                       description: "Include the commit body along with the summary",
                                       optional: true,
                                       type: Boolean,
                                       default_value: true)
        ]
      end

      def self.output
        [
          ['FL_CHANGELOG', 'The changelog generated by Jenkins']
        ]
      end

      def self.authors
        ["mandrizzle"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'make_changelog_from_jenkins(
            # Optional, lets you set a changelog in the case is not generated on Jenkins or if ran outside of Jenkins
            fallback_changelog: "Bug fixes and performance enhancements"
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
