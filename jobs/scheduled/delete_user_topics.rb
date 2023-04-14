# frozen_string_literal: true

module Jobs
  class DeleteUserPosts < ::Jobs::Scheduled
    every 2.minutes

    def execute(args)
      return unless SiteSetting.delete_user_topics_enabled?
      username = SiteSetting.delete_posts_for_username
      batch = SiteSetting.delete_posts_in_single_batch
      return unless username.present? && batch.to_i > 0 

      user = User.find_by(username: username)
      return unless user.present?

      user.posts.order(created_at: :asc).each_slice(batch.to_i) do |posts|
        posts.each do |post|
          if SiteSetting.delete_user_topics_dry_run?
            Rails.logger.error("DeleteUserPosts would remove Post ID #{post.id} (#{post.topic.title} - #{post.excerpt}) (dry run mode)")
          else
            Rails.logger.error("DeleteUserPosts removing Post ID #{post.id} (#{post.topic.title} - #{post.excerpt})")
            PostDestroyer.new(Discourse.system_user, post).destroy
          end
        end
      end
    end
  end
end
