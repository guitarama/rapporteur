# frozen_string_literal: true

module Rapporteur
  class StatusesController < ApplicationController
    def show
      expires_now
      respond_to do |format|
        format.json do
          resource = Rapporteur.run

          if resource.errors.empty?
            render(json: resource)
          else
            display_errors(resource, :json)
          end
        end
      end
    end

    private

    def display_errors(resource, format)
      render(format => { errors: resource.errors, messages: resource.as_json }, :status => :internal_server_error)
    end
  end
end
