class TicketMailer < ApplicationMailer
    def ticket_mailer(email)
        mail(to: email , subject: 'Bus4U - successful order')
    end
end
