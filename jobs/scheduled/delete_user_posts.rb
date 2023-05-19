# frozen_string_literal: true

module Jobs
  class DeleteUserPosts < ::Jobs::Scheduled
    every 2.minutes

    def execute(args)
      return unless SiteSetting.delete_user_topics_enabled?

      username = SiteSetting.delete_posts_for_username
      posts_per_batch = SiteSetting.delete_posts_in_single_batch.to_i

      return unless username.present? && posts_per_batch.positive?

      user = User.find_by(username: username)
      return unless user.present?

      posts = user.posts.order(created_at: :asc)

      deleted_count = 0
      posts.each do |post|
        break if deleted_count >= posts_per_batch

        if SiteSetting.delete_user_topics_dry_run?
          Rails.logger.error("DeleteUserPosts would remove Post ID #{post.id} (#{post.topic.title} - #{post.excerpt}) (dry run mode)")
        else
          Rails.logger.error("DeleteUserPosts removing Post ID #{post.id} (#{post.topic.title} - #{post.excerpt})")
          begin
            PostDestroyer.new(Discourse.system_user, post).destroy
            deleted_count += 1
          rescue StandardError => e
            Rails.logger.error("Error deleting post ID #{post.id}: #{e.message}")
          end
        end
      end

      # Cancel the scheduled job if there are no more posts remaining
      if posts.size <= posts_per_batch
        self.class.cancel_scheduled_job
      end
    end
  end
end