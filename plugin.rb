# name: discourse-delete-user-topics
# about: Deletes users posts in batches`
# version: 0.1
# required_version: 2.5.0
# author: kbiz
# url: https://forums.mixedmartialarts.com/

enabled_site_setting :delete_user_topics_enabled
after_initialize do
  require_dependency File.expand_path("../jobs/scheduled/delete_user_posts.rb", __FILE__)
end
 