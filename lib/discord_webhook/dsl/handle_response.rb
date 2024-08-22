class DiscordWebhook
  # Sometimes an endpoint has a response body on success that needs
  # to be handled. The when is determined by the user or the endpoint.
  #
  # execute/post: is determined by the user when using wait param
  # edit/patch:   always returns a response body
  # get:          always returns a response body
  # delete:       never returns a response body
  private def handle_response(response)
    if Net::HTTPSuccess === response
      if response.body
        Message.new(**JSON.parse(response.body, symbolize_names: true)).freeze
      end
    else
      if @raise_on_errors
        raise RequestError.new(**JSON.parse(response.body, symbolize_names: true))
      else
        RequestError.new(**JSON.parse(response.body, symbolize_names: true))
      end
    end
  end
end
