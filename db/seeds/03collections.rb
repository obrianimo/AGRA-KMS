#
# Create Collections
#

# Create a public  collection
# @param [User] user creating the collection
# @param [String] collection type gid
# @param [String] id to use for the new collection
# @param [Hash] options holding metadata and permissions for the new collection
def create_collection(user, type_gid, id, options)
  # find existing collection if it already exists
  col = Collection.where(id: id)
  return col.first if col.present?

  # remove stale permisisons for the collection id
  remove_access(collection_id: id)

  # create collection
  col = Collection.new(id: id)
  col.attributes = options.except(:permissions)
  col.apply_depositor_metadata(user.user_key)
  col.collection_type_gid = type_gid
  col.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  col.save

  # apply new permissions
  add_access(collection: col, grants: options[:permissions])
  col
end

# Add access grants to a collection
# @param collection [Collection] the collection to modify
# @param grants [Array<Hash>] array of grants to add to the collection
# @example grants
#   [ { agent_type: Hyrax::PermissionTemplateAccess::GROUP,
#       agent_id: 'my_group_name',
#       access: Hyrax::PermissionTemplateAccess::DEPOSIT } ]
# @see Hyrax::PermissionTemplateAccess for valid values for agent_type and access
def add_access(collection:, grants:)
  template = Hyrax::PermissionTemplate.find_or_create_by(source_id: collection.id)
  grants.each do |grant|
    Hyrax::PermissionTemplateAccess.find_or_create_by(permission_template_id: template.id,
                                                      agent_type: grant[:agent_type],
                                                      agent_id: grant[:agent_id],
                                                      access: grant[:access])
  end
  collection.reset_access_controls! # updates solr
end

# Remove all access grants for a specific collection id
# @param collection_id [String] the id of stale collection
def remove_access(collection_id:)
  templates = Hyrax::PermissionTemplate.where(source_id: collection_id)
  return unless templates.present?
  templates.each { |template| template.destroy! }
end

