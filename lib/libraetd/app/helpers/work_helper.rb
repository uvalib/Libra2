module WorkHelper

  #
  # get a work and handle the reasonable failure cases by returning nil, pass up the exception otherwise
  #
  def get_generic_work( id )

    begin
       work = GenericWork.find( id )
       return work
    rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone, URI::InvalidURIError => ex
      puts "==> get_generic_work exception: #{ex}"
       return nil
    end

  end

end
