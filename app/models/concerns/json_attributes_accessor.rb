module JsonAttributesAccessor
  extend ActiveSupport::Concern

  class_methods do
    def json_accessor(column_name, *attributes)
      attributes.each do |attribute|
        # GETTER
        # def from_time
        #   self.legacy_data["from_time"]
        # end
        define_method(attribute) do
          json_data = self[column_name] || {}
          json_data[attribute.to_s]
        end

        # SETTER
        # def from_time=(value)
        #   self.legacy_data = (self.legacy_data || {}).merge("from_time" => value)
        # end
        define_method("#{attribute}=") do |value|
          json_data = self[column_name] || {}

          if value.nil?
            json_data.delete(attribute.to_s)
          else
            json_data[attribute.to_s] = value
          end

          self[column_name] = json_data
        end
      end
    end
  end
end
