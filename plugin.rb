# name: discourse-delete-user-topics
# about: Deletes topics without replies older than x days in certain categories`
# version: 0.1
# required_version: 2.5.0
# author: DiscourseHosting
# url: https://forums.mixedmartialarts.com/

enabled_site_setting :delete_user_topics_enabled
after_initialize do
  require_dependency File.expand_path("../jobs/scheduled/delete_user_topics.rb", __FILE__)
end
 