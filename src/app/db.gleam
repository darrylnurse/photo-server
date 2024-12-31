import pog

pub fn new_pool(db_url: String) ->  Result(pog.Connection, String) {

  case pog.url_config(db_url) {
    Ok(config) -> {
      case pog.connect(config) {
        pool -> Ok(pool)
      }
    }
    _ -> Error("DATABASE_URL is not set or is invalid")
  }
}

