require 'spec_helper'


describe "Index definition" do

  let(:migration) { ::ActiveRecord::Migration }

  before(:all) do
    define_schema do
      create_table :users, :force => true do |t|
        t.string :login
        t.datetime :deleted_at
      end

      create_table :posts, :force => true do |t|
        t.text :body
        t.integer :user_id
        t.integer :author_id
      end

    end
    class User < ::ActiveRecord::Base ; end
    class Post < ::ActiveRecord::Base ; end
  end

  around(:each) do |example|
    migration.suppress_messages do
      example.run
    end
  end

  after(:each) do
    migration.remove_index :users, :name => 'users_login_index' if migration.index_name_exists? :users, 'users_login_index', true
  end

  context "when case insensitive is added" do

    before(:each) do
      migration.execute "CREATE INDEX users_login_index ON users(LOWER(login))"
      User.reset_column_information
      @index = User.indexes.detect { |i| i.expression =~ /lower\(\(login\)::text\)/i }
    end

    it "is included in User.indexes" do
      expect(@index).not_to be_nil
    end

    it "is not case_sensitive" do
      expect(@index).not_to be_case_sensitive
    end

    it "defines expression" do
      expect(@index.expression).to eq("lower((login)::text)")
    end

    it "doesn't define where" do
      expect(@index.where).to be_nil
    end

  end


  context "when index contains expression" do
    before(:each) do
      migration.execute "CREATE INDEX users_login_index ON users (extract(EPOCH from deleted_at)) WHERE deleted_at IS NULL"
      User.reset_column_information
      @index = User.indexes.detect { |i| i.expression.present? }
    end

    it "exists" do
      expect(@index).not_to be_nil
    end

    it "doesnt have columns defined" do
      expect(@index.columns).to be_empty
    end

    it "is case_sensitive" do
      expect(@index).to be_case_sensitive
    end

    it "defines expression" do
      expect(@index.expression).to eq("date_part('epoch'::text, deleted_at)")
    end

    it "defines where" do
      expect(@index.where).to eq("(deleted_at IS NULL)")
    end

  end

  context "when index has a non-btree type" do
    before(:each) do
      migration.execute "CREATE INDEX users_login_index ON users USING hash(login)"
      User.reset_column_information
      @index = User.indexes.detect { |i| i.name == "users_login_index" }
    end

    it "exists" do
      expect(@index).not_to be_nil
    end

    it "defines using" do
      expect(@index.using).to eq(:hash)
    end

    it "does not define expression" do
      expect(@index.expression).to be_nil
    end

    it "does not define order" do
      expect(@index.orders).to be_blank
    end
  end

  context "equality" do

    it "returns true when case sensitivity are the same" do
      expect(ActiveRecord::ConnectionAdapters::IndexDefinition.new("table", "column", case_sensitive: true)).to eq ActiveRecord::ConnectionAdapters::IndexDefinition.new("table", "column", case_sensitive: true)
    end

    it "returns false when case sensitivity are the different" do
      expect(ActiveRecord::ConnectionAdapters::IndexDefinition.new("table", "column", case_sensitive: true)).not_to eq ActiveRecord::ConnectionAdapters::IndexDefinition.new("table", "column", case_sensitive: false)
    end

  end


  protected
  def index_definition(column_names)
    User.indexes.detect { |index| index.columns == Array(column_names) }
  end


end
