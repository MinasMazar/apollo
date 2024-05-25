defmodule Apollo.Gemini.Api.Status do
  @names %{
    "10" => :input,
    "11" => :sensitive_input,
    "20" => :success,
    "30" => :temporary_redirect,
    "31" => :permanent_redirect,
    "40" => :temporary_failure,
    "41" => :server_unavailable,
    "42" => :cgi_error,
    "43" => :proxy_error,
    "44" => :slow_down,
    "50" => :permanent_failure,
    "51" => :not_found,
    "52" => :gone,
    "53" => :proxy_request_refused,
    "59" => :bad_request,
    "60" => :client_certificate_required,
    "61" => :certificate_not_authorized,
    "62" => :certificate_not_valid
  }

  @codes %{
    input: 10,
    sensitive_input: 11,
    success: 20,
    temporary_redirect: 30,
    permanent_redirect: 31,
    temporary_failure: 40,
    server_unavailable: 41,
    cgi_error: 42,
    proxy_error: 43,
    slow_down: 44,
    permanent_failure: 50,
    not_found: 51,
    gone: 52,
    proxy_request_refused: 53,
    bad_request: 59,
    client_certificate_required: 60,
    certificate_not_authorized: 61,
    certificate_not_valid: 62
  }

  def from_code(int) when is_integer(int), do: int |> to_string() |> from_code()
  def from_code(str) when is_binary(str), do: @names[str] || :invalid
  def from_code(_), do: :invalid

  def from_name(atom) when is_atom(atom), do: @codes[atom] || :invalid
  def from_name(_), do: :invalid

  def redirect?(response) do
    with status <- response.status do
      status == :temporary_redirect || status == :permanent_redirect
    end
  end
end
