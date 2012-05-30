class Article < Couchbase::Model

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming

  view :by_type, :by_category, :by_author, :view_stats, :view_stats_by_type, :by_popularity_and_type, :by_popularity

  def persisted?
    @id
  end

  attr_accessor :id, :title, :type, :url, :author, :contributors, :content, :categories, :attrs, :views, :quality
  @@keys = [:id, :title, :type, :url, :author, :contributors, :content, :categories, :attrs, :views, :quality]

  def self.totals
    total = { :overall => 0, :audio => 0, :video => 0, :text => 0 }
    Couch.client.design_docs["article"].by_type(:group => true, :group_level => 1).entries.each do |row|
      total[row.key[0].to_sym] = row.value
      total[:overall]   += row.value
    end
    total
  end

  def self.view_stats_type
    results = Couch.client.design_docs["article"].view_stats_by_type(:group => true, :reduce => true).entries
    result_hash = {}
    results.each do |r|
      next if r.key == nil
      result_hash[r.key] = r.value
    end
    result_hash.symbolize_keys
  end

  def self.view_stats
    Couch.client.design_docs["article"].view_stats(:reduce => true).entries.first.value.symbolize_keys
  end

  def self.author(a)
    # Couch.client.design_docs["article"].by_type(:reduce => false).entries.collect { |row| Article.find(row.key[1]) }
    options = { :reduce => false }
    options.merge!({ :startkey => [a, ""], :endkey => [a, "\u9999"] })
    by_author(options).entries
  end

  def self.category(c)
    # Couch.client.design_docs["article"].by_type(:reduce => false).entries.collect { |row| Article.find(row.key[1]) }
    options = { :reduce => false }
    options.merge!({ :startkey => [c, ""], :endkey => [c, "\u9999"] })
    by_category(options).entries
  end

  def self.popular_by_type(opts={})
    # Couch.client.design_docs["article"].by_type(:reduce => false).entries.collect { |row| Article.find(row.key[1]) }
    type = opts.delete(:type)
    options = { :reduce => false, :descending => true, :include_docs => true }.merge(opts)
    if type
      options.merge!({ :startkey => [type, Article.view_stats[:max]], :endkey => [type, 0] })
    end
    by_popularity_and_type(options).entries
  end

  def self.popular(opts={})
    options = { :descending => true, :reduce => false, :include_docs => true, :limit => 10 }.merge(opts)
    by_popularity(options).entries
  end

  def update_attributes(attributes)
    attributes.each do |name, value|
      next if (name == "new_category" || name == "delete_category") && !value.present?
      # next unless @@keys.include?(name.to_sym)
      send("#{name}=", value)
    end
    update
  end

  def [](key)
    attrs[key]
  end

  def new_category; nil; end
  def delete_category; nil; end

  def delete_category=(category)
    self.categories.delete(category) if self.categories.include?(category)
  end

  def new_category=(category)
    self.categories << category
  end

  def self.find(id)
    id = id.to_s if id.respond_to?(:to_s)
    new( Couch.client.get(id).merge("id" => id) )
  end

  def initialize(attributes={})
    @errors = ActiveModel::Errors.new(self)

    attributes.each do |name, value|
      next unless @@keys.include?(name.to_sym)
      send("#{name}=", value)
    end

    self.attrs = attributes.with_indifferent_access || {}
    self.views = self.attrs[:views] || 0
    self.quality = self.attrs[:quality] || 0
    self.categories = self.attrs[:categories] || []
  end

  def update
    @attrs.merge!(:categories => @categories, :title => @title, :content => @content, :views => @views, :quality => @quality)
    Couch.client.set(@id, @attrs)
  end

  def destroy
    Couch.client.delete(@id)
  end

  def count_as_viewed
    Couch.client.incr("view_count_#{id}", 1, :initial => 1)
  end

end