require_relative 'build_details'

module Spaceship
  module Tunes
    # Represents a build which is inside the build train
    class Build < TunesBase
      #####################################################
      # @!group General metadata
      #####################################################

      # @return (String) The App identifier of this app, provided by App Store Connect
      # @example
      #   "1013943394"
      attr_accessor :apple_id

      # @return (Spaceship::Tunes::BuildTrain) A reference to the build train this build is contained in
      attr_accessor :build_train

      # @return (Integer) The ID generated by App Store Connect
      attr_accessor :id

      # @return (Boolean)
      attr_accessor :valid

      # @return (String) The build version (not the version number), but also is named `build number`
      attr_accessor :build_version

      # @return (String) The version number (e.g. 1.3)
      attr_accessor :train_version

      # @return (Boolean) Is this build currently processing?
      attr_accessor :processing

      # @return (String) The build processing state, may be nil
      # @example "invalidBinary"
      # @example "processingFailed"
      attr_accessor :processing_state

      # @return (Integer) The number of ticks since 1970 (e.g. 1413966436000)
      attr_accessor :upload_date

      # @return (String) URL to the app icon of this build (150x150px)
      attr_accessor :icon_url

      # @return (String) The name of the app this build is for
      attr_accessor :app_name

      # @return (String) The platform of this build (e.g. 'ios')
      attr_accessor :platform

      # @return (Integer) When is this build going to be invalid
      attr_accessor :internal_expiry_date

      # @return (Integer): When is the external build going to expire?
      attr_accessor :external_expiry_date

      # @return (Bool) Is external beta testing enabled for this train? Only one train can have enabled testing.
      attr_reader :external_testing_enabled

      # @return (Bool) Is internal beta testing enabled for this train? Only one train can have enabled testing.
      attr_reader :internal_testing_enabled

      # @return (String) The status of internal testflight testing for this build. One of active, submitForReview, approvedInactive, waiting
      attr_reader :external_testing_status

      # @return (Bool) Does this build support WatchKit?
      attr_accessor :watch_kit_enabled

      # @return (Bool):
      attr_accessor :ready_to_install

      #####################################################
      # @!group Analytics
      #####################################################

      # @return (Integer) Number of installs of this build
      attr_accessor :install_count

      # @return (Integer) Number of installs for this build that come from internal users
      attr_accessor :internal_install_count

      # @return (Integer) Number of installs for this build that come from external users
      attr_accessor :external_install_count

      # @return (Integer) Might be nil. The number of sessions for this build
      attr_accessor :session_count

      # @return (Integer) Might be nil. The number of crashes of this build
      attr_accessor :crash_count

      attr_mapping(
        'uploadDate' => :upload_date,
        'iconUrl' => :icon_url,
        'buildVersion' => :build_version,
        'trainVersion' => :train_version,
        'appName' => :app_name,
        'platform' => :platform,
        'id' => :id,
        'valid' => :valid,
        'processing' => :processing,
        'processingState' => :processing_state,

        'installCount' => :install_count,
        'internalInstallCount' => :internal_install_count,
        'externalInstallCount' => :external_install_count,
        'sessionCount' => :session_count,
        'crashCount' => :crash_count,
        'internalExpiry' => :internal_expiry_date,
        'externalExpiry' => :external_expiry_date,
        'watchKitEnabled' => :watch_kit_enabled,
        'readyToInstall' => :ready_to_install,
        'internalTesting.value' => :internal_testing_enabled,
        'externalTesting.value' => :external_testing_enabled,
        'buildTestInformationTO.externalStatus' => :external_testing_status
      )

      def setup
        super

        self.external_expiry_date ||= 0
        self.internal_expiry_date ||= 0
      end

      def details
        response = client.build_details(app_id: self.apple_id,
                                         train: self.train_version,
                                  build_number: self.build_version,
                                      platform: self.platform)
        response['apple_id'] = self.apple_id
        BuildDetails.factory(response)
      end

      def apple_id
        return @apple_id if @apple_id
        return self.build_train.application.apple_id
      end

      def update_build_information!(whats_new: nil,
                                    description: nil,
                                    feedback_email: nil)
        parameters = {
          app_id: self.apple_id,
          train: self.train_version,
          build_number: self.build_version,
          platform: self.platform
        }.merge({
          whats_new: whats_new,
          description: description,
          feedback_email: feedback_email
        })
        client.update_build_information!(parameters)
      end

      # This will submit this build for TestFlight beta review
      # @param metadata [Hash] A hash containing the following information (keys must be symbols):
      #  {
      #    # Required Metadata:
      #     changelog: "Changelog",
      #     description: "Your Description",
      #     feedback_email: "Email Address for Feedback",
      #     marketing_url: "https://marketing.com",
      #     first_name: "Felix",
      #     last_name: "Krause",
      #     review_email: "Contact email address for Apple",
      #     phone_number: "0128383383",
      #     review_notes: "Review notes"
      #
      #   # Optional Metadata:
      #     privacy_policy_url: nil,
      #     review_notes: nil,
      #     review_user_name: nil,
      #     review_password: nil,
      #     encryption: false
      #  }
      # Note that iTC will pull a lot of this information from previous builds or the app store information,
      # all of the required values must be set either in this hash or automatically for this to work
      def submit_for_beta_review!(metadata)
        parameters = {
          app_id: self.apple_id,
          train: self.train_version,
          build_number: self.build_version,
          platform: self.platform
        }.merge(metadata)

        client.submit_testflight_build_for_review!(parameters)

        return parameters
      end

      # @return [String] A nicely formatted string about the state of this build
      # @examples:
      #   External, Internal, Inactive, Expired
      def testing_status
        testing ||= "External" if self.external_testing_enabled
        testing ||= "Internal" if self.internal_testing_enabled

        if Time.at(self.internal_expiry_date / 1000) > Time.now
          testing ||= "Inactive"
        else
          testing = "Expired"
        end

        return testing
      end

      # This will cancel the review process for this TestFlight build
      def cancel_beta_review!
        client.remove_testflight_build_from_review!(app_id: self.apple_id,
                                                     train: self.train_version,
                                              build_number: self.build_version,
                                                  platform: self.platform)
      end
    end
  end
