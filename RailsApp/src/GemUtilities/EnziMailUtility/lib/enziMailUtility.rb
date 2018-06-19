require 'mail'
class MailUtility
  @options = nil
  def initialize(userName,password)
    options = { :address              => "smtp.gmail.com",
                 :port                 => 587,
                 :user_name            => "#{userName}",
                 :password             => "#{password}",
                 :authentication       => 'plain',
                 :enable_starttls_auto => true  }
    @options = options
    Mail.defaults do
      delivery_method :smtp, options
    end

  end

  def sendMail(recipient,content,subject)
    fromEmail = @options.to_h[:user_name]
    Mail.deliver do
      to "#{recipient}"
      from fromEmail
      subject "#{subject}"
      html_part do
        content_type 'text/html; charset=UTF-8'
        body content
      end
=begin
      add_file "#{content}"
=end
    end
  end
end
#MailUtility.new('monika.pingale@enzigma.in','arya@1994').sendMail('monika.pingale@enzigma.in' , '<input type="button" value="Test"/>','Testing')