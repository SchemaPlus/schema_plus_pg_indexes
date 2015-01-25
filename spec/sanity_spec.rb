require 'spec_helper'


# A basic sanity check to have as a spec when first starting.  Feel free to delete this
# once you've got real content.

describe "Sanity Check" do

  it "database is connected" do
    expect(ActiveRecord::Base).to be_connected
  end

end
