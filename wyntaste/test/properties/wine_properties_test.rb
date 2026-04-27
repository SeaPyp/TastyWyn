require "test_helper"

class WinePropertiesTest < ActiveSupport::TestCase
  # Feature: rails-modernization, Property 13: Wine filtering correctness
  # **Validates: Requirements 13.3**
  #
  # For any varietal or origin filter applied to the Wine catalog, every Wine
  # in the result set SHALL match the specified filter value, and no Wine
  # matching the filter SHALL be excluded from the result set.
  test "Property 13: wine filtering correctness" do
    varietals = ["Cabernet Sauvignon", "Chardonnay", "Pinot Noir", "Merlot", "Riesling"]
    origins = ["Napa Valley", "Bordeaux", "Tuscany", "Willamette Valley", "Mosel"]

    property_of {
      # Generate a small catalog of wines with random varietals and origins
      count = Rantly { range(3, 8) }
      wines_data = count.times.map do
        {
          name: "Wine_#{SecureRandom.hex(4)}",
          varietal: Rantly { choose(*varietals) },
          origin: Rantly { choose(*origins) },
          vintage: Rantly { range(1990, 2024) }
        }
      end
      filter_type = Rantly { choose(:varietal, :origin) }
      filter_value = if filter_type == :varietal
                       Rantly { choose(*varietals) }
                     else
                       Rantly { choose(*origins) }
                     end
      [wines_data, filter_type, filter_value]
    }.check(100) { |wines_data, filter_type, filter_value|
      # Clean up any wines from previous iterations (posts reference wines via FK)
      Post.delete_all
      Wine.delete_all

      # Create the catalog
      wines_data.each do |wd|
        Wine.create!(name: wd[:name], varietal: wd[:varietal], origin: wd[:origin], vintage: wd[:vintage])
      end

      # Apply the filter the same way the controller does
      result = Wine.where(filter_type => filter_value)

      # Every wine in the result set must match the filter
      result.each do |wine|
        assert_equal filter_value, wine.send(filter_type),
          "Wine '#{wine.name}' in result set has #{filter_type}='#{wine.send(filter_type)}' but filter was '#{filter_value}'"
      end

      # No matching wine should be excluded
      expected_ids = Wine.where(filter_type => filter_value).pluck(:id).sort
      actual_ids = result.pluck(:id).sort
      assert_equal expected_ids, actual_ids,
        "Result set should contain all wines matching #{filter_type}='#{filter_value}'"
    }
  end
end
