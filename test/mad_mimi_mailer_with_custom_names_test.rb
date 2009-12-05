require "rubygems"
require "test/unit"
require "mocha"

require "mad_mimi_mailer"

MadMimiMailer.api_settings = {
  :username => "testy@mctestin.com",
  :api_key => "w00tb4r"
}

class MadMimiMailerWithCustomNames < MadMimiMailer
  self.template_root = File.dirname(__FILE__) + '/templates/'

  send_with_mad_mimi :hola

  def hola(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    bcc ["Gregg Pollack <gregg@example.com>", "David Clymer <david@example>"]
    promotion "hello"
    body :message => greeting
  end

  def hello(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    bcc ["Gregg Pollack <gregg@example.com>", "David Clymer <david@example>"]
    body :message => greeting
  end
end

class TestMadMimiMailerWithCustomNames < Test::Unit::TestCase
  def setup
    ActionMailer::Base.deliveries.clear
  end

  def test_mad_mimi_method
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \n:message: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    response.stubs(:body).returns("123435")
    MadMimiMailerWithCustomNames.expects(:post_request).yields(mock_request).returns(response)

    MadMimiMailerWithCustomNames.deliver_hola("welcome to mad mimi")
  end

  def test_actionmailer_method
    MadMimiMailerWithCustomNames.any_instance.expects(:perform_delivery_smtp).once
    MadMimiMailerWithCustomNames.deliver_hello("welcome to mad mimi")
  end
end
