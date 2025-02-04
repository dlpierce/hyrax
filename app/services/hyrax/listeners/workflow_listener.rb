# frozen_string_literal: true

module Hyrax
  module Listeners
    ##
    # Listens for object lifecycle events that require workflow changes and
    # manages workflow accordingly.
    class WorkflowListener
      ##
      # @!attribute [rw] factory
      #   @return [#create]
      attr_accessor :factory

      ##
      # @param [#create] factory
      def initialize(factory: Hyrax::Workflow::WorkflowFactory)
        @factory = factory
      end

      ##
      # Called when 'object.deposited' event is published
      # @param [Dry::Events::Event] event
      # @return [void]
      def on_object_deposited(event)
        return Hyrax.logger.warn("Skipping workflow initialization for #{event[:object]}; no user is given\n\t#{event}") if
          event[:user].blank?

        factory.create(event[:object], {}, event[:user])
      rescue Sipity::StateError, Sipity::ConversionError => err
        # don't error on known sipity error types; log instead
        Hyrax.logger.error(err)
      end
    end
  end
end
