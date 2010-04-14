module Restfulie::Common::Converter
  # Implements the interface for unmarshal Atom media type responses (application/atom+xml) to ruby objects instantiated by rAtom library.
  #
  # Furthermore, this class extends rAtom behavior to enable client users to easily access link relationships.
  module Atom

    mattr_reader :media_type_name
    @@media_type_name = 'application/atom+xml'

    mattr_reader :headers
    @@headers = { 
      :get  => { 'Accept'       => media_type_name },
      :post => { 'Content-Type' => media_type_name }
    }

    REQUIRED_ATTRIBUTES = {
      :feed  => [:title, :id, :updated],
      :entry => [:title, :id, :updated] 
    }

    mattr_reader :recipes
    @@recipes = {
      :default_feed => lambda do |obj,feed|
        if obj.is_a?(::String)
          feed = ::Atom::Feed.load_feed(obj)
        else
          REQUIRED_ATTRIBUTES[:feed].each do |attr_sym|
            feed.send("#{attr_sym}=".to_sym,obj.send(attr_sym)) if obj.respond_to?(attr_sym)
          end
        end
        feed
      end,
      :default_entry => lambda do |obj,entry|
        if obj.is_a?(::String)
          entry = ::Atom::Entry.load_entry(obj)
        else
          REQUIRED_ATTRIBUTES[:entry].each do |attr_sym|
            entry.send("#{attr_sym}=".to_sym,obj.send(attr_sym)) if obj.respond_to?(attr_sym)
          end
        end
        entry
      end
    }

    def self.describe_recipe(recipe_name, options={}, &block)
      raise 'Undefined recipe' unless block_given?
      raise 'Undefined recipe_name'   unless recipe_name
      @@recipes[recipe_name] = block
    end

    def self.link(options)
      ::Atom::Link.new(options)
    end

    def to_atom(recipe_name=nil,atom_type=:feed)
      raise "Undefined atom type #{atom_type}" unless [:entry,:feed].include?(atom_type)
      recipe = @@recipes[recipe_name] || @@recipes["default_#{atom_type}".to_sym]
      atom = recipe.call(self,"::Atom::#{atom_type.to_s.camelize}".constantize.new)
      REQUIRED_ATTRIBUTES[atom_type].each do |attr_sym|
        raise "Undefined required value #{attr_sym} from #{atom}" unless atom.send(attr_sym)
      end
      atom
    end

  end

end