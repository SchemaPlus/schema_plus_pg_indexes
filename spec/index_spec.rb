require 'spec_helper'

describe "index" do

  let(:migration) { ::ActiveRecord::Migration }

  class User < ::ActiveRecord::Base ; end

  after(:each) do
    User.reset_column_information
  end

  before(:each) do
    define_schema do
      create_table :users do |t|
        t.string :login
        t.text :address
        t.jsonb :json_col
        t.datetime :deleted_at
      end
    end
  end

  fcontext 'rails 5.2 or newer', rails_5_2: :only do
    it "should handle old arguments" do
      add_index(:users, 'upper(login)', using: :hash, where: 'deleted_at is null', opclass: 'varchar_pattern_ops', :name => 'users_login_index')
      index = User.indexes.first
      expect(index.columns).to include("upper((login)::text)")
      expect(index.where).to eq("(deleted_at IS NULL)")
      expect(index.using).to eq(:hash)
    end
  end

  context 'before rails 5.2', rails_5_2: :skip do
    it "should assign expression, where and using" do
      add_index(:users, :expression => "USING hash (upper(login)) WHERE deleted_at IS NULL", :name => 'users_login_index')
      index = User.indexes.detect { |i| i.expression.present? }
      expect(index.expression).to eq("upper((login)::text)")
      expect(index.where).to eq("(deleted_at IS NULL)")
      expect(index.using).to       eq(:hash)
    end

    it "should allow to specify expression, where and using separately" do
      add_index(:users, :using => "hash", :expression => "upper(login)", :where => "deleted_at IS NULL", :name => 'users_login_index')
      index = User.indexes.detect { |i| i.expression.present? }
      expect(index.expression).to eq("upper((login)::text)")
      expect(index.where).to eq("(deleted_at IS NULL)")
      expect(index.using).to eq(:hash)
    end

    it "should assign operator_class" do
      add_index(:users, :login, :operator_class => 'varchar_pattern_ops')
      expect(index_for(:login).operator_classes).to eq({"login" => 'varchar_pattern_ops'})
    end

    it "should assign multiple operator_classes" do
      add_index(:users, [:login, :address], :operator_class => {:login => 'varchar_pattern_ops', :address => 'text_pattern_ops'})
      expect(index_for([:login, :address]).operator_classes).to eq({"login" => 'varchar_pattern_ops', "address" => 'text_pattern_ops'})
    end

    it "should allow to specify actual expression only" do
      add_index(:users, :expression => "upper(login)", :name => 'users_login_index')
      index = User.indexes.detect { |i| i.name == 'users_login_index' }
      expect(index.expression).to eq("upper((login)::text)")
    end

    it "should create proper sql with jsonb expressions (schema_plus #212)" do
      add_index :users, :name => "json_expression", :using => :gin, :expression => "(json_col -> 'field')"
      index = User.indexes.detect(&its.name == "json_expression")
      expect(index.expression).to eq("(json_col -> 'field'::text)")
    end

    it "should raise if no column given and expression is missing" do
      expect { add_index(:users, :name => 'users_login_index') }.to raise_error(ArgumentError, /expression/)
    end

    it "should raise if expression without name is given" do
      expect { add_index(:users, :expression => "upper(login)") }.to raise_error(ArgumentError, /name/)
    end

    it "should raise if expression is given and case_sensitive is false" do
      expect { add_index(:users, :name => 'users_login_index', :expression => "upper(login)", :case_sensitive => false) }.to raise_error(ArgumentError, /use LOWER/i)
    end
  end

  protected

  def index_for(column_names)
    User.indexes.detect { |i| i.columns == Array(column_names).collect(&:to_s) }
  end

  def add_index(*args)
    migration.add_index(*args)
    User.reset_column_information
  end

end
