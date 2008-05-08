class Files < Application
  
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
  
    File.open("/Users/dbrown/Development/krypteau/uploads/#{params[:file][:filename]}.enc",'wb') do |enc|
      File.open(params[:file][:tempfile].path,"rb") do |f|
      size = File.size(params[:file][:tempfile].path)
      blocks = size / 8
        for i in 1..blocks
          r = f.read(8)
          cipher = c.update(r)
          enc << cipher
        end
        if size%8 >0
          r = f.read((size%8))
          cipher = c.update(r)
          enc << cipher
        end
      end
      enc << c.final
    end 
    redirect "/files"
  end

end