require 'spec_helper'

describe "index" do

  let(:migration) { ::ActiveRecord::Migration }

  describe "add_index" do

    class User < ::ActiveRecord::Base ; end

    after(:each) do
      User.reset_column_information
    end

    context "extra features" do

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

    context "create table" do
      it "defines index with expression only" do
        define_schema do
          create_table :users do |t|
            t.string :login
            t.index :expression => "upper(login)", name: "no_column"
          end
        end
        expect(User.indexes.first.expression).to eq("upper((login)::text)")
        expect(User.indexes.first.name).to eq("no_column")
      end

      it "defines index with expression as column option" do
        define_schema do
          create_table :users do |t|
            t.string :login, index: { expression: "upper(login)" }
          end
        end
        expect(User.indexes.first.expression).to eq("upper((login)::text)")
        expect(User.indexes.first.name).to eq("index_users_on_login")
        expect(User.indexes.first.columns).to be_empty
      end

      it "defines multi-column index with expression as column option" do
        define_schema do
          create_table :users do |t|
            t.string :name
            t.string :login, index: { with: "name", expression: "upper(login)" }
          end
        end
        expect(User.indexes.first.expression).to eq("upper((login)::text)")
        expect(User.indexes.first.name).to eq("index_users_on_login_and_name")
        expect(User.indexes.first.columns).to eq(["name"])
      end

      it "defines multi-column index with column option expression that doesn't reference column" do
        define_schema do
          create_table :users do |t|
            t.string :name
            t.string :login, index: { expression: "upper(name)" }
          end
        end
        expect(User.indexes.first.expression).to eq("upper((name)::text)")
        expect(User.indexes.first.name).to eq("index_users_on_login")
        expect(User.indexes.first.columns).to eq(["login"])
      end
    end

    context "change table" do
      it "defines index with expression only" do
        define_schema do
          create_table :users, :force => true do |t|
            t.string :login
          end
          change_table :users do |t|
            t.index :expression => "upper(login)", name: "no_column"
          end
        end
        expect(User.indexes.first.expression).to eq("upper((login)::text)")
        expect(User.indexes.first.name).to eq("no_column")
      end
    end

    protected

    def index_for(column_names)
      User.indexes.detect { |i| i.columns == Array(column_names).collect(&:to_s) }
    end

  end

  protected
  def add_index(*args)
    migration.suppress_messages do
      migration.add_index(*args)
    end
    User.reset_column_information
  end

  def remove_index(*args)
    migration.suppress_messages do
      migration.remove_index(*args)
    end
    User.reset_column_information
  end

end
