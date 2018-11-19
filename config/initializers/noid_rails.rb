Hyrax.config do |config|
  # puts 'got hyrax config and setting noid in_use lambda'
  ::Noid::Rails.config.identifier_in_use = lambda do |id|
    ActiveFedora::Base.exists?(id) || ActiveFedora::Base.gone?(id)
  end
end
