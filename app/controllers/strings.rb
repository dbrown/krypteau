class Strings < Application
  
  def index
      @krypteaukeys = Krypteaukey.find(:all)
      render
  end

  def encrypt
    @krypteaukey = Krypteaukey.find(params[:krypteaukey])
    c = OpenSSL::Cipher::Cipher.new(@krypteaukey.algorithm)
    c.encrypt
    c.key = key = Base64.decode64(@krypteaukey.text)
    c.iv = iv = Base64.decode64(@krypteaukey.iv)
    e = c.update(params[:text])
    e << c.final
    @readable = Base64.encode64(e)
    render
  end

  def decrypt
    @krypteaukey = Krypteaukey.find(params[:krypteaukey])
    c = OpenSSL::Cipher::Cipher.new(@krypteaukey.algorithm)
    c.decrypt
    c.key = key = Base64.decode64(@krypteaukey.text)
    c.iv = iv = Base64.decode64(@krypteaukey.iv)
    d = c.update(Base64.decode64(params[:text]))
    @readable = d << c.final
    render
  end

end
  