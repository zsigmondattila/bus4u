class CheckoutController < ApplicationController
  # Jegyek letrehozasa es fizetes elinditasa, a buy gomb lenyomasa utan hivodik
  def create
    if current_user.nil?
      render json: { error: "User not logged in" }, status: :unauthorized
      return
    end

    user = current_user
    quantity = params[:quantity].to_i || 1
    ticket_price = params[:ticket_price].to_i
    bought_tickets = []
    success = true
  
    quantity.times do
      ticket = Ticket.new
      ticket.company_uid = params[:company_uid]
      ticket.user_uid = user.uid
      ticket.ticket_type = "normal"
      ticket.route_uid = params[:route_uid]
      ticket.from_station_uid = params[:from_station_uid]
      ticket.to_station_uid = params[:to_station_uid]
      ticket.date_of_purchase = Time.now
      ticket.expiration_date = Time.now + 1.months
      ticket.ticket_price = ticket_price * 100
      ticket.is_valid = true
      ticket.is_paid = false
  
      success = success && ticket.save
      puts "#{ticket.errors} succ"
      bought_tickets << ticket.ticket_uid
    end
  
    if !success
      render json: { error: "Cannot create one or more tickets" }, status: :unprocessable_entity
    end

    route = Route.find_by(uid: params[:route_uid])
    from_station = Station.find_by(uid: params[:from_station_uid])
    to_station = Station.find_by(uid: params[:to_station_uid])

    session = Stripe::Checkout::Session.create({
      customer_email: current_user.email,
      line_items: [{
        price_data: {
          currency: 'ron',
          product_data: {
            name: 'Bus4U Ticket',
            description: "Ticket(s) for route #{route.name} from #{from_station.name} to #{to_station.name}",
            metadata: {
              tickets: bought_tickets.join(', '),
              user_uid: current_user.uid,
            },
          },
          unit_amount: (params[:ticket_price]).to_i * 100,
        },
        quantity: params[:quantity].to_i || 1,
      }],
      mode: 'payment',
      ui_mode: 'embedded',
      # return_url: 'http://localhost:5173/home?session_id={CHECKOUT_SESSION_ID}'
      return_url: 'https://bus4u.online/home?session_id={CHECKOUT_SESSION_ID}'
    })

    render json: { clientSecret: session.client_secret }
  end

  # Fizetesi statusz lekerese, a fooldalra valo visszateres utan hivja meg a kliens
  # Itt derul ki hogy sikeres volt-e a fizetes, ha igen, akkor elkuldi az emailt
  def status
    if current_user.nil?
      render json: { error: "User not logged in" }, status: :unauthorized
      return
    end

    session = Stripe::Checkout::Session.retrieve({
      expand: ['line_items'],
      id: params[:session_id]
    })

    if session.status != 'complete'
      render json: { status: session.status, ticket: nil }, status: :unprocessable_entity
      return
    end

    data = session.line_items.data[0]
    metadata = Stripe::Product.retrieve(data.price.product).metadata

    bought_tickets = metadata['tickets'].split(', ').map(&:strip)
    if bought_tickets.empty?
      render json: { error: "No tickets found in the session metadata" }, status: :unprocessable_entity
      return
    end

    send_email = false
    for ticket_uid in bought_tickets
      ticket = Ticket.find_by(ticket_uid: ticket_uid)
      if ticket && !ticket.is_paid
        send_email = true
        ticket.is_paid = true
        ticket.save
      end
    end

    if send_email
      TicketMailer.ticket_mailer(current_user.email).deliver_now
    end
    
    if current_user.uid == metadata['user_uid']
      render json: { status: session.status, ticket: bought_tickets[0] }
    else
      render json: { error: "The user and the ticket owner doesn't match" }, status: :unauthorized
    end
  end
end
