import gleam/dynamic.{type Dynamic}
import gleam/http.{Get, Post}
import gleam/io
import gleam/json
import gleam/option
import gleam/string
import gleam/string_tree

// import gleam/http/request
// import gleam/http/response
// import gleam/httpc
// import gleam/result
// import gleeunit/should
import app/sql.{all_photos, new_photo, single_photo}
import app/web.{type Context}
import pog
import wisp.{type Request, type Response}

// import birl
// import simplifile

type FirstPhotoFields {
  FirstPhotoFields(
    date_added: String,
    url: String,
    title: String,
    date_taken: String,
    location: String,
    camera: String,
    focal_length: String,
  )
}

type SecondPhotoFields {
  SecondPhotoFields(aperture: String, shutter_speed: String, iso: Int)
}

type UploadPhoto {
  UploadPhoto (
    date_added: String,
    url: String,
    slug: String,
    title: String,
    date_taken: String,
    location: String,
    camera: String,
    focal_length: String,
    aperture: String,
    shutter_speed: String,
    iso: Int,
  )
}

pub type Photo {
  Photo(
    id: Int,
    date_added: String,
    url: String,
    slug: String,
    title: String,
    date_taken: String,
    location: String,
    camera: String,
    focal_length: String,
    aperture: String,
    shutter_speed: String,
    iso: Int,
  )
}

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> list_photos(ctx)
    Post -> add_photos(req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn one(req: Request, ctx: Context, slug: String) -> Response {
  case req.method {
    Get -> read_photo(ctx, slug)
    _ -> wisp.method_not_allowed([Get])
  }
}

pub fn list_photos(ctx: Context) {
  let assert Ok(pog.Returned(_rows_count, rows)) = all_photos(ctx.db)
  let default_string = "NONE"

  let result = {
    Ok(
      json.to_string_tree(
        json.object([
          #(
            "photos",
            json.array(rows, fn(row) {
              json.object([
                #("id", json.int(row.id)),
                #("date_added", json.string(row.date_added)),
                #("url", json.string(row.url)),
                #("slug", json.string(row.slug)),
                #("title", json.string(row.title)),
                #(
                  "date_taken",
                  json.string(option.unwrap(row.date_taken, default_string)),
                ),
                #(
                  "location",
                  json.string(option.unwrap(row.location, default_string)),
                ),
                #(
                  "camera",
                  json.string(option.unwrap(row.camera, default_string)),
                ),
                #(
                  "focal_length",
                  json.string(option.unwrap(row.focal_length, default_string)),
                ),
                #(
                  "aperture",
                  json.string(option.unwrap(row.aperture, default_string)),
                ),
                #(
                  "shutter_speed",
                  json.string(option.unwrap(row.shutter_speed, default_string)),
                ),
                #("iso", json.int(option.unwrap(row.iso, 0))),
              ])
            }),
          ),
        ]),
      ),
    )
  }

  case result {
    Ok(json) -> wisp.json_response(json, 200)
    Error(Nil) -> wisp.internal_server_error()
  }
}

pub fn read_photo(ctx: Context, slug: String) -> Response {
  let assert Ok(pog.Returned(_rows_count, rows)) = single_photo(ctx.db, slug)
  let default_string = "NONE"

  let result = {
    Ok(
      json.to_string_tree(
        json.object([
          #(
            "photo",
            // leaving a lot of this "dupe" code
            // single and all might change, for example:
            // single shows full details and all only shows url, title, date, etc.
            json.array(rows, fn(row) {
              json.object([
                #("id", json.int(row.id)),
                #("date_added", json.string(row.date_added)),
                #("url", json.string(row.url)),
                #("slug", json.string(row.slug)),
                #("title", json.string(row.title)),
                #(
                  "date_taken",
                  json.string(option.unwrap(row.date_taken, default_string)),
                ),
                #(
                  "location",
                  json.string(option.unwrap(row.location, default_string)),
                ),
                #(
                  "camera",
                  json.string(option.unwrap(row.camera, default_string)),
                ),
                #(
                  "focal_length",
                  json.string(option.unwrap(row.focal_length, default_string)),
                ),
                #(
                  "aperture",
                  json.string(option.unwrap(row.aperture, default_string)),
                ),
                #(
                  "shutter_speed",
                  json.string(option.unwrap(row.shutter_speed, default_string)),
                ),
                #("iso", json.int(option.unwrap(row.iso, 0))),
              ])
            }),
          ),
        ]),
      ),
    )
  }

  case result {
    Ok(json) -> wisp.json_response(json, 200)
    Error(Nil) -> wisp.internal_server_error()
  }
}

