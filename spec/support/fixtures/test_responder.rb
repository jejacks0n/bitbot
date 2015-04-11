class TestResponder < Bitbot::Responder
  route :test, /^test/ do
    respond_with("Hey, it worked!")
  end
end
