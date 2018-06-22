# frozen_string_literal: true

require 'spec_helper.rb'

RSpec.describe 'status route', type: :routing do
  it 'routes / to rapporteur/statuses#show' do
    expect(get: '/').to route_to(action: 'show',
                                 controller: 'rapporteur/statuses')
  end
end
