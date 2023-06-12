# frozen_string_literal: true

module Jobs
  class DeleteUserPosts < ::Jobs::Scheduled
    every 2.minutes

    def execute(args)
      return unless SiteSetting.delete_user_topics_enabled?

      username = SiteSetting.delete_posts_for_usernamee
      posts_per_batch = SiteSetting.delete_posts_in_single_batchs.to_i

      return unless username.present? && posts_per_batch.positive?

      user = User.find_by(username: username)
      return unless user.present?

      posts = user.posts.limit(posts_per_batch)

       # Cancel the scheduled job if there are no more posts remaining
      if posts.size < 100
        self.class.cancel_scheduled_job
      end
      posts.each do |post|
        if SiteSetting.delete_user_topics_dry_run?
          Rails.logger.error("DeleteUserPosts would remove Post ID #{post.id} (#{post.topic.title} - #{post.excerpt}) (dry run mode)")
        else
          Rails.logger.error("DeleteUserPosts removing Post ID #{post.id} (#{post.topic.title} - #{post.excerpt})")
          begin
            PostDestroyer.new(Discourse.system_user, post).destroy
          rescue StandardError => e
            Rails.logger.error("Error deleting post ID #{post.id}: #{e.message}")
          end
        end
      end  
    end
  end
end