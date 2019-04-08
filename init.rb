Redmine::Plugin.register :redmine_email_fiddler do
  name "Email Fiddler plugin"
  author "Rafael Vargas"
  description "A Redmine plugin to enable fiddling with the notification emails subjects"
  version "0.2"
  url "https://github.com/rsvargas/redmine_email_fiddler"
  author_url "https://github.com/rsvargas"
  settings :partial => "settings/redmine_email_fiddler",
    :default => {
      "issue_add_subject" => "",
      "issue_edit_subject" => "",
    }
end

# needed for easy redmine 2018
require "mailer_patch" 

Rails.configuration.to_prepare do
  RedmineEmailFiddler::MailerPatch.install
end
