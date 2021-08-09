module Vagrant
  class MachineIndex
    # This module enables the MachineIndex for server mode
    module Remote

      attr_accessor :client

      attr_accessor :project_ref

      # Add an attribute reader for the client
      # when applied to the MachineIndex class
      def self.prepended(klass)
        klass.class_eval do
          attr_reader :client
        end
      end

      # Initializes a MachineIndex
      def initialize(*args)
        @logger = Log4r::Logger.new("vagrant::machine_index")
        @machines  = {}
      end

      # Deletes a machine by UUID.
      #
      # @param [Entry] entry The entry to delete.
      # @return [Boolean] true if delete is successful
      def delete(entry)
        machine = entry.remote_machine.client.ref
        @client.delete(machine)
      end

      # Accesses a machine by UUID
      #
      # @param [String] name for the machine to access.
      # @return [MachineIndex::Entry]
      def get(name)
        ref = Hashicorp::Vagrant::Sdk::Ref::Target.new(
          name: name,
          project: @project_ref
        )
        get_response = @client.get(ref)
        @logger.debug("got machine #{get_response} for #{name}")
        entry = machine_to_entry(get_response.target, get_response.provider)
        @logger.debug("entry: #{entry.to_json_struct}")
        entry
      end
      
      # Tests if the index has the given UUID.
      #
      # @param [String] name
      # @return [Boolean]
      def include?(name)
        ref = Hashicorp::Vagrant::Sdk::Ref::Target.new(
          name: name,
          project: @project_ref
        )
        @client.include?(ref)
      end

      def release(entry)
        #no-op
      end

      # Creates/updates an entry object and returns the resulting entry.
      #
      # @param [Entry] entry
      # @return [Entry]
      def set(entry)
        entry.remote_machine.client.save
        entry
      end

      def recover(entry)
        #no-op
      end

      protected

      # Converts a machine to a machine index entry
      #
      # @param [Hashicorp::Vagrant::Sdk::Args::Target]
      # @return [Vagrant::MachineIndex::Entry] 
      def machine_to_entry(machine, provider)
        @logger.debug("machine name: #{machine.name}")
        raw = {
          "name" => machine.name,
          "vagrantfile_path" => machine.project.path,
          "provider" => provider,
        }
        entry = Vagrant::MachineIndex::Entry.new(
          id=machine.name, raw=raw
        )
        return entry
      end
    end
  end
end