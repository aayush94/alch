module ScenarioCopier
    def copy_scenario(scenario, options = {})
      scenario_copy = scenario.amoeba_dup
      scenario_copy.name = options[:copy_name] || scenario_copy.name
      scenario_copy.description = options[:description] || scenario_copy.description
      scenario_copy.locked = options[:locked] || scenario_copy.locked

      Scenario.transaction(requires_new: true) do
        begin
          scenario_copy.save!
          update_scenario_copy(scenario, scenario_copy)
          return scenario_copy
        rescue ActiveRecord::RecordInvalid => invalid
          render json: invalid.record.errors, status: :unprocessable_entity and return
        end
      end
    end

    private
    def update_scenario_copy(scenario, scenario_copy)
      update_root_node_id(scenario_copy)
      update_choice_links(scenario, scenario_copy)
    end

    def update_root_node_id(scenario_copy)
      root_node = scenario_copy.nodes.find_by_is_start(true)
      scenario_copy.update!(:root_node_id => root_node.id)
    end

    def update_choice_links(scenario, scenario_copy)
      complete_choices = scenario_copy.complete_choices

      complete_choices.each do |choice|
        old_to_node = Node.find(choice.to_node_id)

        old_to_node_index = scenario.nodes.index(old_to_node)
        new_to_node = scenario_copy.nodes[old_to_node_index]

        choice.update!(:to_node_id => new_to_node.id)
      end
    end
end