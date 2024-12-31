import gleam/io
import gleam/option
import app/web.{type Context}
import gleam/dynamic.{type Dynamic}
import gleam/http.{Get, Post}
import gleam/json
import gleam/string_tree
import wisp.{type Request, type Response}
import app/sql.{all_photos, single_photo, new_photo}
import pog

type FirstPhotoFields {
    FirstPhotoFields (
        id: Int,
        added: String,
        url: String,
        title: String,
        date: String,
        location: String,
        camera: String,
        focal_length: String,
        aperture: String,
    )
}

type SecondPhotoFields {
    SecondPhotoFields (
        shutter_speed: String,
        iso: Int 
    )
}

pub type Photo {
    Photo(
        id: Int,
        added: String,
        url: String,
        title: String,
        date: String,
        location: String,
        camera: String,
        focal_length: String,
        aperture: String,
        shutter_speed: String,
        iso: Int
    )
}

pub fn all(req: Request, ctx: Context) -> Response {
    case req.method {
        Get ->  list_photos(ctx)
        Post -> add_photos(req, ctx)
        _ -> wisp.method_not_allowed([Get, Post])
    }
}

pub fn one(req: Request, ctx: Context, id: Int) -> Response {
    case req.method {
        Get -> read_photo(ctx, id)
        _ -> wisp.method_not_allowed([Get])
    }
}

pub fn list_photos(ctx: Context){
    let assert Ok(pog.Returned(_rows_count, rows)) = all_photos(ctx.db)
    let default_string = "NONE"
    
    let result = {
        Ok(
            json.to_string_tree(
                json.object([
                    #(
                        "photos",
                        json.array(rows, fn(row){ 
                            json.object([
                                #("id", json.int(row.id)),
                                #("added", json.string(option.unwrap(row.added, default_string))),
                                #("url", json.string(option.unwrap(row.url, default_string))),
                                #("title", json.string(option.unwrap(row.title, default_string))),
                                #("date", json.string(option.unwrap(row.date, default_string))),
                                #("location", json.string(option.unwrap(row.location, default_string))),
                                #("camera",json.string(option.unwrap(row.camera, default_string))),
                                #("focal_length", json.string(option.unwrap(row.focal_length, default_string))),
                                #("aperture", json.string(option.unwrap(row.aperture, default_string))),
                                #("shutter_speed", json.string(option.unwrap(row.shutter_speed, default_string))),
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

pub fn read_photo(ctx: Context, id: Int) -> Response {

    let assert Ok(pog.Returned(_rows_count, rows)) = single_photo(ctx.db, id)
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
                        json.array(rows, fn(row){ 
                            json.object([
                                #("id", json.int(row.id)),
                                #("added", json.string(option.unwrap(row.added, default_string))),
                                #("url", json.string(option.unwrap(row.url, default_string))),
                                #("title", json.string(option.unwrap(row.title, default_string))),
                                #("date", json.string(option.unwrap(row.date, default_string))),
                                #("location", json.string(option.unwrap(row.location, default_string))),
                                #("camera",json.string(option.unwrap(row.camera, default_string))),
                                #("focal_length", json.string(option.unwrap(row.focal_length, default_string))),
                                #("aperture", json.string(option.unwrap(row.aperture, default_string))),
                                #("shutter_speed", json.string(option.unwrap(row.shutter_speed, default_string))),
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
            
            let result = new_photo(
                ctx.db, 
                photo.id,
                photo.added,
                photo.url,
                photo.title,
                photo.date,
                photo.location,
                photo.camera,
                photo.focal_length,
                photo.aperture,
                photo.shutter_speed,
                photo.iso
            ) 

            case result {
                Ok(_) -> wisp.json_response(string_tree.from_string("{\"name\": \"Joe\"}"), 201)
                Error(_) -> wisp.unprocessable_entity()
            }
        }

        // 415 here (needs all json fields)
        Error(Nil) -> wisp.unprocessable_entity()
    }
}

fn decode_photo(json: Dynamic) -> Result(Photo, Nil) {
    let first_decoder = dynamic.decode9(
        FirstPhotoFields,
        dynamic.field("id", dynamic.int),
        dynamic.field("added", dynamic.string),
        dynamic.field("url", dynamic.string),
        dynamic.field("title", dynamic.string),
        dynamic.field("date", dynamic.string),
        dynamic.field("location", dynamic.string),
        dynamic.field("camera", dynamic.string),
        dynamic.field("focal_length", dynamic.string),
        dynamic.field("aperture", dynamic.string),
    )

    let second_decoder = dynamic.decode2(
        SecondPhotoFields,
        dynamic.field("shutter_speed", dynamic.string),
        dynamic.field("iso", dynamic.int),
    )

    let part1 = first_decoder(json)
    let part2 = second_decoder(json)

    case part1, part2 {
        Ok(FirstPhotoFields(id, added, url, title, date, location, camera, focal_length, aperture)), 
        Ok(SecondPhotoFields(shutter_speed, iso)) 
            -> Ok(Photo(id, added, url, title, date, location, camera, focal_length, aperture, shutter_speed, iso))

        // if the json request does not have all the required fields it will throw a 415
        // i think it's reasonable: no fields should be missing
        Error(e1), Error(e2)-> {
            io.debug(e1)
            io.debug(e2)
            Error(Nil)
        }

        _, _ -> Error(Nil)
    }
}
