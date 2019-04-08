module RedmineEmailFiddler
  module MailerPatch

    module PrependMethods
      def issue_add
        issue_add_with_fiddle
        super
      end
      def issue_edit
        issue_edit_with_fiddle
        super
      end
    end

    def self.install
      Mailer.class_eval do
        def mail_fiddler_format(fmt_string, issue)
          fmt_string.gsub(/(\{(project|tracker|issue_id|subject|status)\})/i).each do |w|
            case w.downcase
            when "{project}"
              issue.project.name
            when "{tracker}"
              issue.tracker.name
            when "{issue_id}"
              "##{issue.id}"
            when "{subject}"
              issue.subject
            when "{status}"
              issue.status.name
            end
          end
        end

        def issue_add_with_fiddle(*args)
          mail = issue_add_without_fiddle(*args)
          new_subject_fmt = Setting.plugin_redmine_email_fiddler["issue_add_subject"]
          if new_subject_fmt != ""
            issue = args[0]
            new_subject = mail_fiddler_format new_subject_fmt, issue
            Rails.logger.debug "redmine_email_fiddler: old_subject #{mail.subject.inspect}, new_subject #{new_subject.inspect}"
            mail.subject = new_subject
          end
          mail
        end

        def issue_edit_with_fiddle(*args)
          mail = issue_edit_without_fiddle(*args)
          new_subject_fmt = Setting.plugin_redmine_email_fiddler["issue_edit_subject"]
          if new_subject_fmt != ""
            journal = args[0]
            issue = journal.journalized
            new_subject = mail_fiddler_format new_subject_fmt, issue
            Rails.logger.debug "redmine_email_fiddler: old_subject #{mail.subject.inspect}, new_subject #{new_subject.inspect}"
            mail.subject = new_subject
          end
          mail
        end
      end
      Mailer.class_eval do
        if self.respond_to?(:alias_method_chain)
          # rails < 5
          alias_method_chain :issue_add, :fiddle
          alias_method_chain :issue_edit, :fiddle
        else
          alias_method :issue_add_with_fiddle, :issue_add
          alias_method :issue_edit_with_fiddle, :issue_edit
          prepend PrependMethods
        end
      end
    end

  end
end
