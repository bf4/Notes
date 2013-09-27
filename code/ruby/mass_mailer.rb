module MassMailer
  module_function

  SMTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
           Errno::ECONNREFUSED, Net::SMTPSyntaxError, Net::SMTPFatalError]

  mattr_accessor :mailer_config
  self.mailer_config = Rails.application.config.action_mailer
  mailer_config.add_delivery_method(:smtp_connection, Mail::SMTP)

  mattr_accessor :original_delivery_method, :original_smtp_settings
  self.original_delivery_method = mailer_config.delivery_method
  self.original_smtp_settings   = mailer_config.smtp_settings

  mattr_accessor :fallback_delivery_method, :fallback_delivery_settings
  self.fallback_delivery_method = AppConfig.fallback_mail_senders[:delivery_method]
  self.fallback_delivery_settings = AppConfig.fallback_mail_senders[fallback_delivery_method].symbolize_keys

  def smtp_settings
    smtp_args = [:address, :port, :domain, :user_name, :password, :authentication]
    original_smtp_settings.values_at(*smtp_args)
  end

  def with_smtp_connection(&block)
    Net::SMTP.start(*smtp_settings) do |smtp|
      smtp.enable_starttls_auto if original_smtp_settings['enable_starttls_auto']
      mailer_config.smtp_settings = {:connection => smtp}
      mailer_config.delivery_method = :smtp_connection
      yield
    end
  rescue *SMTP_ERRORS => e
    log_mailer_failure(:smtp_connection_failure,e,:total_failure)
    notify_exception(e)
  ensure
    mailer_config.delivery_method = original_delivery_method
    mailer_config.smtp_settings = original_smtp_settings
  end

  def send_mail(mailer)
    mailer.delivery_method(mailer_config.delivery_method,  mailer_config.smtp_settings)
    mailer.deliver
  rescue *SMTP_ERRORS => e
    log_mailer_failure(mailer,e,:first_try)
    retry_send_mail(mailer)
  end

  def retry_send_mail(mailer)
    set_fallback_delivery_method(mailer)
    mailer.deliver
  rescue *SMTP_ERRORS => e
    log_mailer_failure(mailer,e,:second_try)
  end

  def set_fallback_delivery_method(mailer)
    log_error "***** FALLING BACK Could not send with settings #{mailer.delivery_method}"
    log_error "***** RETRYING with fallback settings"
    mailer.delivery_method(fallback_delivery_method,  fallback_delivery_settings)
  end

  def log_mailer_failure(mailer,e,attempt)
    log_error "**** FAILED sending email with #{attempt} at #{Time.now.to_s}\t#{mailer.inspect}\n\twith #{e.class}\t#{e.message}\n#{e.backtrace.join("\n")}"
  end

  def log_error(message)
    Rails.logger.error message
  end

  def notify_exception(e)
    Airbrake.notify(e)
  end

end
