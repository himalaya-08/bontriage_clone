require 'fastlane_core/helper'
require 'fastlane/boolean'
require_relative 'detect_values'

module Gym
  class << self
    attr_accessor :config

    attr_accessor :project

    attr_accessor :cache

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
      @cache = {}
    end

    def gymfile_name
      "Gymfile"
    end

    def init_libs
      # Import all the fixes
      require 'gym/xcodebuild_fixes/generic_archive_fix'
    end

    def building_for_ios?
      if Gym.project.mac?
        # Can be building for iOS if mac project and catalyst
        return building_mac_catalyst_for_ios?
      else
        # Can be iOS project and build for mac if catalyst
        return false if building_mac_catalyst_for_mac?

        # Can be iOS project if iOS, tvOS, or watchOS
        return Gym.project.ios? || Gym.project.tvos? || Gym.project.watchos?
      end
    end

    def building_for_mac?
      if Gym.project.supports_mac_catalyst?
        # Can be a mac project and not build mac if catalyst
        return building_mac_catalyst_for_mac?
      else
        return Gym.project.mac?
      end
    end

    def building_mac_catalyst_for_ios?
      Gym.project.supports_mac_catalyst? && Gym.config[:catalyst_platform] == "ios"
    end

    def building_mac_catalyst_for_mac?
      Gym.project.supports_mac_catalyst? && Gym.config[:catalyst_platform] == "macos"
    end

    def export_destination_upload?
      config_path = Gym.cache[:config_path]
      return false if config_path.nil?

      result = CFPropertyList.native_types(CFPropertyList::List.new(file: config_path).value)
      return result["destination"] == "upload"
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  Boolean = Fastlane::Boolean
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))
  DESCRIPTION = "Building your iOS apps has never been easier"

  Gym.init_libs
end
