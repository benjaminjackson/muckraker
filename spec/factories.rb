FactoryGirl.define do
    factory :candidate, :class => CampaignCash::Candidate do
        sequence(:id)
        sequence(:name) { |n| 'Candidate #{n}' }
        sequence(:party) { |n| n % 2 ? 'REP' : 'DEM' }
    end
end
