import wisp.{type Request, type Response}
import gleam/http
import cors_builder as cors
import pog

pub type Context {
    Context(db: pog.Connection)
}

pub fn middleware(
    req: Request,
    handle_request: fn(Request) -> Response
) -> Response {
    let req = wisp.method_override(req)

    use <- wisp.log_request(req)
    use <- wisp.rescue_crashes
    use req <- wisp.handle_head(req)
    use req <- cors.wisp_middleware(req, cors())

    handle_request(req)
}

fn cors() {
    cors.new()
    |> cors.allow_origin("http://localhost:5173")
    |> cors.allow_origin("http://localhost:5174")
    |> cors.allow_origin("https://photo-client.onrender.com")
    |> cors.allow_origin("https://omenclate.com")
    |> cors.allow_method(http.Get)
    |> cors.allow_method(http.Post)
    |> cors.allow_method(http.Options)
    |> cors.allow_header("content-type")
    |> cors.allow_header("authorization")
    |> cors.allow_header("origin")
}