# frozen_string_literal: true

# name: discourse-expo-pn-plugin
# about: Push notifications via Expo Notifications API.
# version: 1.0
# authors: kodefox
# url: https://github.com/kodefox/discourse-expo-pn-plugin

enabled_site_setting :expo_push_enabled

load File.expand_path('lib/discourse_expo_pn_plugin/engine.rb', __dir__)

after_initialize do
  if SiteSetting.expo_push_enabled
    load File.expand_path('jobs/expo_push_notification.rb', __dir__)

    User.class_eval do
      has_many :expo_pn_subscriptions, dependent: :delete_all
    end

    DiscourseEvent.on(:post_notification_alert) do |user, payload|
      if user.expo_pn_subscriptions.exists?
        Jobs.enqueue(:expo_push_notification,
          payload: payload,
          expo_pn_token: ExpoPnSubscription.where(user_id: user.id).pluck(:expo_pn_token),
        )
      end
    end
  end
end