# frozen_string_literal: true

require 'set'

module Aws
  module Partitions
    class Service

      # @option options [required, String] :name
      # @option options [required, String] :partition_name
      # @option options [required, Set<String>] :region_name
      # @option options [required, Boolean] :regionalized
      # @option options [String] :partition_region
      # @api private
      def initialize(options = {})
        @name = options[:name]
        @partition_name = options[:partition_name]
        @regions = options[:regions]
        @fips_regions = options[:fips_regions]
        @dualstack_regions = options[:dualstack_regions]
        @regionalized = options[:regionalized]
        @partition_region = options[:partition_region]
      end

      # @return [String] The name of this service. The name is the module
      #   name as used by the AWS SDK for Ruby.
      attr_reader :name

      # @return [String] The partition name, e.g "aws", "aws-cn", "aws-us-gov".
      attr_reader :partition_name

      # @return [Set<String>] The regions this service is available in.
      #   Regions are scoped to the partition.
      attr_reader :regions

      # @return [Set<String>] The FIPS compatible regions this service is
      #   available in. Regions are scoped to the partition.
      attr_reader :fips_regions

      # @return [Set<String>] The Dualstack compatible regions this service is
      #   available in. Regions are scoped to the partition.
      attr_reader :dualstack_regions

      # @return [String,nil] The global patition endpoint for this service.
      #   May be `nil`.
      attr_reader :partition_region

      # Returns `false` if the service operates with a single global
      # endpoint for the current partition, returns `true` if the service
      # is available in multiple regions.
      #
      # Some services have both a partition endpoint and regional endpoints.
      #
      # @return [Boolean]
      def regionalized?
        @regionalized
      end

      class << self

        # @api private
        def build(service_name, service, partition)
          Service.new(
            name: service_name,
            partition_name: partition['partition'],
            regions: regions(service, partition),
            fips_regions: variant_regions('fips', service, partition),
            dualstack_regions: variant_regions('dualstack', service, partition),
            regionalized: service['isRegionalized'] != false,
            partition_region: partition_region(service)
          )
        end

        private

        def regions(service, partition)
          svc_endpoints = service.key?('endpoints') ? service['endpoints'].keys : []
          names = Set.new(partition['regions'].keys & svc_endpoints)
          names - ["#{partition['partition']}-global"]
        end

        def variant_regions(variant_name, service, partition)
          svc_endpoints = service.fetch('endpoints', {})
          names = Set.new
          svc_endpoints.each do |key, value|
            variants = value.fetch('variants', [])
            variants.each do |variant|
              tags = variant.fetch('tags', [])
              if tags.include?(variant_name) && partition['regions'].key?(key)
                names << key
              end
            end
          end
          names - ["#{partition['partition']}-global"]
        end

        def partition_region(service)
          service['partitionEndpoint']
        end

      end
    end
  end
end
