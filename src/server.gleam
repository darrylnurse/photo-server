import app/db
import app/web
import app/router
import dot_env
import dot_env/env
// import dotenv
// import gleam/erlang/os
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() {

  // squirrel seems to only work with dotenv and not dot_env 😒🐿️
  // dotenv.config()

  dot_env.new() 
  |> dot_env.set_path(".env") 
  |> dot_env.set_debug(False) 
  |> dot_env.load 

  let assert Ok(db_url) = env.get_string("DATABASE_URL")

  let pool = db.new_pool(db_url)

  case pool {
      Ok(connection) -> {
          wisp.configure_logger()

          let context = web.Context(db: connection)

          let secret_key_base = wisp.random_string(64)

          let handler = router.handle_request(_, context)

          let assert Ok(_) =
            handler
            |> wisp_mist.handler(secret_key_base)
            |> mist.new
            |> mist.port(2626)
            |> mist.start_http

          process.sleep_forever()
      }

      Error(_) -> Nil
  }

  
}
