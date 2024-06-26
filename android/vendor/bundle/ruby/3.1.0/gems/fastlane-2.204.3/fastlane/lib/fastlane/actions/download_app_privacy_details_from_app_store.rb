module Fastlane
  module Actions
    class DownloadAppPrivacyDetailsFromAppStoreAction < Action
      DEFAULT_PATH = Fastlane::Helper.fastlane_enabled_folder_path
      DEFAULT_FILE_NAME = "app_privacy_details.json"

      def self.run(params)
        require 'spaceship'

        # Prompts select team if multiple teams and none specified
        UI.message("Login to App Store Connect (#{params[:username]})")
        Spaceship::ConnectAPI.login(params[:username], use_portal: false, use_tunes: true, tunes_team_id: params[:team_id], team_name: params[:team_name])
        UI.message("Login successful")

        # Get App
        app = Spaceship::ConnectAPI::App.find(params[:app_identifier])
        unless app
          UI.user_error!("Could not find app with bundle identifier '#{params[:app_identifier]}' on account #{params[:username]}")
        end

        # Download usages and return a config
        raw_usages = download_app_data_usages(params, app)

        usages_config = []
        if raw_usages.count == 1 && raw_usages.first.data_protection.id == Spaceship::ConnectAPI::AppDataUsageDataProtection::ID::DATA_NOT_COLLECTED
          usages_config << {
            "data_protections" => [Spaceship::ConnectAPI::AppDataUsageDataProtection::ID::DATA_NOT_COLLECTED]
          }
        else
          grouped_usages = raw_usages.group_by do |usage|
            usage.category.id
          end
          grouped_usages.sort_by(&:first).each do |key, usage_group|
            purposes = usage_group.map(&:purpose).compact || []
            data_protections = usage_group.map(&:data_protection).compact || []
            usages_config << {
              "category" => key,
              "purposes" => purposes.map(&:id).sort.uniq,
              "data_protections" => data_protections.map(&:id).sort.uniq
            }
          end
        end

        # Save to JSON file
        json = JSON.pretty_generate(usages_config)
        path = output_path(params)

        UI.message("Writing file to #{path}")
        File.write(path, json)
      end

      def self.output_path(params)
        path = params[:output_json_path]
        return File.absolute_path(path)
      end

      def self.download_app_data_usages(params, app)
        UI.message("Downloading App Data Usage")

        # Delete all existing usages for new ones
        Spaceship::ConnectAPI::AppDataUsage.all(app_id: app.id, includes: "category,grouping,purpose,dataProtection", limit: 500)
      end

      def self.description
        "Download App Privacy Details from an app in App Store Connect"
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FASTLANE_USER",
                                       description: "Your Apple ID Username for App Store Connect",
                                       default_value: user,
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       env_name: "UPLOAD_APP_PRIVACY_DETAILS_TO_APP_STORE_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       env_name: "FASTLANE_ITC_TEAM_ID",
                                       description: "The ID of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       skip_type_validation: true, # as we also allow integers, which we convert to strings anyway
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       env_name: "FASTLANE_ITC_TEAM_NAME",
                                       description: "The name of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                       default_value_dynamic: true),

          # JSON paths
          FastlaneCore::ConfigItem.new(key: :output_json_path,
                                       env_name: "UPLOAD_APP_PRIVACY_DETAILS_TO_APP_STORE_OUTPUT_JSON_PATH",
                                       description: "Path to the app usage data JSON file generated by interactive questions",
                                       conflicting_options: [:skip_json_file_saving],
                                       default_value: File.join(DEFAULT_PATH, DEFAULT_FILE_NAME))
        ]
      end

      def self.author
        "igor-makarov"
      end

      def self.is_supported?(platform)
        [:ios, :mac, :tvos].include?(platform)
      end

      def self.details
        "Download App Privacy Details from an app in App Store Connect. For more detail information, view https://docs.fastlane.tools/uploading-app-privacy-details"
      end

      def self.example_code
        [
          'download_app_privacy_details_from_app_store(
            username: "your@email.com",
            team_name: "Your Team",
            app_identifier: "com.your.bundle"
          )',
          'download_app_privacy_details_from_app_store(
            username: "your@email.com",
            team_name: "Your Team",
            app_identifier: "com.your.bundle",
            output_json_path: "fastlane/app_data_usages.json"
          )'
        ]
      end

      def self.category
        :production
      end
    end
  end
end
