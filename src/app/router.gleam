import app/photos
import app/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["photos"] -> photos.all(req, ctx)
    ["photos", slug] -> photos.one(req, ctx, slug)
    //["upload-photo"] -> photos.upload(req)

    _ -> wisp.not_found()
  }
}
