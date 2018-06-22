# frozen_string_literal: true

module Rapporteur
  # The center of the Rapporteur library, Checker manages holding and running
  # the custom checks, holding any application error messages, and provides the
  # controller with that data for rendering.
  #
  class Checker
    extend CheckerDeprecations

    def initialize
      @check_list = CheckList.new
      reset
    end

    # Public: Add a pre-built or custom check to your status endpoint. These
    # checks are used to test the state of the world of the application, and
    # need only respond to `#call`.
    #
    # Once added, the given check will be called and passed an instance of this
    # checker. If everything is good, do nothing! If there is a problem, use
    # `add_error` to add an error message to the checker.
    #
    # Examples
    #
    #   Rapporteur.add_check { |checker|
    #     checker.add_error(:luck, :bad) if rand(2) == 1
    #   }
    #
    # Returns self.
    # Raises ArgumentError if the given check does not respond to call.
    #
    def add_check(object_or_nil_with_block = nil, &block)
      if block_given?
        check_list.add(block)
      elsif object_or_nil_with_block.respond_to?(:call)
        check_list.add(object_or_nil_with_block)
      else
        raise ArgumentError, 'A check must respond to #call.'
      end
      self
    end

    # Public: Empties all configured checks from the checker. This may be
    # useful for testing and for cases where you might've built up some basic
    # checks but for one reason or another (environment constraint) need to
    # start from scratch.
    #
    # Returns self.
    #
    def clear
      check_list.clear
      self
    end

    ##
    # Public: Checks can call this method to halt any further processing. This
    # is useful for critical or fatal check failures.
    #
    # For example, if load is too high on a machine you may not want to run any
    # other checks.
    #
    # Returns true.
    #
    def halt!
      @halted = true
    end

    # Public: This is the primary execution point for this class. Use run to
    # exercise the configured checker and collect any application errors or
    # data for rendering.
    #
    # Returns self.
    #
    def run
      reset
      check_list.each do |object|
        object.call(self)
        break if @halted
      end
      self
    end

    # Public: Add an error message to the checker in order to have it rendered
    # in the status request.
    #
    # It is suggested that you use I18n and locale files for these messages, as
    # is done with the pre-built checks. If you're using I18n, you'll need to
    # define `rapporteur.errors.<your key>.<your message>`.
    #
    # name - A Symbol which indicates the attribute, name, or other identifier
    #        for the check being run.
    # message - A String/Symbol/Proc to identify the message to provide in a
    #           check failure situation.
    #
    #           A String is presented as given.
    #           A Symbol will attempt to translate through I18n or default to the String-form of the symbol.
    #           A Proc which will be called and the return value will be presented as returned.
    # i18n_options - A Hash of options (likely variable key/value pairs) to
    #                pass to I18n during translation.
    #
    # Examples
    #
    #   checker.add_error(:you, "failed.")
    #   checker.add_error(:using, :i18n_key_is_better)
    #   checker.add_error(:using, :i18n_with_variable, :custom_variable => 'pizza')
    #
    #   en:
    #     rapporteur:
    #       errors:
    #         using:
    #           i18n_key_is_better: 'Look, localization!'
    #           i18n_with_variable: 'Look, %{custom_variable}!'
    #
    # Returns self.
    #
    def add_error(name, message, i18n_options = {})
      errors.add(name, message, i18n_options)
      self
    end

    ##
    # Public: Adds a status message for inclusion in the success response.
    #
    # name - A String containing the name or identifier for your message. This
    #        is unique and may be overriden by other checks using the name
    #        message name key.
    #
    # message - A String/Symbol/Proc containing the message to present to the
    #           user in a successful check sitaution.
    #
    #           A String is presented as given.
    #           A Symbol will attempt to translate through I18n or default to the String-form of the symbol.
    #           A Proc which will be called and the return value will be presented as returned.
    #
    # Examples
    #
    #   checker.add_message(:repository, 'git@github.com/user/repo.git')
    #   checker.add_message(:load, 0.934)
    #   checker.add_message(:load, :too_high, :measurement => '0.934')
    #
    # Returns self.
    #
    def add_message(name, message, i18n_options = {})
      messages.add(name, message, i18n_options)
      self
    end

    ##
    # Internal: Returns a hash of messages suitable for conversion into JSON.
    #
    def as_json(_args = {})
      messages.to_hash
    end

    ##
    # Internal: Used by Rails' JSON serialization to render error messages.
    #
    def errors
      Thread.current[:rapporteur_errors] ||= MessageList.new(:errors)
    end

    ##
    # Internal: Used by Rails' JSON serialization.
    #
    def read_attribute_for_serialization(key)
      messages[key]
    end

    alias read_attribute_for_validation read_attribute_for_serialization

    private

    attr_reader :check_list

    def messages
      Thread.current[:rapporteur_messages] ||= MessageList.new(:messages)
    end

    def reset
      @halted = false
      messages.clear
      errors.clear
    end
  end
end
