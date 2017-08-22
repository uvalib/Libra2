module WorkHelper

  #
  # get a work and handle the reasonable failure cases by returning nil, pass up the exception otherwise
  #
  def get_generic_work( id )

    begin
       work = GenericWork.find( id )
       return work
    rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
       return nil
    end

  end

end