fn add_photos(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  io.debug(json)
  let decoded_photo = decode_photo(json)
  case decoded_photo {
    Ok(photo) -> {
      let result =
        new_photo(
          ctx.db,
          photo.date_added,
          photo.url,
          photo.slug,
          photo.title,
          photo.date_taken,
          photo.location,
          photo.camera,
          photo.focal_length,
          photo.aperture,
          photo.shutter_speed,
          photo.iso,
        )
      case result {
        Ok(_) ->
          wisp.json_response(
            string_tree.from_string("{\"upload_status\": \"Success!\"}"),
            201,
          )
        Error(_) -> wisp.unprocessable_entity()
      }
    }

    // 422 here (needs all json fields)
    Error(Nil) -> wisp.unprocessable_entity()
  }
}

fn decode_photo(json: Dynamic) -> Result(UploadPhoto, Nil) {
  let first_decoder =
    dynamic.decode7(
      FirstPhotoFields,
      dynamic.field("date_added", dynamic.string),
      dynamic.field("url", dynamic.string),
      dynamic.field("title", dynamic.string),
      dynamic.field("date_taken", dynamic.string),
      dynamic.field("location", dynamic.string),
      dynamic.field("camera", dynamic.string),
      dynamic.field("focal_length", dynamic.string),
    )

  let second_decoder =
    dynamic.decode3(
      SecondPhotoFields,
      dynamic.field("aperture", dynamic.string),
      dynamic.field("shutter_speed", dynamic.string),
      dynamic.field("iso", dynamic.int),
    )

  let part1 = first_decoder(json)
  let part2 = second_decoder(json)

  case part1, part2 {
    Ok(FirstPhotoFields(
      date_added,
      url,
      title,
      date_taken,
      location,
      camera,
      focal_length,
    )),
      Ok(SecondPhotoFields(aperture, shutter_speed, iso))
    -> {
      let slug = create_slug(title)
      Ok(UploadPhoto(
        date_added,
        url,
        slug,
        title,
        date_taken,
        location,
        camera,
        focal_length,
        aperture,
        shutter_speed,
        iso,
      ))
    }

    // if the json request does not have all the required fields it will throw a 415
    // i think it's reasonable: no fields should be missing
    Error(e1), Error(e2) -> {
      io.debug(e1)
      io.debug(e2)
      Error(Nil)
    }

    _, _ -> Error(Nil)
  }
}

fn create_slug(title: String) -> String {
  title
  |> string.lowercase
  |> string.replace(each: " ", with: "-")
}

// post image to s3 bucket and return the url to image
// req param should be the image

// pub fn upload(req: Request) {
//   let body = req.body.temporary_directory
//   // let binary_path = body.temporary_directory
//   // case simplifile.read(from: binary_path) {
//   //     Ok(bits) -> io.debug(bits)
//   //     Error(_) -> "Errored out."
//   // }
//   io.debug(body)

//   // case req.body {
//   //     // Ok(_) -> upload_to_bucket()
//   //     _ -> wisp.unprocessable_entity()
//   // }

//   wisp.json_response(
//     string_tree.from_string("{\"upload_status\": \"Okay.\"}"),
//     200,
//   )
// }
// goal rn: get bit array from client
// then: craft url to upload to s3
// then: get url 

// fn upload_to_bucket(image_data: List(Int)) {
//     let assert Ok(base_req) = request.to("http://gleam-photo-bucket.s3.us-east-2.amazonaws.com")
//     let request = request.prepend_header(base_req, "accept", "application/vnd.hmrc.1.0+json")

//     let file_name = "uploads/image-" <> create_timestamp() <> ".jpg"

//     request 
//     |> request.set_method(Post)
//     |> request.set_body()

//     use resp <- result.try(httpc.send(request))

//     resp.status
//     |> should.equal(200)

//     resp
//     |> response.get_header("content-type")
//     |> should.equal(Ok("application/json"))

//     Ok(resp)
// }

// fn create_timestamp() -> String {
//     // created timestamp is: year-month-day-hour-minute-second-millisecond
//     let now = birl.now()
//     birl.to_naive_date_string(now) <> "-" <> birl.to_naive_time_string(now)
//     |> string.replace(each: ":", with: "-")
//     |> string.replace(each: ".", with: "-")
// }
