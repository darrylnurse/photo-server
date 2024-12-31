// shutup for now tests

// import app/router
// import gleam/string
// import gleeunit
// import gleeunit/should
// import wisp/testing

// pub fn main() {
//   gleeunit.main()
// }

// // gleeunit test functions should end in `_test`

// pub fn view_form_test() {
//   let response = router.handle_request(testing.get("/", []))

//   response.status
//   |> should.equal(200)

//   response.headers
//   |> should.equal([#("content-type", "text/html; charset=utf-8")])

//   response
//   |> testing.string_body
//   |> string.contains("<form method='post'>")
//   |> should.equal(True)
// }

// pub fn submit_missing_parameters_test() {
//   let response =
//     testing.post_form("/", [], [])
//     |> router.handle_request()

//   response.status
//   |> should.equal(400)
// }

// pub fn submit_successful_test() {
//   let response =
//     testing.post_form("/", [], [#("title", "Captain"), #("name", "Caveman")])
//     |> router.handle_request()

//   response.status
//   |> should.equal(200)

//   response.headers
//   |> should.equal([#("content-type", "text/html; charset=utf-8")])

//   response
//   |> testing.string_body
//   |> should.equal("Hi, Captain Caveman!")
// }
