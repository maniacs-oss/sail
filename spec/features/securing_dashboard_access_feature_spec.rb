# frozen_string_literal: true

feature "securing dashboard access", js: true, type: :feature do
  class User; end

  before do
    Sail.configure do |config|
      config.dashboard_auth_lambda = -> { redirect_to("/") unless user.admin? }
    end

    Sail::SettingsController.before_action(*Sail.configuration.dashboard_auth_lambda)

    Sail::Setting.create!(name: "setting", cast_type: :string,
                          value: :something,
                          description: "Setting that does something",
                          group: "feature_flags")
  end

  context "when user is admin" do
    it "can navigate to Sail" do
      user = User.new
      def user.admin?; true; end

      allow_any_instance_of(Sail::SettingsController).to receive(:user).and_return(user)

      visit "/sail"
      expect(page).to have_text("Setting")
    end
  end

  context "when user is not admin" do
    it "is redirect to root path" do
      user = User.new
      def user.admin?; false; end

      allow_any_instance_of(Sail::SettingsController).to receive(:user).and_return(user)

      visit "/sail"
      expect(page).to have_text("Inside dummy app")
    end
  end
end