end

# Example Response
# {"sectionErrorKeys"=>[],
#  "sectionInfoKeys"=>[],
#  "sectionWarningKeys"=>[],
#  "buildVersion"=>"1",
#  "trainVersion"=>"1.0",
#  "uploadDate"=>1441975590000,
#  "iconUrl"=>
#   "https://is2-ssl.mzstatic.com/image/thumb/Newsstand3/v4/a9/f9/8b/a9f98b23-592d-af2e-6e10-a04873bed5df/Icon-76@2x.png.png/150x150bb-80.png",
#  "iconAssetToken"=>
#   "Newsstand3/v4/a9/f9/8b/a9f98b23-592d-af2e-6e10-a04873bed5df/Icon-76@2x.png.png",
#  "appName"=>"Updated by fastlane",
#  "platform"=>"ios",
#  "betaEntitled"=>true,
#  "exceededFileSizeLimit"=>false,
#  "wentLiveWithVersion"=>false,
#  "processing"=>false,
#  "processingState": nil,
#  "id"=>5298023,
#  "valid"=>true,
#  "missingExportCompliance"=>false,
#  "waitingForExportComplianceApproval"=>false,
#  "addedInternalUsersCount"=>0,
#  "addedExternalUsersCount"=>0,
#  "invitedExternalUsersCount"=>0,
#  "invitedInternalUsersCount"=>0,
#  "acceptedInternalUsersCount"=>1,
#  "acceptedExternalUsersCount"=>0,
#  "installCount"=>0,
#  "internalInstallCount"=>0,
#  "externalInstallCount"=>0,
#  "sessionCount"=>0,
#  "internalSessionCount"=>0,
#  "externalSessionCount"=>0,
#  "crashCount"=>0,
#  "internalCrashCount"=>0,
#  "externalCrashCount"=>0,
#  "promotedVersion"=>nil,
#  "internalState"=>"inactive",
#  "betaState"=>"submitForReview",
#  "internalExpiry"=>1444567590000,
#  "externalExpiry"=>0,
#  "watchKitEnabled"=>false,
#  "readyToInstall"=>true,
#  "sdkBuildWhitelisted"=>true,
#  "internalTesting"=>{"value"=>false, "isEditable"=>true, "isRequired"=>false, "errorKeys"=>nil},
#  "externalTesting"=>{"value"=>false, "isEditable"=>true, "isRequired"=>false, "errorKeys"=>nil}
