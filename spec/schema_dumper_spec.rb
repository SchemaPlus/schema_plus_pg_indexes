require 'spec_helper'
require 'stringio'

describe "Schema dump" do

  before(:each) do
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Schema.define do
        connection.tables.each do |table| drop_table table, force: :cascade end

        create_table :users do |t|
          t.string :login
          t.datetime :deleted_at
          t.integer :first_post_id
        end

        create_table :posts do |t|
          t.text :body
          t.integer :user_id
          t.integer :first_comment_id
          t.string :string_no_default
          t.integer :short_id
          t.string :str_short
          t.integer :integer_col
          t.float :float_col
          t.decimal :decimal_col
          t.datetime :datetime_col
          t.timestamp :timestamp_col
          t.time :time_col
          t.date :date_col
          t.binary :binary_col
          t.boolean :boolean_col
        end

        create_table :comments do |t|
          t.text :body
          t.integer :post_id
          t.integer :commenter_id
        end
      end
    end
    class ::User < ActiveRecord::Base ; end
    class ::Post < ActiveRecord::Base ; end
    class ::Comment < ActiveRecord::Base ; end
  end

  context "index extras" do

    it "should define case insensitive index" do
      with_index Post, [:body, :string_no_default], :case_sensitive => false do
        expect(dump_posts).to match(/"body".*index: {.*with:.*string_no_default.*case_sensitive: false/)
      end
    end

    it "should define index with type cast" do
      with_index Post, [:integer_col], :name => "index_with_type_cast", :expression => "LOWER(integer_col::text)" do
        expect(dump_posts).to include(%q{t.index name: "index_with_type_cast", expression: "lower((integer_col)::text)"})
      end
    end


    it "should define case insensitive index with mixed ids and strings" do
      with_index Post, [:user_id, :str_short, :short_id, :body], :case_sensitive => false do
        expect(dump_posts).to match(/user_id.*index: {.* with: \["str_short", "short_id", "body"\], case_sensitive: false}/)
      end
    end

    [:integer, :float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean].each do |col_type|
      col_name = "#{col_type}_col"
      it "should define case insensitive index that includes an #{col_type}" do
        with_index Post, [:user_id, :str_short, col_name, :body], :case_sensitive => false do
          expect(dump_posts).to match(/user_id.*index: {.* with: \["str_short", "#{col_name}", "body"\], case_sensitive: false}/)
        end
      end
    end

    it "should define where" do
      with_index Post, :user_id, :name => "posts_user_id_index", :where => "user_id IS NOT NULL" do
        expect(dump_posts).to match(/user_id.*index: {.*where: "\(user_id IS NOT NULL\)"}/)
      end
    end

    it "should define expression" do
      with_index Post, :name => "posts_freaky_index", :expression => "USING hash (least(id, user_id))" do
        expect(dump_posts).to include(%q{t.index name: "posts_freaky_index", using: :hash, expression: "LEAST(id, user_id)"})
      end
    end

    it "should define multi-column with expression" do
      with_index Post, :body, :expression => "(least(id, user_id))" do
        expect(dump_posts).to match(/body.*index.*expression: "LEAST\(id, user_id\)"/)
      end
    end


    it "should define operator_class" do
      with_index Post, :body, :operator_class => 'text_pattern_ops' do
        expect(dump_posts).to match(/body.*index:.*operator_class: "text_pattern_ops"/)
      end
    end

    it "should define multi-column operator classes " do
      with_index Post, [:body, :string_no_default], :operator_class => {body: 'text_pattern_ops', string_no_default: 'varchar_pattern_ops' } do
        expect(dump_posts).to match(/body.*index:.*operator_class: {"body"=>"text_pattern_ops", "string_no_default"=>"varchar_pattern_ops"}/)
      end
    end
    
    it "should define multi-column operator classes even if one column has no operator" do
      with_index Post, [:body, :string_no_default], :operator_class => {string_no_default: 'varchar_pattern_ops'} do
        expect(dump_posts).to match(/body.*index:.*operator_class: {"string_no_default"=>"varchar_pattern_ops"}/)
      end
    end

    it 'should dump proper operator_class with case_sensitive => false' do
      with_index Post, :body, :operator_class => 'text_pattern_ops', :case_sensitive => false do
        expect(dump_posts).to match(/body.*index:.*name: "index_posts_on_body", case_sensitive: false, operator_class: "text_pattern_ops"/)
      end
    end

    it "should dump unique: true with expression (Issue #142)" do
      with_index Post, :name => "posts_user_body_index", :unique => true, :expression => "BTRIM(LOWER(body))" do
        expect(dump_posts).to include(%q{t.index name: "posts_user_body_index", unique: true, expression: "btrim(lower(body))"})
      end
    end


    it "should not define :case_sensitive => false with non-trivial expression" do
      with_index Post, :name => "posts_user_body_index", :expression => "BTRIM(LOWER(body))" do
        expect(dump_posts).to include(%q{t.index name: "posts_user_body_index", expression: "btrim(lower(body))"})
      end
    end

    it "should define using" do
      with_index Post, :name => "posts_body_index", :expression => "USING hash (body)" do
        expect(dump_posts).to match(/body.*index:.*using: :hash/)
      end
    end
  end

  protected

  def with_index(*args)
    options = args.extract_options!
    model, columns = args
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Migration.add_index(model.table_name, columns, options)
    end
    model.reset_column_information
    yield
  end

  def determine_index_name(model, columns, options)
    name = columns[:name] if columns.is_a?(Hash)
    name ||= options[:name]
    name ||= model.indexes.detect { |index| index.table == model.table_name.to_s && index.columns.sort == Array(columns).collect(&:to_s).sort }.name
    name
  end

  def dump_schema(opts={})
    stream = StringIO.new
    ActiveRecord::SchemaDumper.ignore_tables = Array.wrap(opts[:ignore]) || []
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    stream.string
  end

  def dump_posts
    dump_schema(:ignore => %w[users comments])
  end

end

