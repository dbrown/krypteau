class Krypteaukeys < Application
  
  def index
    @krypteaukeys = Krypteaukey.find( :all, :order => "created_at DESC" )
    @ciphers = OpenSSL::Cipher.ciphers
    render
  end

  def create     
      algorithm = params[:algorithm]
      c = OpenSSL::Cipher::Cipher.new(algorithm)
      c.encrypt
      c.key = key = c.random_key
      c.iv = iv = c.random_iv
      iv = Base64.encode64(iv)
      text = Base64.encode64(key)
      Krypteaukey.create!(  :name => params[:name],
                            :algorithm => algorithm,
                            :iv => iv,
                            :text => text  )
      redirect url( :action => "index" )
  end
  
end
