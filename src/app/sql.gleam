import gleam/dynamic/decode
import gleam/option.{type Option}
import pog

/// A row you get from running the `single_photo` query
/// defined in `./src/app/sql/single_photo.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.1.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type SinglePhotoRow {
  SinglePhotoRow(
    id: Int,
    added: Option(String),
    url: Option(String),
    title: Option(String),
    date: Option(String),
    location: Option(String),
    camera: Option(String),
    focal_length: Option(String),
    aperture: Option(String),
    shutter_speed: Option(String),
    iso: Option(Int),
  )
}

/// Runs the `single_photo` query
/// defined in `./src/app/sql/single_photo.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn single_photo(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use added <- decode.field(1, decode.optional(decode.string))
    use url <- decode.field(2, decode.optional(decode.string))
    use title <- decode.field(3, decode.optional(decode.string))
    use date <- decode.field(4, decode.optional(decode.string))
    use location <- decode.field(5, decode.optional(decode.string))
    use camera <- decode.field(6, decode.optional(decode.string))
    use focal_length <- decode.field(7, decode.optional(decode.string))
    use aperture <- decode.field(8, decode.optional(decode.string))
    use shutter_speed <- decode.field(9, decode.optional(decode.string))
    use iso <- decode.field(10, decode.optional(decode.int))
    decode.success(
      SinglePhotoRow(
        id:,
        added:,
        url:,
        title:,
        date:,
        location:,
        camera:,
        focal_length:,
        aperture:,
        shutter_speed:,
        iso:,
      ),
    )
  }

  let query = "SELECT
    *
FROM
    photos
WHERE
    id = $1"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `new_photo` query
/// defined in `./src/app/sql/new_photo.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn new_photo(
  db,
  arg_1,
  arg_2,
  arg_3,
  arg_4,
  arg_5,
  arg_6,
  arg_7,
  arg_8,
  arg_9,
  arg_10,
  arg_11,
) {
  let decoder =
  decode.map(decode.dynamic, fn(_) { Nil })

  let query =
  "INSERT INTO
    photos (id, added, url, title, date, location, camera, focal_length, aperture, shutter_speed, iso)
VALUES
    ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.parameter(pog.text(arg_5))
  |> pog.parameter(pog.text(arg_6))
  |> pog.parameter(pog.text(arg_7))
  |> pog.parameter(pog.text(arg_8))
  |> pog.parameter(pog.text(arg_9))
  |> pog.parameter(pog.text(arg_10))
  |> pog.parameter(pog.int(arg_11))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `all_photos` query
/// defined in `./src/app/sql/all_photos.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.1.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type AllPhotosRow {
  AllPhotosRow(
    id: Int,
    added: Option(String),
    url: Option(String),
    title: Option(String),
    date: Option(String),
    location: Option(String),
    camera: Option(String),
    focal_length: Option(String),
    aperture: Option(String),
    shutter_speed: Option(String),
    iso: Option(Int),
  )
}

/// Runs the `all_photos` query
/// defined in `./src/app/sql/all_photos.sql`.
///
/// > 🐿️ This function was generated automatically using v2.1.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn all_photos(db) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use added <- decode.field(1, decode.optional(decode.string))
    use url <- decode.field(2, decode.optional(decode.string))
    use title <- decode.field(3, decode.optional(decode.string))
    use date <- decode.field(4, decode.optional(decode.string))
    use location <- decode.field(5, decode.optional(decode.string))
    use camera <- decode.field(6, decode.optional(decode.string))
    use focal_length <- decode.field(7, decode.optional(decode.string))
    use aperture <- decode.field(8, decode.optional(decode.string))
    use shutter_speed <- decode.field(9, decode.optional(decode.string))
    use iso <- decode.field(10, decode.optional(decode.int))
    decode.success(
      AllPhotosRow(
        id:,
        added:,
        url:,
        title:,
        date:,
        location:,
        camera:,
        focal_length:,
        aperture:,
        shutter_speed:,
        iso:,
      ),
    )
  }

  let query = "SELECT
    *
FROM    
    photos"

  pog.query(query)
  |> pog.returning(decoder)
  |> pog.execute(db)
}
