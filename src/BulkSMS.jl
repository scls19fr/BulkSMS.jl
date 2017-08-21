module BulkSMS

    export BulkSMSClient, send, shorten, multiple

    using Requests: get, Response

    @enum ActionWhenLong shorten=1 multiple=2

    _DEFAULT_BASE_URL = "http://bulksms.vsms.net:5567"
    _DEFAULT_MAX_MESSAGE_LEN = 160

    mutable struct BulkSMSClientException <: Exception
        s::AbstractString
    end

    mutable struct BulkSMSResponse
        status_code::Int
        status_string::AbstractString
        id::Int
        function BulkSMSResponse(response::Response)
            s = readstring(response)
            statusCode, statusString, Id = split(s, "|")
            new(parse(Int64, statusCode), statusString, parse(Int64, Id))
        end
    end


    mutable struct BulkSMSClient
        msisdn::AbstractString
        username::AbstractString
        password::AbstractString

        base_url::AbstractString
        max_message_len::Int

        function BulkSMSClient(msisdn, username, password;
                base_url=_DEFAULT_BASE_URL,
                max_message_len=_DEFAULT_MAX_MESSAGE_LEN)
            new(msisdn, username, password, base_url, max_message_len)
        end
    end


    function _crop(msg, max_len)
        if max_len > 0 && length(msg) > max_len
            msg[1:max_len-3] * "..."
        else
            msg
        end
    end

    function _send(client::BulkSMSClient, message_text::AbstractString, msisdn::AbstractString)
        endpoint = "/eapi/submission/send_sms/2/2.0"

        url = client.base_url * endpoint

        params = Dict(
            "username" => client.username,
            "password" => client.password,
            "message" => message_text,
            "msisdn" => msisdn
        )

        raw_response = get(url; query = params)

        if raw_response.status != 200
            throw(BulkSMSClientException("HTTP status code != 200"))
        end

        response = BulkSMSResponse(raw_response)

        if response.status_code != 0
            throw(BulkSMSClientException("BulkSMS status code != 0"))
        end

        response
    end

    function send(client::BulkSMSClient, message_text::AbstractString; msisdn=nothing, action_when_long::ActionWhenLong=shorten)

        if msisdn === nothing
            msisdn = client.msisdn
        end

        response = nothing

        if action_when_long == shorten
            shorten_message_text = _crop(message_text, client.max_message_len)
            response = _send(client, shorten_message_text, msisdn)

        # elseif action_when_long == multiple

        else
            throw(BulkSMSClientException("action_when_long=$action_when_long is not a support action"))
        end

        response
    end

end # module
