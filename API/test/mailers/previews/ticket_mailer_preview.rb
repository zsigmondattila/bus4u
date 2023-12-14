# Preview all emails at http://localhost:3000/rails/mailers/ticket_mailer
class TicketMailerPreview < ActionMailer::Preview

    def ticket_mailer
        TicketMailer.ticket_mailer
      end

end
