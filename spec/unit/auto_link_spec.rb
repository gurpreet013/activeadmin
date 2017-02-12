require 'rails_helper'

RSpec.describe "auto linking resources", type: :view do
  include ActiveAdmin::ViewHelpers::ActiveAdminApplicationHelper
  include ActiveAdmin::ViewHelpers::AutoLinkHelper
  include ActiveAdmin::ViewHelpers::DisplayHelper
  include MethodOrProcHelper

  let(:active_admin_config)   { double namespace: namespace }
  let(:active_admin_namespace){ ActiveAdmin::Namespace.new(ActiveAdmin::Application.new, :admin) }
  let(:post){ Post.create! title: "Hello World" }

  before do
    allow(self).to receive(:authorized?).and_return(true)
  end

  context "when the resource is not registered" do
    it "should return the display name of the object" do
      expect(auto_link(post)).to eq "Hello World"
    end
  end

  context "when the resource is registered" do
    before do
      active_admin_namespace.register Post
    end

    it "should return a link with the display name of the object" do
      expect(auto_link(post)).to \
          match(%r{<a href="/admin/posts/\d+">Hello World</a>})
    end

    context "but the user doesn't have access" do
      before do
        allow(self).to receive(:authorized?).and_return(false)
      end

      it "should return the display name of the object" do
        expect(auto_link(post)).to eq "Hello World"
      end
    end

    context "but the show action is disabled" do
      before do
        active_admin_namespace.register(Post) { actions :all, except: :show }
      end

      it "should fallback to edit" do
        expect(auto_link(post)).to \
          match(%r{<a href="/admin/posts/\d+/edit">Hello World</a>})
      end
    end

    context "but the show and edit actions are disabled" do
      before do
        active_admin_namespace.register(Post) do
          actions :all, except: [:show, :edit]
        end
      end

      it "should return the display name of the object" do
        expect(auto_link(post)).to eq "Hello World"
      end
    end
  end
end
