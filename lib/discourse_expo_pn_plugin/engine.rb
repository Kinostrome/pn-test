# frozen_string_literal: true

module DiscourseExpoPnPlugin
  class Engine < ::Rails::Engine
    engine_name "DiscourseExpoPnPlugin".freeze
    isolate_namespace DiscourseExpoPnPlugin
    
    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::DiscourseExpoPnPlugin::Engine, at: "/expo_pn"
      end
    end
  end
end
