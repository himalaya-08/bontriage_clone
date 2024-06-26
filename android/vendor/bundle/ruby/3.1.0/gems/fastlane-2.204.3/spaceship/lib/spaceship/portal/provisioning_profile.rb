require_relative 'app'
require_relative 'device'
require_relative 'certificate'
require_relative 'provisioning_profile_template'

module Spaceship
  module Portal
    # Represents a provisioning profile of the Apple Dev Portal
    #
    # NOTE: If the environment variable `SPACESHIP_AVOID_XCODE_API` is present when using this class, all requests will be made via Apple developer portal API.
    # In the default case, this class will use the Xcode API for fetching provisioning profiles. This is an optimization that results in 1 query for all Profiles vs 1+N queries.
    class ProvisioningProfile < PortalBase
      # @return (String) The ID generated by the Dev Portal
      #   You'll probably not really need this value
      # @example
      #   "2MAY7NPHAA"
      attr_accessor :id

      # @return (String) The UDID of this provisioning profile
      #   This value is used for example for code signing
      #   It is also contained in the actual profile
      # @example
      #   "23d7df3b-9767-4e85-a1ea-1df4d8f32fec"
      attr_accessor :uuid

      # @return (DateTime) The date and time of when the profile
      #   expires.
      # @example
      #   #<DateTime: 2015-11-25T22:45:50+00:00 ((2457352j,81950s,0n),+0s,2299161j)>
      attr_accessor :expires

      # @return (String) The profile distribution type. You probably want to
      #   use the class type to detect the profile type instead of this string.
      # @example AppStore Profile
      #     "store"
      # @example AdHoc Profile
      #     "adhoc"
      # @example Development Profile
      #     "limited"
      # @example Mac Developer ID Profile
      #     "direct"
      attr_accessor :distribution_method

      # @return (String) The name of this profile
      # @example
      #   "com.krausefx.app AppStore"
      attr_accessor :name

      # @return (String) The status of this profile
      # @example Active (profile is fine)
      #   "Active"
      # @example Expired (time ran out)
      #   "Expired"
      # @example Invalid (e.g. code signing identity not available any more)
      #   "Invalid"
      attr_accessor :status

      # @return (String) The type of the profile (development or distribution).
      #   You'll probably not need this value
      # @example Distribution
      #   "iOS Distribution"
      # @example Development
      #   "iOS Development"
      attr_accessor :type

      # @return (String) This will always be "2"
      # @example
      #   "2"
      attr_accessor :version

      # @return (String) The supported platform for this profile
      # @example
      #   "ios"
      attr_accessor :platform

      # @return (String) The supported sub_platform for this profile
      # @example
      #   "tvOS"
      attr_accessor :sub_platform

      # No information about this attribute
      attr_accessor :managing_app

      # A reference to the app this profile is for.
      # You can then easily access the value directly
      # @return (App) The app this profile is for
      #
      # @example Example Value
      #   <Spaceship::Portal::App
      #     @app_id="2UMR2S6PAA"
      #     @name="App Name"
      #     @platform="ios"
      #     @prefix="5A997XSAAA"
      #     @bundle_id="com.krausefx.app"
      #     @is_wildcard=false
      #     @dev_push_enabled=false
      #     @prod_push_enabled=false>
      #
      # @example Usage
      #   profile.app.name
      attr_accessor :app

      # @return (Array) A list of certificates used for this profile
      # @example Example Value
      #  [
      #   <Spaceship::Portal::Certificate::Production
      #     @status=nil
      #     @id="XC5PH8D4AA"
      #     @name="iOS Distribution"
      #     @created=nil
      #     @expires=#<DateTime: 2015-11-25T22:45:50+00:00 ((2457352j,81950s,0n),+0s,2299161j)>
      #     @owner_type="team"
      #     @owner_name=nil
      #     @owner_id=nil
      #     @type_display_id="R58UK2EWAA">]
      #  ]
      #
      # @example Usage
      #   profile.certificates.first.id
      attr_accessor :certificates

      # @return (Array) A list of devices this profile is enabled for.
      #   This will always be [] for AppStore profiles
      #
      # @example Example Value
      #  <Spaceship::Portal::Device
      #    @id="WXQ7V239BE"
      #    @name="Grahams iPhone 4s"
      #    @udid="ba0ac7d70f7a14c6fa02ef0e02f4fe9c5178e2f7"
      #    @platform="ios"
      #    @status="c">]
      #
      # @example Usage
      #  profile.devices.first.name
      attr_accessor :devices

      # This is the second level request, which is done before creating the object
      # this includes information about the devices and the certificates
      # more information on this issue https://github.com/fastlane/fastlane/issues/6137
      attr_accessor :profile_details

      # @return (Bool) Does the profile use a template (has extended entitlements)?
      #
      # @example
      #   false
      attr_accessor :is_template_profile

      # @return (Spaceship::Portal::ProvisioningProfileTemplate)
      #   Model representation of the provisioning profile template.
      #   This will be always nil if is_template_profile returns false
      #
      # @example Example Value
      #  <Spaceship::Portal::ProvisioningProfileTemplate
      #    @template_description="Subscription Service iOS (dist)",
      #    @entitlements=nil,
      #    @purpose_description="Generic Provisioning Profile Template for App: com.apple.smoot.subscriptionservice",
      #    @purpose_display_name="Subscription Service iOS (dist)",
      #    @purpose_name="Subscription Service iOS (dist)",
      #    @version=1>
      #
      # @example Usage
      #  profile.template.purpose_display_name
      attr_accessor :template

      attr_mapping({
        'provisioningProfileId' => :id,
        'UUID' => :uuid,
        'dateExpire' => :expires,
        'distributionMethod' => :distribution_method,
        'name' => :name,
        'status' => :status,
        'type' => :type,
        'version' => :version,
        'proProPlatform' => :platform,
        'proProSubPlatform' => :sub_platform,
        'managingApp' => :managing_app,
        'appId' => :app,
        'isTemplateProfile' => :is_template_profile,
        'template' => :template
      })

      class << self
        # @return (String) The profile type used for web requests to the Dev Portal
        # @example
        #  "limited"
        #  "store"
        #  "adhoc"
        #  "inhouse"
        def type
          raise "You cannot create a ProvisioningProfile without a type. Use a subclass."
        end

        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          # available values of `distributionMethod` at this point: ['adhoc', 'store', 'limited', 'direct', 'inhouse']
          klass = case attrs['distributionMethod']
                  when 'limited'
                    Development
                  when 'store'
                    AppStore
                  when 'adhoc'
                    AdHoc
                  when 'inhouse'
                    InHouse
                  when 'direct'
                    Direct # Mac-only
                  else
                    raise "Can't find class '#{attrs['distributionMethod']}'"
                  end

          # Parse the dates
          # rubocop:disable Style/RescueModifier
          attrs['dateExpire'] = (Time.parse(attrs['dateExpire']) rescue attrs['dateExpire'])
          # rubocop:enable Style/RescueModifier

          # When a profile is created with a template name, the response
          # (provisioning profiles info) already contains the data about
          # template, which is used to instantiate the
          # ProvisioningProfileTemplate model.
          # Doing so saves an API call needed to fetch profile details.
          #
          # Verify if `attrs` contains the info needed to instantiate a template.
          # If not, the template will be lazily loaded.
          if attrs['profile'] && attrs['profile']['description']
            attrs['template'] = ProvisioningProfileTemplate.factory(attrs['template'])
          end

          klass.client = @client
          obj = klass.new(attrs)

          return obj
        end

        # @return (String) The human readable name of this profile type.
        # @example
        #  "AppStore"
        #  "AdHoc"
        #  "Development"
        #  "InHouse"
        def pretty_type
          name.split('::').last
        end

        # Create a new provisioning profile
        # @param name (String): The name of the provisioning profile on the Dev Portal
        # @param bundle_id (String): The app identifier, this parameter is required
        # @param certificate (Certificate): The certificate that should be used with this
        #   provisioning profile. You can also pass an array of certificates to this method. This will
        #   only work for development profiles
        # @param devices (Array) (optional): An array of Device objects that should be used in this profile.
        #  It is recommend to not pass devices as spaceship will automatically add all devices for AdHoc
        #  and Development profiles and add none for AppStore and Enterprise Profiles
        # @param mac (Bool) (optional): Pass true if you're making a Mac provisioning profile
        # @param sub_platform (String) Used to create tvOS profiles at the moment. Value should equal 'tvOS' or nil.
        # @param template_name (String) (optional): The name of the provisioning profile template.
        #  The value can be found by inspecting the Entitlements drop-down when creating/editing a
        #  provisioning profile in Developer Portal.
        # @return (ProvisioningProfile): The profile that was just created
        def create!(name: nil, bundle_id: nil, certificate: nil, devices: [], mac: false, sub_platform: nil, template_name: nil)
          raise "Missing required parameter 'bundle_id'" if bundle_id.to_s.empty?
          raise "Missing required parameter 'certificate'. e.g. use `Spaceship::Portal::Certificate::Production.all.first`" if certificate.to_s.empty?

          app = Spaceship::Portal::App.find(bundle_id, mac: mac)
          raise "Could not find app with bundle id '#{bundle_id}'" unless app

          raise "Invalid sub_platform #{sub_platform}, valid values are tvOS" if !sub_platform.nil? && sub_platform != 'tvOS'

          # Fill in sensible default values
          name ||= [bundle_id, self.pretty_type].join(' ')

          if self == AppStore || self == InHouse || self == Direct
            # Distribution Profiles MUST NOT have devices
            devices = []
          end

          certificate_parameter = certificate.collect(&:id) if certificate.kind_of?(Array)
          certificate_parameter ||= [certificate.id]

          # Fix https://github.com/KrauseFx/fastlane/issues/349
          certificate_parameter = certificate_parameter.first if certificate_parameter.count == 1

          if devices.nil? || devices.count == 0
            if self == Development || self == AdHoc
              # For Development and AdHoc we usually want all compatible devices by default
              if mac
                devices = Spaceship::Portal::Device.all_macs
              elsif sub_platform == 'tvOS'
                devices = Spaceship::Portal::Device.all_apple_tvs
              else
                devices = Spaceship::Portal::Device.all_ios_profile_devices
              end
            end
          end

          profile = client.with_retry do
            client.create_provisioning_profile!(name,
                                                self.type,
                                                app.app_id,
                                                certificate_parameter,
                                                devices.map(&:id),
                                                mac: mac,
                                                sub_platform: sub_platform,
                                                template_name: template_name)
          end

          self.new(profile)
        end

        # @return (Array) Returns all profiles registered for this account
        #  If you're calling this from a subclass (like AdHoc), this will
        #  only return the profiles that are of this type
        # @param mac (Bool) (optional): Pass true to get all Mac provisioning profiles
        # @param xcode (Bool) (optional): Pass true to include Xcode managed provisioning profiles
        def all(mac: false, xcode: false)
          if ENV['SPACESHIP_AVOID_XCODE_API']
            profiles = client.provisioning_profiles(mac: mac)
          else
            profiles = client.provisioning_profiles_via_xcode_api(mac: mac)
          end

          # transform raw data to class instances
          profiles.map! { |profile| self.factory(profile) }

          # filter out the profiles managed by xcode
          unless xcode
            profiles.delete_if(&:managed_by_xcode?)
          end

          return profiles if self == ProvisioningProfile
          return profiles.select { |profile| profile.class == self }
        end

        # @return (Array) Returns all profiles registered for this account
        #  If you're calling this from a subclass (like AdHoc), this will
        #  only return the profiles that are of this type
        def all_tvos
          profiles = all(mac: false)
          tv_os_profiles = []
          profiles.each do |tv_os_profile|
            if tv_os_profile.tvos?
              tv_os_profiles << tv_os_profile
            end
          end
          return tv_os_profiles
        end

        # @return (Array) Returns an array of provisioning
        #   profiles matching the bundle identifier
        #   Returns [] if no profiles were found
        #   This may also contain invalid or expired profiles
        def find_by_bundle_id(bundle_id: nil, mac: false, sub_platform: nil)
          raise "Missing required parameter 'bundle_id'" if bundle_id.to_s.empty?
          raise "Invalid sub_platform #{sub_platform}, valid values are tvOS" if !sub_platform.nil? && sub_platform != 'tvOS'
          find_tvos_profiles = sub_platform == 'tvOS'
          all(mac: mac).find_all do |profile|
            profile.app.bundle_id == bundle_id && profile.tvos? == find_tvos_profiles
          end
        end
      end

      # Represents a Development profile from the Dev Portal
      class Development < ProvisioningProfile
        def self.type
          'limited'
        end
      end

      # Represents an AppStore profile from the Dev Portal
      class AppStore < ProvisioningProfile
        def self.type
          'store'
        end
      end

      # Represents an AdHoc profile from the Dev Portal
      class AdHoc < ProvisioningProfile
        def self.type
          'adhoc'
        end
      end

      # Represents an Enterprise InHouse profile from the Dev Portal
      class InHouse < ProvisioningProfile
        def self.type
          'inhouse'
        end
      end

      # Represents a Mac Developer ID profile from the Dev Portal
      class Direct < ProvisioningProfile
        def self.type
          'direct'
        end
      end

      # Download the current provisioning profile. This will *not* store
      # the provisioning profile on the file system. Instead this method
      # will return the content of the profile.
      # @return (String) The content of the provisioning profile
      #  You'll probably want to store it on the file system
      # @example
      #  File.write("path.mobileprovision", profile.download)
      def download
        client.download_provisioning_profile(self.id, mac: mac?)
      end

      # Delete the provisioning profile
      def delete!
        client.delete_provisioning_profile!(self.id, mac: mac?)
      end

      # Repair an existing provisioning profile
      # alias to update!
      # @return (ProvisioningProfile) A new provisioning profile, as
      #  the repair method will generate a profile with a new ID
      def repair!
        update!
      end

      # Updates the provisioning profile from the local data
      # e.g. after you added new devices to the profile
      # This will also update the code signing identity if necessary
      # @return (ProvisioningProfile) A new provisioning profile, as
      #  the repair method will generate a profile with a new ID
      def update!
        # sigh handles more specific filtering and validation steps that make this logic OK
        #
        # This is the minimum protection needed for people using spaceship directly
        unless certificate_valid?
          if mac?
            if self.kind_of?(Development)
              self.certificates = [Spaceship::Portal::Certificate::MacDevelopment.all.first]
            elsif self.kind_of?(Direct)
              self.certificates = [Spaceship::Portal::Certificate::DeveloperIdApplication.all.first]
            else
              self.certificates = [Spaceship::Portal::Certificate::MacAppDistribution.all.first]
            end
          else
            if self.kind_of?(Development)
              self.certificates = [Spaceship::Portal::Certificate::Development.all.first]
            elsif self.kind_of?(InHouse)
              self.certificates = [Spaceship::Portal::Certificate::InHouse.all.first]
            else
              self.certificates = [Spaceship::Portal::Certificate::Production.all.first]
            end
          end
        end

        client.with_retry do
          client.repair_provisioning_profile!(
            id,
            name,
            distribution_method,
            app.app_id,
            certificates.map(&:id),
            devices.map(&:id),
            mac: mac?,
            sub_platform: tvos? ? 'tvOS' : nil,
            template_name: is_template_profile ? template.purpose_name : nil
          )
        end

        # We need to fetch the provisioning profile again, as the ID changes
        profile = Spaceship::Portal::ProvisioningProfile.all(mac: mac?).find do |p|
          p.name == self.name # we can use the name as it's valid
        end

        return profile
      end

      # Is the certificate of this profile available?
      # @return (Bool) is the certificate valid?
      def certificate_valid?
        return false if (certificates || []).count == 0
        certificates.each do |c|
          if Spaceship::Portal::Certificate.all(mac: mac?).collect(&:id).include?(c.id)
            return true
          end
        end
        return false
      end

      # @return (Bool) Is the current provisioning profile valid?
      #                To also verify the certificate call certificate_valid?
      def valid?
        return status == 'Active'
      end

      # @return (Bool) Is this profile managed by Xcode?
      def managed_by_xcode?
        managing_app == 'Xcode'
      end

      # @return (Bool) Is this a Mac provisioning profile?
      def mac?
        platform == 'mac'
      end

      # @return (Bool) Is this a tvos provisioning profile?
      def tvos?
        sub_platform == 'tvOS'
      end

      def devices
        if (@devices || []).empty?
          @devices = (self.profile_details["devices"] || []).collect do |device|
            Device.set_client(client).factory(device)
          end
        end

        @devices
      end

      def certificates
        if (@certificates || []).empty?
          @certificates = (profile_details["certificates"] || []).collect do |cert|
            Certificate.set_client(client).factory(cert)
          end
        end

        @certificates
      end

      def app
        if raw_data.key?('appId')
          app_attributes = raw_data['appId']
        else
          app_attributes = profile_details['appId']
        end

        App.set_client(client).new(app_attributes)
      end

      # This is an expensive operation as it triggers a new request
      def profile_details
        # Since 15th September 2016 certificates and devices are hidden behind another request
        # see https://github.com/fastlane/fastlane/issues/6137 for more information
        @profile_details ||= client.provisioning_profile_details(provisioning_profile_id: self.id, mac: mac?)
      end

      # Lazily instantiates the provisioning profile template model
      #
      # @return (Bool) The template model if the provisioning profile has a
      #   template or nil if provisioning profile doesn't have a template
      def template
        return nil unless is_template_profile

        @template ||= ProvisioningProfileTemplate.factory(profile_details['template'])
      end

      # @return (String) The name of the template (as displayed in Dev Portal)
      #   or nil if provisioning profile doesn't have a template
      def template_name
        is_template_profile ? template.purpose_display_name : nil
      end
    end
  end
end
