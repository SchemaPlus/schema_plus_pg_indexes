
require 'spec_helper'

describe "schema" do

  class User < ::ActiveRecord::Base ; end


  before(:each) do
    User.reset_column_information
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
end
