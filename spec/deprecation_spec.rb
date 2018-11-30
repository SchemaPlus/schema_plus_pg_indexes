require 'spec_helper'

describe 'Deprecations' do

  before(:all) do
      class User < ::ActiveRecord::Base ; end
  end

  let(:migration) { ::ActiveRecord::Migration }

  context "on table creation" do
    it "deprecates :conditions" do
      where = "((login)::text ~~ '%xyz'::text)"
      expect(ActiveSupport::Deprecation).to receive(:warn).with(/conditions.*where/)
      create_table User, :login => { index: { conditions: where } }
      index = User.indexes.first
      expect(index.where).to eq where
    end

    it "deprecates :kind" do
      using = :hash
      expect(ActiveSupport::Deprecation).to receive(:warn).with(/kind.*using/)
      create_table User, :login => { index: { kind: using } }
      index = User.indexes.first
      expect(index.using).to eq using
    end

    it "deprecates :expression", rails_5_2: :only do
      field = 'date(login_at)'
      expect(ActiveSupport::Deprecation).to receive(:warn).with(/expression.*simply/)
      # type is here only for the tests, not a real option
      create_table User, :login_at => { type: :datetime, index: { expression: field } }
      index = User.indexes.first
      expect(index.columns).to include field
    end
  end

  context "on IndexDefinition object" do

    it "deprecates #conditions" do
      where = "((login)::text ~~ '%xyz'::text)"
      create_table User, :login => { index: { where: where } }
      index = User.indexes.first
      expect(ActiveSupport::Deprecation).to receive(:warn).with(/conditions.*where/)
      expect(index.where).to eq where # sanity check
      expect(index.conditions).to eq index.where
    end

    it "deprecates #kind" do
      using = :hash
      create_table User, :login => { index: { using: using } }
      index = User.indexes.first
      expect(ActiveSupport::Deprecation).to receive(:warn).with(/kind.*using/)
      expect(index.using).to eq using # sanity check
      expect(index.kind).to eq using.to_s
    end

    it "deprecates #expression", rails_5_2: :only do
      field = 'date(login_at)'
      # type is here only for the tests, not a real option
      create_table User, :login_at => { type: :datetime }
      migration.add_index User.table_name, field, name: 'index_login_date'
      index = User.indexes.first
      expect(ActiveSupport::Deprecation).to receive(:warn).with(/expression.*simply/)
      expect(index.columns).to include field # sanity check
      expect(index.expression).to be_nil
    end
  end

  protected

  def create_table(model, columns_with_options)
    migration.suppress_messages do
      migration.create_table model.table_name, :force => true do |t|
        columns_with_options.each_pair do |column, options|
          type = options.delete(:type) || :string
          t.send type, column, options
        end
      end
      model.reset_column_information
    end
  end
end
