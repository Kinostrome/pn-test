# frozen_string_literal: true

module DiscourseExpoPnPlugin
  class ExpoPnController < ::ApplicationController
    requires_plugin DiscourseExpoPnPlugin

    def subscribe
      expo_pn_token = params.require(:expo_pn_token)
      application_name = params.require(:application_name)
      platform = params.require(:platform)

      if ["ios", "android"].exclude?(platform)
        raise Discourse::InvalidParameters, "Platform parameter should be ios or android."
      end

      ExpoPnSubscription.where(expo_pn_token: expo_pn_token).where.not(user_id: current_user.id).destroy_all

      record = ExpoPnSubscription.find_or_create_by(
        user_id: current_user.id,
        expo_pn_token: expo_pn_token,
        application_name: application_name,
        platform: platform,
      )

      render json: record
    end
  end
end
