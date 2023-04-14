module Admin
    class DiscourseDeleteuserTopicsMasterSettingsController < ::Admin::AdminController
      def index
        # ...
      end
  
      def update
        # ... 
  
        if params[:delete_user_posts_button].present?
          Jobs.enqueue(:delete_user_posts_job)
        end
  
        # ...
      end
    end
  end
  