case Rails.env
when 'development', 'integration', 'staging', 'production'

  organization_gid = CollectionTypeService.organization_gid
  test_gid = CollectionTypeService.test_gid

  unless organization_gid.present?
    puts 'Failed to get Agra collection type.  Unable to create collections.'
    return
  end

  user = User.find_by(email: ENV['ADMIN_EMAIL'])
  unless user.present?
    puts 'Failed to get admin user.  Unable to create collections.'
    return
  end

  base_grants = [ { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE } ]

  puts 'Adding Collections...'

  unless Collection.exists?(title: 'Training')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    training = create_collection(user, test_gid, 'training',
                            title: ['Training'],
                            description: ['Training Collection'],
                            permissions: permissions)

    puts 'Created Training Collection'
  end

  unless Collection.exists?(title: 'Agra KMS')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'agra_kms',
                            title: ['Agra KMS'],
                            description: ['Agra KMS Collection'],
                            permissions: permissions)
    puts 'Created Agra KMS Collection'
  end

  unless Collection.exists?(title: 'Finance')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'finance',
                            title: ['Finance'],
                            description: ['Finance Collection'],
                            permissions: permissions)
    puts 'Created Finance Collection'
  end

  unless Collection.exists?(title: 'Partnerships')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'partnerships',
                            title: ['Partnerships'],
                            description: ['Partnerships Collection'],
                            permissions: permissions)
    puts 'Created Partnerships Collection'
  end

  unless Collection.exists?(title: 'Grants')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'grants',
                            title: ['Grants'],
                            description: ['Grants Collection'],
                            permissions: permissions)
    puts 'Created Grants Collection'
  end

  unless Collection.exists?(title: 'Human Resources')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'human_resources',
                            title: ['Human Resources'],
                            description: ['Human Resources Collection'],
                            permissions: permissions)
    puts 'Created Human Resources Collection'
  end

  unless Collection.exists?(title: 'Procurement')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'procurement',
                            title: ['Procurement'],
                            description: ['Procurement Collection'],
                            permissions: permissions)
    puts 'Created Procurement Collection'
  end

  unless Collection.exists?(title: 'Legal')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'legal',
                            title: ['Legal'],
                            description: ['Legal Collection'],
                            permissions: permissions)
    puts 'Created Legal Collection'
  end


  unless Collection.exists?(title: 'ICT')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'ict',
                            title: ['ICT'],
                            description: ['ICT Collection'],
                            permissions: permissions)
    puts 'Created ICT Collection'
  end

  unless Collection.exists?(title: 'Internal Audit')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'internal_audit',
                            title: ['Internal Audit'],
                            description: ['Internal Audit Collection'],
                            permissions: permissions)
    puts 'Created Internal Audit Collection'
  end


  unless Collection.exists?(title: 'AGRF')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'agrf',
                            title: ['AGRF'],
                            description: ['AGRF Collection'],
                            permissions: permissions)
    puts 'Created AGRF Collection'
  end


  unless Collection.exists?(title: 'Stragegy and Analytics')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'strategy_analytics',
                            title: ['Stragegy and Analytics'],
                            description: ['Stragegy and Analytics Collection'],
                            permissions: permissions)
    puts 'Created Stragegy and Analytics Collection'
  end

  unless Collection.exists?(title: 'Resources Mobilization')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'resources_mobilization',
                            title: ['Resources Mobilization'],
                            description: ['Resources Mobilization Collection'],
                            permissions: permissions)
    puts 'Created Resources Mobilization Collection'
  end

  unless Collection.exists?(title: 'Seeds')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'seeds',
                            title: ['Seeds'],
                            description: ['Seeds Collection'],
                            permissions: permissions)
    puts 'Created Seeds Collection'
  end

  unless Collection.exists?(title: 'GST 1')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'gst_1',
                            title: ['GST 1'],
                            description: ['GST 1 Collection'],
                            permissions: permissions)
    puts 'Created GST 1 Collection'
  end


  unless Collection.exists?(title: 'GST 2')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'gst_2',
                            title: ['GST 2'],
                            description: ['GST 2 Collection'],
                            permissions: permissions)
    puts 'Created GST 2 Collection'
  end


  unless Collection.exists?(title: 'GST 3')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'gst_3',
                            title: ['GST 3'],
                            description: ['GST 3 Collection'],
                            permissions: permissions)
    puts 'Created GST 3 Collection'
  end


  unless Collection.exists?(title: 'GST 4')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'gst_4',
                            title: ['GST 4'],
                            description: ['GST 4 Collection'],
                            permissions: permissions)
    puts 'Created GST 4 Collection'
  end


  unless Collection.exists?(title: 'GST 5')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'gst_5',
                            title: ['GST 5'],
                            description: ['GST 5 Collection'],
                            permissions: permissions)
    puts 'Created GST 5 Collection'
  end


  unless Collection.exists?(title: 'Capacity Building')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'capacity_building',
                            title: ['Capacity Building'],
                            description: ['Capacity Building Collection'],
                            permissions: permissions)
    puts 'Created Capacity Building Collection'
  end

  unless Collection.exists?(title: 'Markets')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'markets',
                            title: ['Markets'],
                            description: ['Markets Collection'],
                            permissions: permissions)
    puts 'Created Markets Collection'
  end

  unless Collection.exists?(title: 'Agrodealer')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'agrodealer',
                            title: ['Agrodealer'],
                            description: ['Agrodealer Collection'],
                            permissions: permissions)
    puts 'Created Agrodealer Collection'
  end

  unless Collection.exists?(title: 'Inclusive Finance')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'inclusive_finance',
                            title: ['Inclusive Finance'],
                            description: ['Inclusive Finance Collection'],
                            permissions: permissions)
    puts 'Created Inclusive Finance Collection'
  end

  unless Collection.exists?(title: 'Scaling Seeds and other Technologies Partnership (SSTP)')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'scaling_seeds',
                            title: ['Scaling Seeds and other Technologies Partnership (SSTP)'],
                            description: ['Scaling Seeds and other Technologies Partnership (SSTP) Collection'],
                            permissions: permissions)
    puts 'Created Scaling Seeds and other Technologies Partnership (SSTP) Collection'
  end

  unless Collection.exists?(title: 'PDI')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'pdi',
                            title: ['PDI'],
                            description: ['PDI Collection'],
                            permissions: permissions)
    puts 'Created PDI Collection'
  end

  # parent is PDI
  unless Collection.exists?(title: 'PDI/Seed System')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'pdi_seed_system',
                            title: ['PDI/Seed System'],
                            description: ['PDI/Seed System Collection'],
                            permissions: permissions)
    puts 'Created PDI/Seed System Collection'
  end

  # parent is PDI
  unless Collection.exists?(title: 'PDI/Fertilizer System')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'pdi_fertilizer_system',
                            title: ['PDI/Fertilizer System'],
                            description: ['PDI/Fertilizer System Collection'],
                            permissions: permissions)
    puts 'Created PDI/Fertilizer System Collection'
  end

  # parent is PDI
  unless Collection.exists?(title: 'PDI/Input Distribution')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'pdi_input_distribution',
                            title: ['PDI/Input Distribution'],
                            description: ['PDI/Input Distribution Collection'],
                            permissions: permissions)
    puts 'Created PDI/Input Distribution Collection'
  end

  # parent is PDI
  unless Collection.exists?(title: 'PDI/Extension')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'pdi_extension',
                            title: ['PDI/Extension'],
                            description: ['PDI/Extension Collection'],
                            permissions: permissions)
    puts 'Created PDI/Extension Collection'
  end

  # parent is PDI
  unless Collection.exists?(title: 'PDI/Markets')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'pdi_markets',
                            title: ['PDI/Markets'],
                            description: ['PDI/Markets Collection'],
                            permissions: permissions)
    puts 'Created PDI/Markets Collection'
  end

  # parent is PDI
  unless Collection.exists?(title: 'PDI/Resilience')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'pdi_resilience',
                            title: ['PDI/Resilience'],
                            description: ['PDI/Resilience Collection'],
                            permissions: permissions)
    puts 'Created PDI/Resilience Collection'
  end

  # parent is PDI
  unless Collection.exists?(title: 'PDI/ICT4AG')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'pdi_ict4ag',
                            title: ['PDI/ICT4AG'],
                            description: ['PDI/Markets Collection'],
                            permissions: permissions)
    puts 'Created PDI/Markets Collection'
  end

  unless Collection.exists?(title: 'PASS - Program for Africa Seed Systems')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'pass',
                            title: ['PASS - Program for African Seed Systems'],
                            description: ['PASS - Program for African Seed Systems Collection'],
                            permissions: permissions)
    puts 'Created PASS - Program for African Seed Systems Collection'
  end

  unless Collection.exists?(title: 'Extension')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'extension',
                            title: ['Extension'],
                            description: ['Extension Collection'],
                            permissions: permissions)
    puts 'Created Extension Collection'
  end

  unless Collection.exists?(title: 'Policiy and Advocacy')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'policy_advocacy',
                            title: ['Policiy and Advocacy'],
                            description: ['Policiy and Advocacy Collection'],
                            permissions: permissions)
    puts 'Created Policiy and Advocacy Collection'
  end

  unless Collection.exists?(title: 'SAIOMA')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'saioma',
                            title: ['SAIOMA'],
                            description: ['SAIOMA Collection'],
                            permissions: permissions)
    puts 'Created SAIOMA Collection'
  end

  unless Collection.exists?(title: 'Communications')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'communications',
                            title: ['Communications'],
                            description: ['Communications Collection'],
                            permissions: permissions)
    puts 'Created Communications Collection'
  end

  unless Collection.exists?(title: 'Monitoring & Evaluation (M&E)')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'monitorig_evaluation',
                            title: ['Monitoring & Evaluation (M&E)'],
                            description: ['Monitoring & Evaluation (M&E) Collection'],
                            permissions: permissions)
    puts 'Created Monitoring & Evaluation (M&E) Collection'
  end

  unless Collection.exists?(title: 'Soil Health')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'admin', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    agrakms = create_collection(user, organization_gid, 'soil_health',
                            title: ['Soil Health'],
                            description: ['Soil Health Collection'],
                            permissions: permissions)
    puts 'Created Soil Health Collection'
  end

  puts 'Done.'
end
