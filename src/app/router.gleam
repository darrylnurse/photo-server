import app/web.{type Context}
import app/photos
import wisp.{type Request, type Response}
import gleam/int

pub fn handle_request(req: Request, ctx: Context) -> Response {
    use req <- web.middleware(req)

    case wisp.path_segments(req) {
        ["photos"] -> photos.all(req, ctx)
        ["photos", id] -> {
            let int_id = int.parse(id)
            case int_id {
                Ok(int) -> photos.one(req, ctx, int)
                Error(_) -> wisp.not_found()
            }
            
        }

        _ -> wisp.not_found()
    }
}
