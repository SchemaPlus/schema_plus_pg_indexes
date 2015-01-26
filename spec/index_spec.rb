require 'spec_helper'

describe "index" do

  let(:migration) { ::ActiveRecord::Migration }
  let(:connection) { ::ActiveRecord::Base.connection }

  describe "add_index" do

    before(:each) do
      connection.tables.each do |table| connection.drop_table table, cascade: true end

      define_schema(:auto_create => false) do
        create_table :users, :force => true do |t|
          t.string :login
          t.text :address
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


    after(:each) do
      migration.suppress_messages do
        migration.remove_index(:users, :name => @index.name) if (@index ||= nil)
      end
    end

    context "extra features", :postgresql => :only do

      it "should assign conditions" do
        add_index(:users, :login, :where => 'deleted_at IS NULL')
        expect(index_for(:login).where).to eq('(deleted_at IS NULL)')
      end

      it "should assign expression, conditions and using" do
        add_index(:users, :expression => "USING hash (upper(login)) WHERE deleted_at IS NULL", :name => 'users_login_index')
        @index = User.indexes.detect { |i| i.expression.present? }
        expect(@index.expression).to eq("upper((login)::text)")
        expect(@index.where).to eq("(deleted_at IS NULL)")
        expect(@index.using).to       eq(:hash)
      end

      it "should allow to specify expression, conditions and using separately" do
        add_index(:users, :using => "hash", :expression => "upper(login)", :where => "deleted_at IS NULL", :name => 'users_login_index')
        @index = User.indexes.detect { |i| i.expression.present? }
        expect(@index.expression).to eq("upper((login)::text)")
        expect(@index.where).to eq("(deleted_at IS NULL)")
        expect(@index.using).to eq(:hash)
      end

      it "should allow to specify using" do
        add_index(:users, :login, :using => "hash")
        expect(index_for(:login).using).to eq(:hash)
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
        @index = User.indexes.detect { |i| i.name == 'users_login_index' }
        expect(@index.expression).to eq("upper((login)::text)")
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
      @index = User.indexes.detect { |i| i.columns == Array(column_names).collect(&:to_s) }
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
