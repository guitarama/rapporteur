# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'A status request with a RevisionCheck', type: :request do
  before do
    allow(Rapporteur::Revision).to receive(:current).and_return('revisionidentifier')
    Rapporteur.add_check(Rapporteur::Checks::RevisionCheck)

    get(rapporteur.status_path(format: 'json'))
  end

  it_behaves_like 'a successful status response'

  context 'the response payload' do
    it 'contains the current application revision' do
      expect(response).to include_status_message('revision', 'revisionidentifier')
    end
  end
end
