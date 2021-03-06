module Menu
  class CustomLoader
    include Singleton

    def self.load
      instance.load_custom_items
    end

    def load_custom_items
      @sections = []
      @items    = []
      Dir.glob(File.join(File.dirname(__FILE__), "../../../product/menubar/*.yml")).each do |f|
        load_custom_item(f)
      end
      [@sections, @items]
    end

    private

    def load_custom_item(file_name)
      properties = YAML.load(File.open(file_name))

      if properties['type'] == 'section'
        @sections << create_custom_menu_section(properties)
      else
        @items << create_custom_menu_item(properties)
      end
    end

    class CustomItem < Item
      attr_accessor :parent
      # FIXME: :order?
    end

    def create_custom_menu_item(properties)
      rbac = properties['rbac'].each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      item = CustomItem.new(properties['id'], properties['name'], properties['feature'], rbac, properties['url'])
      item.parent = properties['parent'].to_sym
      item
    end

    def create_custom_menu_section(properties)
      if properties.key?('section_type')
        Section.new(properties['id'].to_sym, properties['name'], [], properties['section_type'].to_sym)
      else
        Section.new(properties['id'].to_sym, properties['name'])
      end
    end
  end
end
